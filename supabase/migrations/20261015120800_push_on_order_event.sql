-- Phase 4: "FCM push on order_events insert (Edge Function)". Rather than
-- a dashboard-configured Database Webhook (not version-controlled), this
-- installs the same trigger mechanism the dashboard's webhook UI
-- generates under the hood: supabase_functions.http_request(), which
-- every Supabase project ships pre-installed.
--
-- One-time setup per project (this can't be done from inside a
-- migration - it needs the project's own URL and service role key,
-- which differ per environment): run once against each project
-- (dev/staging/prod) via the SQL editor or `supabase db execute`:
--
--   alter database postgres
--     set app.settings.edge_functions_url = 'https://<project-ref>.supabase.co/functions/v1';
--   alter database postgres
--     set app.settings.service_role_key = '<service role key, from Project Settings > API>';
--
-- Until both are set, the trigger below no-ops (logs a warning) instead
-- of failing place_order()'s insert into order_events.

create extension if not exists pg_net;

create or replace function public.notify_order_event()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_base_url text := current_setting('app.settings.edge_functions_url', true);
  v_service_role_key text := current_setting('app.settings.service_role_key', true);
begin
  if coalesce(v_base_url, '') = '' or coalesce(v_service_role_key, '') = '' then
    raise warning 'app.settings.edge_functions_url/service_role_key not set - skipping push for order_event %', new.id;
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

create trigger on_order_event_notify
  after insert on public.order_events
  for each row
  execute function public.notify_order_event();
