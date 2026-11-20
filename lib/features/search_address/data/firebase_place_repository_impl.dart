import 'package:cloud_functions/cloud_functions.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:zippy/core/firebase/report_error.dart';
import 'package:zippy/core/utils/parsed_address.dart';
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

  /// Reported once per app run: why search fell back to the phone's
  /// geocoder (missing GOOGLE_PLACES_API_KEY secret, Places switched off in
  /// the admin, quota). The fallback can't find schools, clubs or shops.
  static bool _fallbackReported = false;

  @override
  Future<Map<String, dynamic>> fetchPlacePredictions(
    String? input, {
    double? nearLat,
    double? nearLng,
  }) async {
    final query = input?.trim() ?? '';
    if (query.isEmpty) return {'status': 'ZERO_RESULTS', 'predictions': []};

    try {
      final data = await _call({
        'action': 'autocomplete',
        'input': query,
        if (nearLat != null &&
            nearLng != null &&
            (nearLat != 0 || nearLng != 0))
          'near': {'lat': nearLat, 'lng': nearLng},
      });
      final status = data['status'] as String?;
      if (status == 'OK' || status == 'ZERO_RESULTS') return data;
      _reportFallback(
        StateError(
          'placesProxy status $status'
          '${data['disabled'] == true ? ' (switched off in Settings)' : ''}',
        ),
        StackTrace.current,
      );
    } catch (e, s) {
      _reportFallback(e, s);
    }

    return _devicePredictions(query);
  }

  void _reportFallback(Object e, StackTrace s) {
    if (_fallbackReported) return;
    _fallbackReported = true;
    reportNonFatal(e, s, reason: 'places search fell back to the geocoder');
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

    // The geocoder doesn't know points of interest: "Chelyama girls
    // school" and "Chelyama youth club" land on the same village point.
    // Keep what was typed as the main text (it becomes address line 1),
    // never a plus code, and list each point once.
    final predictions = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final location in locations.take(5)) {
      final placeId =
          '$devicePlacePrefix${location.latitude.toStringAsFixed(5)},'
          '${location.longitude.toStringAsFixed(5)}';
      if (!seen.add(placeId)) continue;
      var secondary = '';
      try {
        final marks = await geocoder.placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (marks.isNotEmpty) {
          final m = marks.first;
          secondary = {m.subLocality, m.locality, m.administrativeArea}
              .whereType<String>()
              .where((p) => p.trim().isNotEmpty && !isPlusCode(p))
              .join(', ');
        }
      } catch (_) {}

      predictions.add({
        'description': secondary.isEmpty ? query : '$query, $secondary',
        'placeId': placeId,
        'structuredFormatting': {'mainText': query, 'secondaryText': secondary},
      });
    }

    return {
      'status': predictions.isEmpty ? 'ZERO_RESULTS' : 'OK',
      'predictions': predictions,
    };
  }
}
