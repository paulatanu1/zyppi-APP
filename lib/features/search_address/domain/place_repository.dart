abstract class PlaceRepository {
  /// Raw Google Places Autocomplete JSON (see place_prediction.dart).
  Future<Map<String, dynamic>> fetchPlacePredictions(String? input);

  /// Raw Google Places Details JSON (see place_details.dart).
  Future<Map<String, dynamic>> fetchPlaceDetails(String? placeId);
}
