-- Phase 4: push-on-order-event (supabase/functions/push-on-order-event)
-- looks the device token up here to notify whoever placed the order.
alter table public.profiles
  add column fcm_token text;
