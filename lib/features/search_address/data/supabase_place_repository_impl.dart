import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/features/search_address/domain/place_repository.dart';

/// Prefix for predictions that came from the device geocoder instead of
/// Google Places: `geo:<lat>,<lng>`. Picking one resolves the coordinates
/// directly (place_prediction_provider.dart) — there's no Places id.
const devicePlacePrefix = 'geo:';

/// Places autocomplete/details go through the `places-proxy` Edge Function
/// (no client-side Google key; supabase/functions/places-proxy/index.ts).
///
/// If Places is unavailable — key not configured, quota, offline proxy —
/// search falls back to the phone's own geocoder (the same keyless one
/// "use current location" uses), so finding an area never just breaks.
class SupabasePlaceRepository implements PlaceRepository {
  final SupabaseClient client;

  SupabasePlaceRepository(this.client);

  @override
  Future<Map<String, dynamic>> fetchPlacePredictions(String? input) async {
    final query = input?.trim() ?? '';
    if (query.isEmpty) return {'status': 'ZERO_RESULTS', 'predictions': []};

    try {
      final response = await client.functions.invoke(
        'places-proxy',
        body: {'action': 'autocomplete', 'input': query},
      );
      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String?;
      if (status == 'OK' || status == 'ZERO_RESULTS') return data;
    } catch (_) {
      // Fall through to the device geocoder.
    }

    return _devicePredictions(query);
  }

  @override
  Future<Map<String, dynamic>> fetchPlaceDetails(String? placeId) async {
    final response = await client.functions.invoke(
      'places-proxy',
      body: {'action': 'details', 'placeId': placeId},
    );

    return response.data as Map<String, dynamic>;
  }

  /// Google-shaped predictions from the platform geocoder.
  Future<Map<String, dynamic>> _devicePredictions(String query) async {
    final geocoder = geocoding.Geocoding();
    final List<geocoding.Location> locations;
    try {
      locations = await geocoder.locationFromAddress(query);
    } catch (_) {
      // "No result found" is thrown as an exception by the plugin.
      return {'status': 'ZERO_RESULTS', 'predictions': []};
    }

    final predictions = <Map<String, dynamic>>[];
    for (final location in locations.take(5)) {
      var description = query;
      try {
        final marks = await geocoder.placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (marks.isNotEmpty) {
          final m = marks.first;
          final parts = {
            m.name,
            m.subLocality,
            m.locality,
            m.administrativeArea,
          }.whereType<String>().where((p) => p.trim().isNotEmpty);
          if (parts.isNotEmpty) description = parts.join(', ');
        }
      } catch (_) {}

      predictions.add({
        'description': description,
        'place_id':
            '$devicePlacePrefix${location.latitude},${location.longitude}',
      });
    }

    return {
      'status': predictions.isEmpty ? 'ZERO_RESULTS' : 'OK',
      'predictions': predictions,
    };
  }
}
