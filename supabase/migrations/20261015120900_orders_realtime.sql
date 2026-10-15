-- Phase 4: "Live tracking via Supabase Realtime". orders already has a
-- SELECT RLS policy scoping rows to their own user (see
-- 20261015120200_orders_schema.sql); adding it to the supabase_realtime
-- publication is what lets Postgres Changes actually stream those rows.
alter publication supabase_realtime add table public.orders;
