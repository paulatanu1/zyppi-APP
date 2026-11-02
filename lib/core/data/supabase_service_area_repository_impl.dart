import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/data/service_area_repository.dart';
import 'package:zippy/core/domain/service_area.dart';

/// Calls the `serviceable_area(lat, lng)` RPC (see
/// supabase/migrations/20261015120500_service_area_geofence.sql), which
/// does the haversine-vs-radius check in Postgres and returns the nearest
/// match, or no rows if the point is outside every launch area.
class SupabaseServiceAreaRepository implements ServiceAreaRepository {
  final SupabaseClient client;

  SupabaseServiceAreaRepository(this.client);

  @override
  Future<ServiceArea?> findServiceableArea(double lat, double lng) async {
    final result = await client.rpc(
      'serviceable_area',
      params: {'lat': lat, 'lng': lng},
    );
    // The RPC returns a single composite row: outside every area that's
    // a row of nulls (not null), so check the id rather than relying on a
    // cast failing. Tolerate a list shape too.
    final row = switch (result) {
      final List<dynamic> list when list.isNotEmpty =>
        list.first as Map<String, dynamic>,
      final Map<String, dynamic> map => map,
      _ => null,
    };
    if (row == null || row['id'] == null) return null;

    return ServiceArea(
      id: row['id'] as String,
      name: row['name'] as String,
      isActive: row['is_active'] as bool,
      centerLat: (row['center_lat'] as num?)?.toDouble(),
      centerLng: (row['center_lng'] as num?)?.toDouble(),
      radiusMeters: row['radius_meters'] as int?,
    );
  }
}
