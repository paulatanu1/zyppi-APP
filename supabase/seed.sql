-- Mirrors assets/mock/*.json so the Supabase-backed data source looks
-- the same as the mock one during development. Run via
-- `supabase db reset` (local) or `psql ... -f supabase/seed.sql`.
--
-- `image` holds an object path inside the `catalog-images` Storage
-- bucket (see 20261015120400_catalog_images_storage.sql), not a
-- public URL — SupabaseCatalogRepository resolves it to one via
-- `storage.from('catalog-images').getPublicUrl()`. The actual files
-- (assets/images/*.png) still need uploading to that bucket once per
-- project (`supabase storage cp` or the dashboard) — this seed only
-- inserts the rows that reference them.

-- center_lat/lng/radius_meters are approximate town centers; refine
-- against the real dark-store addresses before launch.
insert into public.service_areas (id, name, is_active, center_lat, center_lng, radius_meters) values
  ('11111111-0000-0000-0000-000000000001', 'Purulia', true, 23.3324, 86.3617, 6000),
  ('11111111-0000-0000-0000-000000000002', 'Raghunathpur', true, 23.5667, 86.6667, 5000),
  ('11111111-0000-0000-0000-000000000003', 'Chelyama', true, 23.4833, 86.6333, 4000);

insert into public.stores (id, service_area_id, name, is_active) values
  ('22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'Zyppi Purulia Dark Store', true),
  ('22222222-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000002', 'Zyppi Raghunathpur Dark Store', true),
  ('22222222-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000003', 'Zyppi Chelyama Dark Store', true);

insert into public.categories (id, name, image, color_hex, border_color_hex, sort_order) values
  ('33333333-0000-0000-0000-000000000001', 'Fresh Fruits & Vegetables', 'categories/category.png', '1A53B175', 'FF53B175', 0),
  ('33333333-0000-0000-0000-000000000002', 'Bread & Eggs', 'categories/bread.png', 'FFFFECF7', 'FFFB54B6', 1),
  ('33333333-0000-0000-0000-000000000003', 'Atta, Rice & Dals', 'categories/rice.png', '1AF8A44C', 'FFFABD7C', 2),
  ('33333333-0000-0000-0000-000000000004', 'Masala & Dry Fruits', 'categories/category.png', 'FFEDF7FD', 'FF52BAF4', 3),
  ('33333333-0000-0000-0000-000000000005', 'Cooking Oil & Ghee', 'categories/oil.png', '1AF8A44C', 'B2F8A44C', 4),
  ('33333333-0000-0000-0000-000000000006', 'Meat & Fish', 'categories/meat.png', '3FF7A593', 'FFF7A593', 5),
  ('33333333-0000-0000-0000-000000000007', 'Bakery & Snacks', 'categories/bread.png', '3FFDE598', 'FFFDE598', 6),
  ('33333333-0000-0000-0000-000000000008', 'Beverages', 'categories/beverages.png', '3FB7DFF5', 'FFB7DFF5', 7);

insert into public.products (id, category_id, name, image) values
  ('44444444-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000001', 'Fresh Tomatoes', 'products/veg.png'),
  ('44444444-0000-0000-0000-000000000002', '33333333-0000-0000-0000-000000000001', 'Apple', 'products/apple.png'),
  ('44444444-0000-0000-0000-000000000003', '33333333-0000-0000-0000-000000000002', 'Brown Bread', 'products/bread.png'),
  ('44444444-0000-0000-0000-000000000004', '33333333-0000-0000-0000-000000000003', 'Basmati Rice', 'products/rice.png'),
  ('44444444-0000-0000-0000-000000000005', '33333333-0000-0000-0000-000000000005', 'Sunflower Oil', 'products/oil.png'),
  ('44444444-0000-0000-0000-000000000006', '33333333-0000-0000-0000-000000000006', 'Chicken Curry Cut', 'products/meat.png'),
  ('44444444-0000-0000-0000-000000000007', '33333333-0000-0000-0000-000000000008', 'Toned Milk', 'products/milk.png'),
  ('44444444-0000-0000-0000-000000000008', '33333333-0000-0000-0000-000000000007', 'Butter Cookies', 'products/item.png');

insert into public.product_variants (id, product_id, label, price_paise, mrp_paise) values
  ('55555555-0000-0000-0000-000000000001', '44444444-0000-0000-0000-000000000001', '500 g', 2500, 3000),
  ('55555555-0000-0000-0000-000000000002', '44444444-0000-0000-0000-000000000002', '1 kg', 18000, 20000),
  ('55555555-0000-0000-0000-000000000003', '44444444-0000-0000-0000-000000000003', '400 g', 4500, 5000),
  ('55555555-0000-0000-0000-000000000004', '44444444-0000-0000-0000-000000000004', '1 kg', 14500, 16000),
  ('55555555-0000-0000-0000-000000000005', '44444444-0000-0000-0000-000000000004', '5 kg', 68000, 75000),
  ('55555555-0000-0000-0000-000000000006', '44444444-0000-0000-0000-000000000005', '1 L', 15000, 17000),
  ('55555555-0000-0000-0000-000000000007', '44444444-0000-0000-0000-000000000006', '500 g', 15500, 17500),
  ('55555555-0000-0000-0000-000000000008', '44444444-0000-0000-0000-000000000007', '1 L', 6400, 6800),
  ('55555555-0000-0000-0000-000000000009', '44444444-0000-0000-0000-000000000008', '200 g', 5600, 6000);

-- Stock every variant at every store (100 units) so place_order()'s
-- stock check passes out of the box in dev/staging.
insert into public.inventory (store_id, product_variant_id, quantity)
select s.id, pv.id, 100
from public.stores s
cross join public.product_variants pv;

-- One express slot plus several concrete scheduled windows (checkout's
-- "Schedule" option lists these); eta_minutes on a scheduled slot is
-- minutes-from-now at seed time, not a live countdown — refining that
-- into real date-relative windows is future polish (PLAN.md §6).
insert into public.delivery_slots (id, label, eta_minutes, is_express) values
  ('66666666-0000-0000-0000-000000000001', 'In 12 minutes', 12, true),
  ('66666666-0000-0000-0000-000000000002', 'Today, 4:00 PM - 6:00 PM', 180, false),
  ('66666666-0000-0000-0000-000000000003', 'Today, 6:00 PM - 8:00 PM', 300, false),
  ('66666666-0000-0000-0000-000000000004', 'Tomorrow, 8:00 AM - 10:00 AM', 900, false),
  ('66666666-0000-0000-0000-000000000005', 'Tomorrow, 10:00 AM - 12:00 PM', 1020, false);

insert into public.coupons (code, description, discount_paise, min_order_paise) values
  ('ZYPPI50', 'Flat ₹50 off on orders above ₹300', 5000, 30000);
