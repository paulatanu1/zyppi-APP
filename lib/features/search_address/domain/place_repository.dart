import 'package:dio/dio.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';

abstract class PlaceRepository {
  Future<(dynamic, DioException?)> fetchPlacePredictions(String? input);

  Future<(dynamic, DioException?)> fetchPlaceDetails(String? placeId);

  Future<(dynamic, DioException?)> addAddress({
    required PlaceDetails? placeDetails,
    required String? selectedAddress,
  });
}
