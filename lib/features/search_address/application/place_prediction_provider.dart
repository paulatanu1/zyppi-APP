import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/address_repository.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/utils/log.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/search_address/data/place_repository_impl.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';
import 'package:zippy/features/search_address/domain/place_prediction.dart';
import 'package:zippy/features/search_address/domain/place_repository.dart';

import 'place_prediction_state.dart';

class PlacePredictionProvider extends StateNotifier<PlacePredictionState> {
  final PlaceRepository repository;
  final AddressRepository addressRepository;
  final GetCurrentLocationProvider getCurrentLocationProvider;

  PlacePredictionProvider(
    this.repository,
    this.addressRepository,
    this.getCurrentLocationProvider,
  ) : super(PlacePredictionState());

  Future<void> placePrediction({required String? input}) async {
    try {
      var (response, dioException) = await repository.fetchPlacePredictions(
        input,
      );

      if (response == null && dioException == null) {
        showConnectionInterrupted();
      } else if (dioException != null) {
        AppLog.showLog(error: dioException.toString());
        showDioError(dioException);
      } else if (response.statusCode > 200 && response.statusCode <= 500) {
        AppLog.showLog(
          tag: 'Prediction Status Code: ${response.statusCode}',
          message: json.encode(response.data),
        );

        showSuccessToast(message: 'Something Went Wrong');
      } else {
        final placePrediction = PlacePrediction.fromJson(response.data);

        state = state.copyWith(placePrediction: placePrediction);

        AppLog.showLog(
          tag: 'Place Prediction',
          message: json.encode(placePrediction),
        );
      }
    } catch (error, stackTrace) {
      AppLog.showLog(error: error, stackTrace: stackTrace);

      showDioError(error);
    }
  }

  Future<void> placeDetails({
    required String? placeId,
    required String? selectedAddress,
  }) async {
    try {
      var (response, dioException) = await repository.fetchPlaceDetails(
        placeId,
      );

      if (response == null && dioException == null) {
        showConnectionInterrupted();
      } else if (dioException != null) {
        AppLog.showLog(error: dioException.toString());
        showDioError(dioException);
      } else if (response.statusCode > 200 && response.statusCode <= 500) {
        AppLog.showLog(
          tag: 'Prediction Status Code: ${response.statusCode}',
          message: json.encode(response.data),
        );

        showSuccessToast(message: 'Something Went Wrong');
      } else {
        final placeDetails = PlaceDetails.fromJson(response.data);

        state = state.copyWith(
          placeDetails: placeDetails,
          selectedAddress: selectedAddress,
        );

        getCurrentLocationProvider.state = getCurrentLocationProvider.state
            .copyWith(
              latitude: placeDetails.result?.geometry?.location?.lat ?? 0.0,
              longitude: placeDetails.result?.geometry?.location?.lng ?? 0.0,
              address: selectedAddress,
            );

        AppLog.showLog(
          tag: 'Place Detail',
          message: json.encode(state.placeDetails),
        );
      }
    } catch (error, stackTrace) {
      AppLog.showLog(error: error, stackTrace: stackTrace);

      showDioError(error);
    }
  }

  Future<void> addAddress({
    required PlaceDetails? placeDetails,
    required String? selectedAddress,
  }) async {
    try {
      // The map-pin picker and address-component parsing are Phase 4
      // work (needs google_maps_flutter); these placeholders match what
      // the old REST payload hardcoded for every address added here.
      await addressRepository.addAddress(
        Address(
          id: 'address-${DateTime.now().millisecondsSinceEpoch}',
          label: 'Other',
          line1: selectedAddress ?? 'Unknown address',
          area: 'Prince Anwar Shah Road',
          city: 'Kolkata',
          state: 'West Bengal',
          postalCode: '123456',
          landmark: 'South City',
          lat: placeDetails?.result?.geometry?.location?.lat ?? 0.0,
          lng: placeDetails?.result?.geometry?.location?.lng ?? 0.0,
          isDefault: true,
        ),
      );

      AppLog.showLog(tag: 'Add Address', message: 'Address added');

      showSuccessToast(message: 'Address Added Successfully');
    } catch (error, stackTrace) {
      AppLog.showLog(error: error, stackTrace: stackTrace);

      showError(error);
    }
  }
}

final placePredictionProvider =
    StateNotifierProvider<PlacePredictionProvider, PlacePredictionState>(
      (ref) => PlacePredictionProvider(
        ref.read(placeRepositoryProvider),
        ref.read(addressRepositoryProvider),
        ref.read(currentLocation.notifier),
      ),
    );
