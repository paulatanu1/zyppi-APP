-- Account settings, rider details, product descriptions, default address.

-- ---------------------------------------------------------------------------
-- Profile preferences (Account → Payment settings / Notification preferences)
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column preferred_payment_method text
    check (preferred_payment_method in ('UPI', 'Credit or debit card', 'Cash on delivery')),
  add column notify_order_updates boolean not null default true,
  add column notify_offers boolean not null default false;

-- Light sanity checks for the edit-profile form; NOT VALID so any existing
-- rows don't block the migration (new writes are still checked).
alter table public.profiles
  add constraint profiles_email_format
    check (email is null or email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$') not valid,
  add constraint profiles_gender_values
    check (gender is null or gender in ('male', 'female', 'other')) not valid;

-- ---------------------------------------------------------------------------
-- Rider details on orders (tracking screen's name + call button)
-- ---------------------------------------------------------------------------

alter table public.orders
  add column rider_name text,
  add column rider_phone text;

-- Same function, optional rider details. Dropped first because adding
-- parameters changes the signature.
drop function if exists public.admin_update_order_status(uuid, text);

create function public.admin_update_order_status(
  p_order_id uuid,
  p_new_status text,
  p_rider_name text default null,
  p_rider_phone text default null
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

  update orders
  set status = p_new_status,
      rider_name = coalesce(p_rider_name, rider_name),
      rider_phone = coalesce(p_rider_phone, rider_phone)
  where id = p_order_id;

  if not found then
    raise exception 'Order not found: %', p_order_id;
  end if;

  insert into order_events (order_id, status) values (p_order_id, p_new_status);
end;
$$;

revoke all on function public.admin_update_order_status(uuid, text, text, text) from public, anon;
grant execute on function public.admin_update_order_status(uuid, text, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Product descriptions (product details' "About this item")
-- ---------------------------------------------------------------------------

alter table public.products add column description text;

-- ---------------------------------------------------------------------------
-- One default address per user
-- ---------------------------------------------------------------------------

-- Keep only the most recent default if a user somehow has several.
update public.addresses a
set is_default = false
where a.is_default
  and exists (
    select 1 from public.addresses b
    where b.user_id = a.user_id and b.is_default
      and (b.created_at, b.id) > (a.created_at, a.id)
  );

create unique index addresses_one_default_per_user
  on public.addresses (user_id)
  where is_default;

-- Moves the default flag atomically (two separate client updates could
-- leave zero or two defaults). Runs as the caller, so RLS applies.
create function public.set_default_address(p_address_id uuid)
returns void
language sql
security invoker
set search_path = public
as $$
  update addresses set is_default = false
  where user_id = (select auth.uid()) and is_default and id <> p_address_id;

  update addresses set is_default = true
  where user_id = (select auth.uid()) and id = p_address_id;
$$;

revoke all on function public.set_default_address(uuid) from public, anon;
grant execute on function public.set_default_address(uuid) to authenticated;
