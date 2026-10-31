-- Edit Profile screen needs these — profiles only had id/phone/full_name
-- (20261015120100_user_schema.sql); RLS already restricts to owner.
alter table public.profiles
  add column email text,
  add column dob date,
  add column gender text;
