-- Catalog + delivery infrastructure tables. Clients only ever read
-- these (RLS grants no insert/update/delete to anon/authenticated) —
-- writes happen from the dashboard, a future admin app, or seed.sql.

create table public.service_areas (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.stores (
  id uuid primary key default gen_random_uuid(),
  service_area_id uuid not null references public.service_areas (id) on delete cascade,
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index stores_service_area_id_idx on public.stores (service_area_id);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  image text,
  color_hex text not null,
  border_color_hex text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories (id) on delete restrict,
  name text not null,
  image text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index products_category_id_idx on public.products (category_id);

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete cascade,
  label text not null,
  price_paise int not null check (price_paise >= 0),
  mrp_paise int check (mrp_paise is null or mrp_paise >= price_paise),
  created_at timestamptz not null default now()
);

create index product_variants_product_id_idx on public.product_variants (product_id);

create table public.inventory (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores (id) on delete cascade,
  product_variant_id uuid not null references public.product_variants (id) on delete cascade,
  quantity int not null default 0 check (quantity >= 0),
  updated_at timestamptz not null default now(),
  unique (store_id, product_variant_id)
);

create index inventory_product_variant_id_idx on public.inventory (product_variant_id);

create table public.delivery_slots (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  eta_minutes int not null check (eta_minutes > 0),
  is_express boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.coupons (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  description text,
  discount_paise int not null check (discount_paise >= 0),
  min_order_paise int not null default 0 check (min_order_paise >= 0),
  is_active boolean not null default true,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.service_areas enable row level security;
alter table public.stores enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.inventory enable row level security;
alter table public.delivery_slots enable row level security;
alter table public.coupons enable row level security;

-- Catalog is read-only for clients; only active rows are visible.
create policy "service_areas are publicly readable"
on public.service_areas for select
to anon, authenticated
using (is_active);

create policy "stores are publicly readable"
on public.stores for select
to anon, authenticated
using (is_active);

create policy "categories are publicly readable"
on public.categories for select
to anon, authenticated
using (true);

create policy "products are publicly readable"
on public.products for select
to anon, authenticated
using (is_active);

create policy "product_variants are publicly readable"
on public.product_variants for select
to anon, authenticated
using (true);

create policy "inventory is publicly readable"
on public.inventory for select
to anon, authenticated
using (true);

create policy "delivery_slots are publicly readable"
on public.delivery_slots for select
to anon, authenticated
using (is_active);

-- Coupons: only the code/discount needed to validate one client-side;
-- place_order() re-validates server-side regardless.
create policy "active coupons are publicly readable"
on public.coupons for select
to anon, authenticated
using (is_active and (expires_at is null or expires_at > now()));
