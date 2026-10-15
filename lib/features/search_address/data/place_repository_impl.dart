import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/infrastructure/network_api_services.dart';
import 'package:zippy/core/infrastructure/url.dart';
import 'package:zippy/core/shared_providers/network_provider.dart';
import 'package:zippy/features/search_address/domain/place_repository.dart';

// Phase 1 keeps the existing Google Places calls behind this interface;
// Phase 4 swaps the implementation to an Edge Function (no client Maps
// key for Places).
class PlaceRepositoryImpl implements PlaceRepository {
  final NetworkApiServices networkApiServices;

  PlaceRepositoryImpl(this.networkApiServices);

  @override
  Future<(dynamic, DioException?)> fetchPlacePredictions(String? input) {
    return networkApiServices.getApiRequest(
      url: '${Url.googleApi}/place/autocomplete/json?',
      parameters:
          'input=$input&language=en&types=geocode&key=${Env.googleMapsApiKey}',
    );
  }

  @override
  Future<(dynamic, DioException?)> fetchPlaceDetails(String? placeId) {
    return networkApiServices.getApiRequest(
      url: '${Url.googleApi}/place/details/json?',
      parameters: 'placeid=$placeId&key=${Env.googleMapsApiKey}',
    );
  }
}

final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => PlaceRepositoryImpl(ref.read(networkProvider)),
);
