import 'package:dio/dio.dart';

abstract class PlaceRepository {
  Future<(dynamic, DioException?)> fetchPlacePredictions(String? input);

  Future<(dynamic, DioException?)> fetchPlaceDetails(String? placeId);
}
