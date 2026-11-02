-- pgTAP checks for 20261101120000_secure_payments.sql.
-- Run against a local stack (needs Docker): `supabase test db`.
-- Relies on supabase/seed.sql (Purulia area/store, slots, inventory).
begin;
select plan(9);

-- A customer with an address and one item (Tomatoes 500 g, ₹25) in cart.
insert into auth.users (id, email)
values ('aaaaaaaa-0000-0000-0000-000000000001', 'pay-test@example.com');
-- carts/profiles rows come from the on_auth_user_created trigger.
insert into public.addresses (id, user_id, service_area_id, label, line1, area, city, state, postal_code, lat, lng)
values ('bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001', 'Home', 'Ranchi Road', 'Saheb Bandh', 'Purulia', 'WB', '723101', 23.33, 86.36);
insert into public.cart_items (cart_id, product_variant_id, quantity)
select c.id, '55555555-0000-0000-0000-000000000001', 2
from public.carts c where c.user_id = 'aaaaaaaa-0000-0000-0000-000000000001';

-- Quote: 2 × ₹25 + ₹5 handling + ₹0 delivery + ₹10 tip = ₹65.
select is(
  (select total_paise from public.quote_order(
    'aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001',
    '66666666-0000-0000-0000-000000000001', null, 1000)),
  6500, 'quote_order prices the server cart');

select throws_ok(
  $$select public.quote_order('aaaaaaaa-0000-0000-0000-000000000001',
    'bbbbbbbb-0000-0000-0000-000000000001', '66666666-0000-0000-0000-000000000001', null, 60000)$$,
  'Invalid tip', 'tips above the cap are rejected');

-- Clients can no longer place prepaid orders themselves.
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-0000-0000-000000000001","role":"authenticated"}';
select throws_ok(
  $$select public.place_order('bbbbbbbb-0000-0000-0000-000000000001',
    '66666666-0000-0000-0000-000000000001', 'UPI')$$,
  'Online payments must be confirmed by the server', 'place_order is COD-only for clients');
select throws_ok(
  $$select public.place_paid_order('zyppi-x', 'txn', 100)$$,
  '42501', null, 'clients cannot call place_paid_order');
reset role;

select throws_ok(
  $$select public.place_paid_order('zyppi-missing', 'txn', 100)$$,
  'Unknown payment', 'an unknown payment is rejected');

-- A payment whose amount differs from the quote is parked for review.
insert into public.payment_intents (merchant_order_id, user_id, amount_paise, payment_method, address_id, delivery_slot_id, tip_paise)
values ('zyppi-test-1', 'aaaaaaaa-0000-0000-0000-000000000001', 6500, 'UPI',
        'bbbbbbbb-0000-0000-0000-000000000001', '66666666-0000-0000-0000-000000000001', 1000);
select is(public.place_paid_order('zyppi-test-1', 'txn-1', 100), null, 'wrong amount: no order');
select is((select status from public.payment_intents where merchant_order_id = 'zyppi-test-1'),
  'needs_review', 'wrong amount: intent needs review');

-- The right amount creates the order exactly once.
insert into public.payment_intents (merchant_order_id, user_id, amount_paise, payment_method, address_id, delivery_slot_id, tip_paise)
values ('zyppi-test-2', 'aaaaaaaa-0000-0000-0000-000000000001', 6500, 'UPI',
        'bbbbbbbb-0000-0000-0000-000000000001', '66666666-0000-0000-0000-000000000001', 1000);
select isnt(public.place_paid_order('zyppi-test-2', 'txn-2', 6500), null, 'paid: order created');
select is(public.place_paid_order('zyppi-test-2', 'txn-2', 6500),
  (select order_id from public.payment_intents where merchant_order_id = 'zyppi-test-2'),
  'repeat verification returns the same order');

select * from finish();
rollback;
