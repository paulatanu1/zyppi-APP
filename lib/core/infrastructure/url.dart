/// The old REST backend is gone (auth moved to Supabase Auth in Phase 3,
/// addresses moved to the `addresses` table) — this only still fronts
/// Google's Places/geocoding APIs, which stay client-side dio calls
/// until Phase 4 moves them behind an Edge Function.
class Url {
  static const googleApi = 'https://maps.googleapis.com/maps/api';
}
