-- Backend/admin-driven Home screen sections (Blinkit-referenced redesign).
-- A section's `type` picks which Flutter widget renders it
-- (lib/features/home_screen/widgets/sections/); each item's `data` is
-- free-form JSONB so admin isn't locked into a fixed field set per type -
-- see docs/PLAN.md's note on this being a typed-section/flexible-item
-- model rather than a full page-builder.

create table public.home_sections (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  title text,
  subtitle text,
  display_order int not null default 0,
  is_active boolean not null default true,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.home_section_items (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references public.home_sections (id) on delete cascade,
  display_order int not null default 0,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index home_section_items_section_id_idx on public.home_section_items (section_id);

alter table public.home_sections enable row level security;
alter table public.home_section_items enable row level security;

create policy "anyone can read active home sections"
on public.home_sections for select
using (is_active);

create policy "anyone can read items of an active home section"
on public.home_section_items for select
using (
  exists (
    select 1 from public.home_sections hs
    where hs.id = home_section_items.section_id and hs.is_active
  )
);

-- Admins get full CRUD (same is_admin() gate as every other admin policy -
-- 20261016010000_admin_panel.sql); "for all" covers select too, so this
-- also lets admins read inactive/draft sections the public policy hides.
create policy "admins can manage home sections"
on public.home_sections for all to authenticated
using (is_admin()) with check (is_admin());

create policy "admins can manage home section items"
on public.home_section_items for all to authenticated
using (is_admin()) with check (is_admin());
