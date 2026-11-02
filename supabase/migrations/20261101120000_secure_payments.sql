-- Server-verified payments.
--
-- Before this, place_order() accepted any non-null client-supplied PhonePe
-- transaction id as proof of payment, nothing tied the charged amount to
-- the order total, and one payment could back any number of orders. Now:
--
--   1. create-phonepe-order quotes the order on the server (quote_order),
--      records a payment_intent with that amount and the order's
--      parameters, then opens PhonePe for exactly that amount.
--   2. verify-phonepe-payment checks PhonePe's status *and* paid amount,
--      then calls place_paid_order() with the service role. The order is
--      created server-side even if the app dies after paying, and calling
--      it again returns the same order (idempotent).
--   3. place_order() is now cash-on-delivery only for clients.
--
-- Orders also keep a snapshot of the delivery address, and user/address
-- foreign keys become ON DELETE SET NULL, so an account (or address) can
-- be deleted while its order history stays intact for accounting.

-- ---------------------------------------------------------------------------
-- Orders: address snapshot + deletable owners
-- ---------------------------------------------------------------------------

alter table public.orders
  add column address_label text,
  add column address_text text;

update public.orders o
set address_label = a.label,
    address_text = concat_ws(', ', a.line1, a.area, a.city, a.postal_code)
from public.addresses a
where a.id = o.address_id;

alter table public.orders
  alter column user_id drop not null,
  alter column address_id drop not null,
  drop constraint orders_user_id_fkey,
  drop constraint orders_address_id_fkey,
  add constraint orders_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete set null,
  add constraint orders_address_id_fkey
    foreign key (address_id) references public.addresses (id) on delete set null;

-- Tips are capped (₹500), matching the app's tip selector.
alter table public.orders
  add constraint orders_tip_cap check (tip_paise <= 50000);

-- One real payment can never back two orders.
create unique index payments_provider_reference_key
  on public.payments (provider_reference)
  where provider_reference is not null;

-- ---------------------------------------------------------------------------
-- Payment intents
-- ---------------------------------------------------------------------------

create table public.payment_intents (
  merchant_order_id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  amount_paise int not null check (amount_paise > 0),
  payment_method text not null,
  address_id uuid not null,
  delivery_slot_id uuid not null,
  coupon_code text,
  tip_paise int not null default 0,
  status text not null default 'created'
    check (status in ('created', 'completed', 'failed', 'needs_review')),
  transaction_id text unique,
  order_id uuid references public.orders (id) on delete set null,
  failure_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index payment_intents_user_id_idx on public.payment_intents (user_id);

alter table public.payment_intents enable row level security;

-- Clients may read their own intents (e.g. to resume a pending one);
-- only the Edge Functions (service role) ever write them.
revoke all on public.payment_intents from anon, authenticated;
grant select on public.payment_intents to authenticated;

create policy "users can read their own payment intents"
on public.payment_intents for select
to authenticated
using ((select auth.uid()) = user_id);

-- ---------------------------------------------------------------------------
-- quote_order: the single source of truth for an order's validity + total
-- ---------------------------------------------------------------------------

create function public.quote_order(
  p_user_id uuid,
  p_address_id uuid,
  p_delivery_slot_id uuid,
  p_coupon_code text default null,
  p_tip_paise int default 0
)
returns table (
  cart_id uuid,
  service_area_id uuid,
  coupon_id uuid,
  item_total_paise int,
  delivery_fee_paise int,
  handling_fee_paise int,
  discount_paise int,
  total_paise int
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_handling_fee_paise constant int := 500; -- ₹5, matches BillCalculator
  v_delivery_fee_paise constant int := 0;   -- free, matches BillCalculator
  v_cart_id uuid;
  v_service_area_id uuid;
  v_item record;
  v_item_total int := 0;
  v_available int;
  v_coupon record;
  v_coupon_id uuid; -- a record field can't be read before assignment
  v_discount int := 0;
begin
  if p_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_tip_paise < 0 or p_tip_paise > 50000 then
    raise exception 'Invalid tip';
  end if;

  select a.service_area_id into v_service_area_id
  from addresses a
  where a.id = p_address_id and a.user_id = p_user_id;

  if v_service_area_id is null then
    raise exception 'Address not found or not serviceable';
  end if;

  if not exists (
    select 1 from stores s
    where s.service_area_id = v_service_area_id and s.is_active
  ) then
    raise exception 'We do not deliver to this address yet';
  end if;

  if not exists (
    select 1 from delivery_slots d
    where d.id = p_delivery_slot_id and d.is_active
  ) then
    raise exception 'Delivery slot is not available';
  end if;

  select c.id into v_cart_id from carts c where c.user_id = p_user_id;

  if v_cart_id is null or not exists (
    select 1 from cart_items ci where ci.cart_id = v_cart_id
  ) then
    raise exception 'Cart is empty';
  end if;

  -- Stock and prices from the live catalog; inactive products can't be
  -- ordered.
  for v_item in
    select ci.product_variant_id, ci.quantity, pv.price_paise, p.name, p.is_active
    from cart_items ci
    join product_variants pv on pv.id = ci.product_variant_id
    join products p on p.id = pv.product_id
    where ci.cart_id = v_cart_id
  loop
    if not v_item.is_active then
      raise exception 'Product unavailable: %', v_item.name;
    end if;

    select coalesce(sum(inv.quantity), 0) into v_available
    from inventory inv
    join stores s on s.id = inv.store_id
    where inv.product_variant_id = v_item.product_variant_id
      and s.service_area_id = v_service_area_id
      and s.is_active;

    if v_available < v_item.quantity then
      raise exception 'Insufficient stock for %', v_item.name;
    end if;

    v_item_total := v_item_total + v_item.price_paise * v_item.quantity;
  end loop;

  if p_coupon_code is not null then
    select * into v_coupon
    from coupons cp
    where cp.code = upper(p_coupon_code)
      and cp.is_active
      and (cp.expires_at is null or cp.expires_at > now());

    if found and v_item_total >= v_coupon.min_order_paise then
      v_discount := least(v_coupon.discount_paise, v_item_total);
      v_coupon_id := v_coupon.id;
    end if;
  end if;

  return query select
    v_cart_id,
    v_service_area_id,
    v_coupon_id,
    v_item_total,
    v_delivery_fee_paise,
    v_handling_fee_paise,
    v_discount,
    v_item_total + v_delivery_fee_paise + v_handling_fee_paise + p_tip_paise - v_discount;
end;
$$;

revoke all on function public.quote_order(uuid, uuid, uuid, text, int) from public, anon, authenticated;
grant execute on function public.quote_order(uuid, uuid, uuid, text, int) to service_role;

-- ---------------------------------------------------------------------------
-- place_order_internal: creates the order from the user's server cart
-- ---------------------------------------------------------------------------

create function public.place_order_internal(
  p_user_id uuid,
  p_address_id uuid,
  p_delivery_slot_id uuid,
  p_payment_method text,
  p_coupon_code text,
  p_tip_paise int,
  p_payment_status text,
  p_provider_reference text,
  p_expected_total_paise int default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_quote record;
  v_order_id uuid;
  v_item record;
  v_address record;
begin
  select * into v_quote
  from quote_order(p_user_id, p_address_id, p_delivery_slot_id, p_coupon_code, p_tip_paise);

  if p_expected_total_paise is not null and v_quote.total_paise <> p_expected_total_paise then
    raise exception 'PAYMENT_AMOUNT_MISMATCH';
  end if;

  select label, concat_ws(', ', line1, area, city, postal_code) as text
  into v_address
  from addresses where id = p_address_id;

  insert into orders (
    user_id, address_id, address_label, address_text, delivery_slot_id,
    coupon_id, status, payment_method, item_total_paise, delivery_fee_paise,
    handling_fee_paise, tip_paise, discount_paise, total_paise
  ) values (
    p_user_id, p_address_id, v_address.label, v_address.text, p_delivery_slot_id,
    v_quote.coupon_id, 'placed', p_payment_method, v_quote.item_total_paise,
    v_quote.delivery_fee_paise, v_quote.handling_fee_paise, p_tip_paise,
    v_quote.discount_paise, v_quote.total_paise
  )
  returning id into v_order_id;

  for v_item in
    select ci.product_variant_id, ci.quantity, pv.price_paise, pv.label, p.name
    from cart_items ci
    join product_variants pv on pv.id = ci.product_variant_id
    join products p on p.id = pv.product_id
    where ci.cart_id = v_quote.cart_id
  loop
    insert into order_items (order_id, product_variant_id, name, unit, quantity, price_paise)
    values (v_order_id, v_item.product_variant_id, v_item.name, v_item.label, v_item.quantity, v_item.price_paise);

    -- Decrement from whichever serviceable store currently holds the most
    -- stock of this variant (simplified single-store fulfilment).
    update inventory
    set quantity = inventory.quantity - v_item.quantity, updated_at = now()
    where id = (
      select inv.id
      from inventory inv
      join stores s on s.id = inv.store_id
      where inv.product_variant_id = v_item.product_variant_id
        and s.service_area_id = v_quote.service_area_id
        and s.is_active
      order by inv.quantity desc
      limit 1
    );
  end loop;

  insert into order_events (order_id, status) values (v_order_id, 'placed');

  insert into payments (order_id, method, amount_paise, status, provider_reference)
  values (v_order_id, p_payment_method, v_quote.total_paise, p_payment_status, p_provider_reference);

  delete from cart_items where cart_id = v_quote.cart_id;

  return v_order_id;
end;
$$;

revoke all on function public.place_order_internal(uuid, uuid, uuid, text, text, int, text, text, int) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Client entry point: cash on delivery only
-- ---------------------------------------------------------------------------

drop function if exists public.place_order(uuid, uuid, text, text, int, text, text);

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
begin
  if p_payment_method <> 'Cash on delivery' then
    -- Prepaid orders are only ever created by verify-phonepe-payment.
    raise exception 'Online payments must be confirmed by the server';
  end if;

  return place_order_internal(
    auth.uid(), p_address_id, p_delivery_slot_id, p_payment_method,
    p_coupon_code, p_tip_paise, 'pending', null
  );
end;
$$;

revoke all on function public.place_order(uuid, uuid, text, text, int) from public, anon;
grant execute on function public.place_order(uuid, uuid, text, text, int) to authenticated;

-- ---------------------------------------------------------------------------
-- Service-role entry point: turn a verified PhonePe payment into an order
-- ---------------------------------------------------------------------------

create function public.place_paid_order(
  p_merchant_order_id text,
  p_transaction_id text,
  p_paid_amount_paise int
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_intent payment_intents%rowtype;
  v_order_id uuid;
begin
  -- Serialise concurrent verifications of the same payment.
  select * into v_intent
  from payment_intents
  where merchant_order_id = p_merchant_order_id
  for update;

  if v_intent.merchant_order_id is null then
    raise exception 'Unknown payment';
  end if;

  -- Idempotent: a repeat verification returns the order already created.
  if v_intent.order_id is not null then
    return v_intent.order_id;
  end if;

  if p_paid_amount_paise <> v_intent.amount_paise then
    update payment_intents
    set status = 'needs_review', transaction_id = p_transaction_id,
        failure_reason = 'Paid amount differs from quote', updated_at = now()
    where merchant_order_id = p_merchant_order_id;
    -- Return rather than raise: raising would roll back this update.
    return null;
  end if;

  begin
    v_order_id := place_order_internal(
      v_intent.user_id, v_intent.address_id, v_intent.delivery_slot_id,
      v_intent.payment_method, v_intent.coupon_code, v_intent.tip_paise,
      'succeeded', p_transaction_id, v_intent.amount_paise
    );
  exception when others then
    -- The customer has paid but the order can't be created (stock ran
    -- out, cart changed, …). Keep the evidence for a refund/manual order.
    update payment_intents
    set status = 'needs_review', transaction_id = p_transaction_id,
        failure_reason = sqlerrm, updated_at = now()
    where merchant_order_id = p_merchant_order_id;
    return null;
  end;

  update payment_intents
  set status = 'completed', transaction_id = p_transaction_id,
      order_id = v_order_id, updated_at = now()
  where merchant_order_id = p_merchant_order_id;

  return v_order_id;
end;
$$;

revoke all on function public.place_paid_order(text, text, int) from public, anon, authenticated;
grant execute on function public.place_paid_order(text, text, int) to service_role;
