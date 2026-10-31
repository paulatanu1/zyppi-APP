-- Admin panel (zyppi-admin, Angular): every catalog/order/user table's own
-- comment already said writes would come "from the dashboard, a future
-- admin app, or seed.sql" — this is that admin app. The Angular app is a
-- pure client-side SPA (no server runtime) using only the anon key, so
-- admin write access has to be RLS-gated by an admin_users table rather
-- than relying on a service-role key the browser bundle can't safely hold.

create table public.admin_users (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;

-- Admins can see who else is an admin (handy for the panel itself later);
-- no insert/update/delete policy - admin provisioning stays a manual,
-- service-role-key operation, not something the panel can do to itself.
create policy "admins can read admin_users"
on public.admin_users for select
to authenticated
using (exists (select 1 from public.admin_users au where au.id = auth.uid()));

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (select 1 from public.admin_users where id = auth.uid());
$$;

grant execute on function public.is_admin() to authenticated;

-- Catalog/config tables: admins get full CRUD on top of the existing
-- public-read policies from 20261015120000_catalog_schema.sql.
create policy "admins can manage service_areas"
on public.service_areas for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage stores"
on public.stores for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage categories"
on public.categories for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage products"
on public.products for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage product_variants"
on public.product_variants for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage inventory"
on public.inventory for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage delivery_slots"
on public.delivery_slots for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage coupons"
on public.coupons for all to authenticated
using (is_admin()) with check (is_admin());

-- Orders: admins can read every order (not just their own, like the
-- existing customer policies), but never write orders/order_items/
-- payments directly - only through admin_update_order_status() below,
-- so the push/Realtime pipeline that depends on order_events can't be
-- bypassed by a raw UPDATE.
create policy "admins can read all orders"
on public.orders for select to authenticated
using (is_admin());

create policy "admins can read all order_items"
on public.order_items for select to authenticated
using (is_admin());

create policy "admins can read all order_events"
on public.order_events for select to authenticated
using (is_admin());

create policy "admins can read all payments"
on public.payments for select to authenticated
using (is_admin());

create policy "admins can read all profiles"
on public.profiles for select to authenticated
using (is_admin());

create policy "admins can read all addresses"
on public.addresses for select to authenticated
using (is_admin());

-- Status updates: one transaction, both the orders.status UPDATE and the
-- order_events INSERT that on_order_event_notify (push) and the
-- supabase_realtime publication (customer app) both depend on.
create or replace function public.admin_update_order_status(
  p_order_id uuid,
  p_new_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Not authorized';
  end if;

  if p_new_status not in ('placed', 'packed', 'out_for_delivery', 'delivered', 'cancelled') then
    raise exception 'Invalid status: %', p_new_status;
  end if;

  update orders set status = p_new_status where id = p_order_id;

  if not found then
    raise exception 'Order not found: %', p_order_id;
  end if;

  insert into order_events (order_id, status) values (p_order_id, p_new_status);
end;
$$;

revoke all on function public.admin_update_order_status(uuid, text) from public, anon;
grant execute on function public.admin_update_order_status(uuid, text) to authenticated;

-- Users list: auth.users.email lives in the protected auth schema and
-- isn't queryable by a normal client even with admin RLS on profiles, so
-- this SECURITY DEFINER function bridges it, gated the same way as
-- every other admin-only RPC here.
create or replace function public.admin_list_users()
returns table (
  id uuid,
  email text,
  phone text,
  full_name text,
  created_at timestamptz
)
language sql
security definer
set search_path = public
stable
as $$
  select p.id, u.email, p.phone, p.full_name, p.created_at
  from public.profiles p
  join auth.users u on u.id = p.id
  where is_admin()
  order by p.created_at desc;
$$;

revoke all on function public.admin_list_users() from public, anon;
grant execute on function public.admin_list_users() to authenticated;

-- Storage: admins can manage catalog images (currently public-read-only,
-- no write policy existed for anyone - see 20261015120400_catalog_images_storage.sql).
create policy "admins can manage catalog images"
on storage.objects for all to authenticated
using (bucket_id = 'catalog-images' and is_admin())
with check (bucket_id = 'catalog-images' and is_admin());
