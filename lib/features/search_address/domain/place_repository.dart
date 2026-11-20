abstract class PlaceRepository {
  /// Raw Google Places Autocomplete JSON (see place_prediction.dart).
  /// [nearLat]/[nearLng] (the map's current point) bias results towards
  /// it, so "youth club" finds the one in this village first.
  Future<Map<String, dynamic>> fetchPlacePredictions(
    String? input, {
    double? nearLat,
    double? nearLng,
  });

  /// Raw Google Places Details JSON (see place_details.dart).
  Future<Map<String, dynamic>> fetchPlaceDetails(String? placeId);
}
