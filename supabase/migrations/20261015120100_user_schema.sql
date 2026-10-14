-- Per-user tables. RLS restricts every row to its owner — see the
-- Supabase skill's security checklist (TO authenticated + an
-- ownership predicate in USING, WITH CHECK on every UPDATE).

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text,
  full_name text,
  created_at timestamptz not null default now()
);

create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  service_area_id uuid references public.service_areas (id) on delete set null,
  label text not null,
  line1 text not null,
  area text not null,
  city text not null,
  state text not null,
  postal_code text not null,
  landmark text,
  lat double precision not null,
  lng double precision not null,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create index addresses_user_id_idx on public.addresses (user_id);

create table public.carts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now()
);

create table public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts (id) on delete cascade,
  product_variant_id uuid not null references public.product_variants (id) on delete cascade,
  quantity int not null check (quantity > 0),
  updated_at timestamptz not null default now(),
  unique (cart_id, product_variant_id)
);

create index cart_items_cart_id_idx on public.cart_items (cart_id);

alter table public.profiles enable row level security;
alter table public.addresses enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;

create policy "users can read their own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

create policy "users can update their own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy "users can manage their own addresses"
on public.addresses for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "users can manage their own cart"
on public.carts for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "users can manage their own cart items"
on public.cart_items for all
to authenticated
using (
  exists (
    select 1 from public.carts
    where carts.id = cart_items.cart_id
      and carts.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.carts
    where carts.id = cart_items.cart_id
      and carts.user_id = (select auth.uid())
  )
);

-- Auto-create a profile (and an empty cart) when a user signs up.
-- SECURITY DEFINER is required here (the trigger runs before the new
-- user has a session to satisfy the profiles RLS policy above), but it
-- is a trigger function, not a callable RPC, so it isn't exposed the
-- way a public SECURITY DEFINER function would be.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, phone, full_name)
  values (new.id, new.phone, new.raw_user_meta_data ->> 'full_name');

  insert into public.carts (user_id) values (new.id);

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
