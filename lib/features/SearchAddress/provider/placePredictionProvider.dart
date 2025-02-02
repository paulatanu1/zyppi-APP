import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/constants/googleApiKey.dart';
import 'package:zippy/core/infrastructure/networkApiServices.dart';
import 'package:zippy/core/infrastructure/url.dart';
import 'package:zippy/core/sharedProviders/Location/provider/getCurrentLocationProvider.dart';
import 'package:zippy/core/sharedProviders/networkProvider.dart';
import 'package:zippy/core/utils/log.dart';
import 'package:zippy/core/utils/snackBar.dart';
import 'package:zippy/features/SearchAddress/domain/placeDetails.dart';
import 'package:zippy/features/SearchAddress/domain/placePrediction.dart';
import '../application/placePredictionState.dart';

class PlacePredictionProvider extends StateNotifier<PlacePredictionState> {
  final NetworkApiServices networkApiServices;
  final GetCurrentLocationProvider getCurrentLocationProvider;

  PlacePredictionProvider(
      this.networkApiServices, this.getCurrentLocationProvider)
      : super(PlacePredictionState());

  Future<void> placePrediction({required String? input}) async {
    try {
      var (response, dioException) = await networkApiServices.getApiRequest(
          url: '${Url.googleApi}/place/autocomplete/json?',
          parameters:
              'input=$input&language=en&types=geocode&key=$googleApiKey');

      if (response == null && dioException == null) {
        showConnectionInterrupted();
      } else if (dioException != null) {
        AppLog.showLog(error: dioException.toString());
        showDioError(dioException);
      } else if (response.statusCode > 200 && response.statusCode <= 500) {
        AppLog.showLog(
            tag: 'Prediction Status Code: ${response.statusCode}',
            message: json.encode(response.data));

        showSuccessToast(message: 'Something Went Wrong');
      } else {
        final placePrediction = PlacePrediction.fromJson(response.data);

        state = state.copyWith(placePrediction: placePrediction);

        AppLog.showLog(
            tag: 'Place Prediction', message: json.encode(placePrediction));
      }
    } catch (error, stackTrace) {
      AppLog.showLog(error: error, stackTrace: stackTrace);

      showDioError(error);
    }
  }

  Future<void> placeDetails(
      {required String? placeId, required String? selectedAddress}) async {
    try {
      var (response, dioException) = await networkApiServices.getApiRequest(
          url: '${Url.googleApi}/place/details/json?',
          parameters: 'placeid=$placeId&key=$googleApiKey');

      if (response == null && dioException == null) {
        showConnectionInterrupted();
      } else if (dioException != null) {
        AppLog.showLog(error: dioException.toString());
        showDioError(dioException);
      } else if (response.statusCode > 200 && response.statusCode <= 500) {
        AppLog.showLog(
            tag: 'Prediction Status Code: ${response.statusCode}',
            message: json.encode(response.data));

        showSuccessToast(message: 'Something Went Wrong');
      } else {
        final placeDetails = PlaceDetails.fromJson(response.data);

        state = state.copyWith(
            placeDetails: placeDetails, selectedAddress: selectedAddress);

        getCurrentLocationProvider.state = getCurrentLocationProvider.state
            .copyWith(
                latitude: placeDetails.result?.geometry?.location?.lat ?? 0.0,
                longitude: placeDetails.result?.geometry?.location?.lng ?? 0.0,
                address: selectedAddress);

        AppLog.showLog(
            tag: 'Place Detail', message: json.encode(state.placeDetails));
      }
    } catch (error, stackTrace) {
      AppLog.showLog(error: error, stackTrace: stackTrace);

      showDioError(error);
    }
  }

  Future<void> addAddress(
      {required PlaceDetails? placeDetails,
      required String? selectedAddress}) async {
    try {
      var (response, dioException) = await networkApiServices
          .postAuthenticatedApiRequest(url: Url.addAddress, payload: {
        'street': selectedAddress,
        'city': 'Kolkata',
        'state': 'West Bengal',
        'country': 'India',
        'postalCode': '123456',
        'area': 'Prince Anwar Shah Road',
        'landmark': 'South City',
        'otherAddressType': 'string',
        'addressType': 'others',
        'lat': placeDetails?.result?.geometry?.location?.lat.toString(),
        'lng': placeDetails?.result?.geometry?.location?.lng.toString(),
        'isDefault': true
      });

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
            ref.read(networkProvider), ref.read(currentLocation.notifier)));
