-- Postgres full-text search for product search (Phase 3, PLAN.md §3
-- screen 8). A generated column keeps the tsvector in sync with `name`
-- automatically; the GIN index makes `textSearch()` queries fast.

alter table public.products
  add column search_vector tsvector
    generated always as (to_tsvector('english', name)) stored;

create index products_search_vector_idx
  on public.products using gin (search_vector);
