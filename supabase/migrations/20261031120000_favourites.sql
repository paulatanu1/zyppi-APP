-- Favourites move from device-only Hive to the user's account, so they
-- survive reinstalls and follow the user across devices. Guest
-- (anonymous) users get their own rows too; they're dropped with the
-- auth.users row via the cascade.

create table public.favourites (
  user_id uuid not null references auth.users (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);

-- The PK covers lookups by user_id; this one keeps the products cascade
-- from scanning the whole table.
create index favourites_product_id_idx on public.favourites (product_id);

alter table public.favourites enable row level security;

revoke all on public.favourites from anon;
grant select, insert, delete on public.favourites to authenticated;

create policy "users can read their own favourites"
on public.favourites for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "users can add their own favourites"
on public.favourites for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "users can remove their own favourites"
on public.favourites for delete
to authenticated
using ((select auth.uid()) = user_id);
