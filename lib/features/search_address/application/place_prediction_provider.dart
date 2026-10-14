import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
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
  final GetCurrentLocationProvider getCurrentLocationProvider;

  PlacePredictionProvider(this.repository, this.getCurrentLocationProvider)
    : super(PlacePredictionState());

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
      var (response, dioException) = await repository.addAddress(
        placeDetails: placeDetails,
        selectedAddress: selectedAddress,
      );

      if (response == null && dioException == null) {
        showConnectionInterrupted();
      } else if (dioException != null) {
        AppLog.showLog(error: dioException.toString());
        showDioError(dioException);
      } else {
        final addAddressSuccess = json.encode(response.data);

        AppLog.showLog(tag: 'Add Address', message: addAddressSuccess);

        showSuccessToast(message: 'Address Added Successfully');
      }
    } catch (error, stackTrace) {
      AppLog.showLog(error: error, stackTrace: stackTrace);

      showDioError(error);
    }
  }
}

final placePredictionProvider =
    StateNotifierProvider<PlacePredictionProvider, PlacePredictionState>(
      (ref) => PlacePredictionProvider(
        ref.read(placeRepositoryProvider),
        ref.read(currentLocation.notifier),
      ),
    );
