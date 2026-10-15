-- Supabase Storage bucket for category/product images (Phase 3). Like
-- the catalog tables, this is read-only for clients — uploads happen
-- from the dashboard, a future admin app, or seed/CI, never from the
-- app itself.

insert into storage.buckets (id, name, public)
values ('catalog-images', 'catalog-images', true)
on conflict (id) do nothing;

create policy "catalog images are publicly readable"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'catalog-images');
