-- Phase 4 follow-up: `alter database ... set app.settings.*` (the
-- original approach in 20261015120800_push_on_order_event.sql) turns
-- out not to be permitted at all on hosted Supabase - not via the CLI,
-- the Management API, or even the dashboard's own SQL editor ("ERROR:
-- 42501: permission denied to set parameter"). That's a platform
-- restriction, not a privileges issue on any particular account.
--
-- Supabase's own intended mechanism for secrets a Postgres function
-- needs is Vault, so notify_order_event() now reads from
-- vault.decrypted_secrets instead of current_setting().
--
-- One-time setup per project (still can't be done from inside a
-- migration - needs the project's own URL and service role key, which
-- differ per environment): run once via the SQL editor or
-- `supabase db query --linked`:
--
--   select vault.create_secret(
--     'https://<project-ref>.supabase.co/functions/v1',
--     'edge_functions_url'
--   );
--   select vault.create_secret(
--     '<service role key, from Project Settings > API Keys > Legacy anon, service_role API keys>',
--     'service_role_key'
--   );
--
-- Until both exist in Vault, the trigger no-ops (logs a warning)
-- instead of failing place_order()'s insert into order_events.

create or replace function public.notify_order_event()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_base_url text;
  v_service_role_key text;
begin
  select decrypted_secret into v_base_url
  from vault.decrypted_secrets where name = 'edge_functions_url';

  select decrypted_secret into v_service_role_key
  from vault.decrypted_secrets where name = 'service_role_key';

  if coalesce(v_base_url, '') = '' or coalesce(v_service_role_key, '') = '' then
    raise warning 'edge_functions_url/service_role_key not set in Vault - skipping push for order_event %', new.id;
    return new;
  end if;

  perform net.http_post(
    url := v_base_url || '/push-on-order-event',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_service_role_key
    ),
    body := jsonb_build_object(
      'orderId', new.order_id,
      'status', new.status
    )
  );

  return new;
end;
$$;
