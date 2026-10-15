-- Phase 4: serviceability needs a geofence per service area so the app can
-- check a device/pin location against the three launch towns. No PostGIS —
-- a plain haversine distance against a center point + radius is plenty for
-- a handful of dark-store catchments.

alter table public.service_areas
  add column center_lat double precision,
  add column center_lng double precision,
  add column radius_meters int check (radius_meters > 0);

-- Approximate town centers (Purulia district, West Bengal); refine against
-- the real dark-store addresses before launch.
update public.service_areas set center_lat = 23.3324, center_lng = 86.3617, radius_meters = 6000
  where name = 'Purulia';
update public.service_areas set center_lat = 23.5667, center_lng = 86.6667, radius_meters = 5000
  where name = 'Raghunathpur';
update public.service_areas set center_lat = 23.4833, center_lng = 86.6333, radius_meters = 4000
  where name = 'Chelyama';

create or replace function public.haversine_meters(
  lat1 double precision, lng1 double precision,
  lat2 double precision, lng2 double precision
) returns double precision
language sql
immutable
parallel safe
as $$
  select 2 * 6371000 * asin(sqrt(
    sin(radians(lat2 - lat1) / 2) ^ 2 +
    cos(radians(lat1)) * cos(radians(lat2)) * sin(radians(lng2 - lng1) / 2) ^ 2
  ));
$$;

-- Returns the nearest serviceable area for a point, or no rows if the point
-- falls outside every active area's radius.
create or replace function public.serviceable_area(lat double precision, lng double precision)
returns public.service_areas
language sql
stable
as $$
  select sa.*
  from public.service_areas sa
  where sa.is_active
    and sa.center_lat is not null
    and sa.center_lng is not null
    and sa.radius_meters is not null
    and public.haversine_meters(lat, lng, sa.center_lat, sa.center_lng) <= sa.radius_meters
  order by public.haversine_meters(lat, lng, sa.center_lat, sa.center_lng) asc
  limit 1;
$$;

grant execute on function public.haversine_meters(double precision, double precision, double precision, double precision) to anon, authenticated;
grant execute on function public.serviceable_area(double precision, double precision) to anon, authenticated;
