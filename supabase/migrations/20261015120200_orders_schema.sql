-- Orders are never written directly by clients — only place_order()
-- below (SECURITY DEFINER, re-validates stock/price/coupon/
-- serviceability) can create one. Clients can only read their own.

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete restrict,
  address_id uuid not null references public.addresses (id) on delete restrict,
  delivery_slot_id uuid not null references public.delivery_slots (id) on delete restrict,
  coupon_id uuid references public.coupons (id) on delete set null,
  status text not null default 'placed'
    check (status in ('placed', 'packed', 'out_for_delivery', 'delivered', 'cancelled')),
  payment_method text not null,
  item_total_paise int not null check (item_total_paise >= 0),
  delivery_fee_paise int not null default 0 check (delivery_fee_paise >= 0),
  handling_fee_paise int not null default 0 check (handling_fee_paise >= 0),
  tip_paise int not null default 0 check (tip_paise >= 0),
  discount_paise int not null default 0 check (discount_paise >= 0),
  total_paise int not null check (total_paise >= 0),
  placed_at timestamptz not null default now()
);

create index orders_user_id_idx on public.orders (user_id);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_variant_id uuid not null references public.product_variants (id) on delete restrict,
  name text not null,
  unit text not null,
  quantity int not null check (quantity > 0),
  price_paise int not null check (price_paise >= 0)
);

create index order_items_order_id_idx on public.order_items (order_id);

create table public.order_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  status text not null,
  created_at timestamptz not null default now()
);

create index order_events_order_id_idx on public.order_events (order_id);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  method text not null,
  amount_paise int not null check (amount_paise >= 0),
  status text not null default 'pending'
    check (status in ('pending', 'succeeded', 'failed', 'refunded')),
  provider_reference text,
  created_at timestamptz not null default now()
);

create index payments_order_id_idx on public.payments (order_id);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_events enable row level security;
alter table public.payments enable row level security;

create policy "users can read their own orders"
on public.orders for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "users can read their own order items"
on public.order_items for select
to authenticated
using (
  exists (
    select 1 from public.orders
    where orders.id = order_items.order_id
      and orders.user_id = (select auth.uid())
  )
);

create policy "users can read their own order events"
on public.order_events for select
to authenticated
using (
  exists (
    select 1 from public.orders
    where orders.id = order_events.order_id
      and orders.user_id = (select auth.uid())
  )
);

create policy "users can read their own payments"
on public.payments for select
to authenticated
using (
  exists (
    select 1 from public.orders
    where orders.id = payments.order_id
      and orders.user_id = (select auth.uid())
  )
);

-- No insert/update/delete policies on orders/order_items/order_events/
-- payments for anon/authenticated: all writes happen through
-- place_order() (checkout) or, in a later phase, service-role-only
-- RPCs/webhooks for status updates and payment confirmation.

create function public.place_order(
  p_address_id uuid,
  p_delivery_slot_id uuid,
  p_payment_method text,
  p_coupon_code text default null,
  p_tip_paise int default 0
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_cart_id uuid;
  v_order_id uuid;
  v_item record;
  v_item_total_paise int := 0;
  v_handling_fee_paise constant int := 500; -- ₹5, matches BillCalculator
  v_delivery_fee_paise constant int := 0;   -- free, matches BillCalculator
  v_discount_paise int := 0;
  v_total_paise int;
  v_coupon record;
  v_service_area_id uuid;
  v_store_count int;
  v_available int;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_tip_paise < 0 then
    raise exception 'Tip cannot be negative';
  end if;

  -- The address must belong to the caller and sit in a serviceable area.
  select service_area_id into v_service_area_id
  from addresses
  where id = p_address_id and user_id = v_user_id;

  if v_service_area_id is null then
    raise exception 'Address not found or not serviceable';
  end if;

  select count(*) into v_store_count
  from stores
  where service_area_id = v_service_area_id and is_active = true;

  if v_store_count = 0 then
    raise exception 'We do not deliver to this address yet';
  end if;

  if not exists (
    select 1 from delivery_slots
    where id = p_delivery_slot_id and is_active = true
  ) then
    raise exception 'Delivery slot is not available';
  end if;

  select id into v_cart_id from carts where user_id = v_user_id;

  if v_cart_id is null or not exists (
    select 1 from cart_items where cart_id = v_cart_id
  ) then
    raise exception 'Cart is empty';
  end if;

  -- Re-check stock and compute the item total from current catalog
  -- prices (never trust client-supplied totals).
  for v_item in
    select ci.product_variant_id, ci.quantity, pv.price_paise, pv.label, p.name
    from cart_items ci
    join product_variants pv on pv.id = ci.product_variant_id
    join products p on p.id = pv.product_id
    where ci.cart_id = v_cart_id
  loop
    select coalesce(sum(inv.quantity), 0) into v_available
    from inventory inv
    join stores s on s.id = inv.store_id
    where inv.product_variant_id = v_item.product_variant_id
      and s.service_area_id = v_service_area_id
      and s.is_active = true;

    if v_available < v_item.quantity then
      raise exception 'Insufficient stock for %', v_item.name;
    end if;

    v_item_total_paise := v_item_total_paise + v_item.price_paise * v_item.quantity;
  end loop;

  if p_coupon_code is not null then
    select * into v_coupon
    from coupons
    where code = upper(p_coupon_code)
      and is_active
      and (expires_at is null or expires_at > now());

    if v_coupon.id is not null and v_item_total_paise >= v_coupon.min_order_paise then
      v_discount_paise := least(v_coupon.discount_paise, v_item_total_paise);
    else
      v_coupon.id := null;
    end if;
  end if;

  v_total_paise := v_item_total_paise + v_delivery_fee_paise + v_handling_fee_paise
    + p_tip_paise - v_discount_paise;

  insert into orders (
    user_id, address_id, delivery_slot_id, coupon_id, status, payment_method,
    item_total_paise, delivery_fee_paise, handling_fee_paise, tip_paise,
    discount_paise, total_paise
  ) values (
    v_user_id, p_address_id, p_delivery_slot_id, v_coupon.id, 'placed', p_payment_method,
    v_item_total_paise, v_delivery_fee_paise, v_handling_fee_paise, p_tip_paise,
    v_discount_paise, v_total_paise
  )
  returning id into v_order_id;

  for v_item in
    select ci.product_variant_id, ci.quantity, pv.price_paise, pv.label, p.name
    from cart_items ci
    join product_variants pv on pv.id = ci.product_variant_id
    join products p on p.id = pv.product_id
    where ci.cart_id = v_cart_id
  loop
    insert into order_items (order_id, product_variant_id, name, unit, quantity, price_paise)
    values (v_order_id, v_item.product_variant_id, v_item.name, v_item.label, v_item.quantity, v_item.price_paise);

    -- Decrement from whichever serviceable store currently holds the
    -- most stock of this variant (simplified single-store fulfilment).
    update inventory
    set quantity = inventory.quantity - v_item.quantity, updated_at = now()
    where id = (
      select inv.id
      from inventory inv
      join stores s on s.id = inv.store_id
      where inv.product_variant_id = v_item.product_variant_id
        and s.service_area_id = v_service_area_id
        and s.is_active = true
      order by inv.quantity desc
      limit 1
    );
  end loop;

  insert into order_events (order_id, status) values (v_order_id, 'placed');

  delete from cart_items where cart_id = v_cart_id;

  return v_order_id;
end;
$$;

-- Keep this callable by signed-in users only; SECURITY DEFINER
-- functions in `public` are PUBLIC-executable by default (per the
-- Supabase skill's security checklist), so explicitly revoke from
-- anon/public before granting to authenticated.
revoke all on function public.place_order(uuid, uuid, text, text, int) from public, anon;
grant execute on function public.place_order(uuid, uuid, text, text, int) to authenticated;
