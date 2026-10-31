-- Phase 4 follow-up: Razorpay was never actually used (the app's
-- Razorpay account never existed, only its integration code did) - this
-- replaces the Razorpay payment reference params with PhonePe's.
-- Verification still happens client-side via create-phonepe-order /
-- verify-phonepe-payment *before* place_order() is called; place_order()
-- just records what already happened in `payments`.
drop function if exists public.place_order(uuid, uuid, text, text, int, text, text);

create function public.place_order(
  p_address_id uuid,
  p_delivery_slot_id uuid,
  p_payment_method text,
  p_coupon_code text default null,
  p_tip_paise int default 0,
  p_phonepe_merchant_order_id text default null,
  p_phonepe_transaction_id text default null
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

  if p_payment_method <> 'Cash on delivery' and p_phonepe_transaction_id is null then
    raise exception 'Payment was not confirmed';
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

  insert into payments (order_id, method, amount_paise, status, provider_reference)
  values (
    v_order_id,
    p_payment_method,
    v_total_paise,
    case when p_phonepe_transaction_id is not null then 'succeeded' else 'pending' end,
    coalesce(p_phonepe_transaction_id, p_phonepe_merchant_order_id)
  );

  delete from cart_items where cart_id = v_cart_id;

  return v_order_id;
end;
$$;

revoke all on function public.place_order(uuid, uuid, text, text, int, text, text) from public, anon;
grant execute on function public.place_order(uuid, uuid, text, text, int, text, text) to authenticated;
