import 'package:cloud_functions/cloud_functions.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:zippy/features/search_address/domain/place_repository.dart';

/// Prefix for predictions that came from the device geocoder instead of
/// Google Places: `geo:<lat>,<lng>`. Picking one resolves the coordinates
/// directly (place_prediction_provider.dart) — there's no Places id.
const devicePlacePrefix = 'geo:';

/// Places autocomplete/details go through the `placesProxy` Cloud Function
/// (Google Places API (New); no Google key in the app; functions/src/places.ts),
/// which already returns the camelCase shape PlacePrediction/PlaceDetails read.
///
/// If Places is unavailable — key not configured, quota, offline — search
/// falls back to the phone's own geocoder (the same keyless one "use
/// current location" uses), so finding an area never just breaks.
class FirebasePlaceRepository implements PlaceRepository {
  final FirebaseFunctions functions;

  FirebasePlaceRepository(this.functions);

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final result = await functions.httpsCallable('placesProxy').call(body);
    return Map<String, dynamic>.from(result.data as Map);
  }

  @override
  Future<Map<String, dynamic>> fetchPlacePredictions(String? input) async {
    final query = input?.trim() ?? '';
    if (query.isEmpty) return {'status': 'ZERO_RESULTS', 'predictions': []};

    try {
      final data = await _call({'action': 'autocomplete', 'input': query});
      final status = data['status'] as String?;
      if (status == 'OK' || status == 'ZERO_RESULTS') return data;
    } catch (_) {
      // Fall through to the device geocoder.
    }

    return _devicePredictions(query);
  }

  @override
  Future<Map<String, dynamic>> fetchPlaceDetails(String? placeId) =>
      _call({'action': 'details', 'placeId': placeId});

  /// Predictions in the same shape as placesProxy's, from the platform
  /// geocoder.
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
        'placeId':
            '$devicePlacePrefix${location.latitude},${location.longitude}',
      });
    }

    return {
      'status': predictions.isEmpty ? 'ZERO_RESULTS' : 'OK',
      'predictions': predictions,
    };
  }
}
