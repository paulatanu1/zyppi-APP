import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/infrastructure/network_api_services.dart';
import 'package:zippy/core/infrastructure/url.dart';
import 'package:zippy/core/sharedProviders/Location/domain/get_current_location_model.dart';
import 'package:zippy/core/sharedProviders/network_provider.dart';
import 'package:zippy/core/utils/log.dart';
import 'package:zippy/core/utils/snack_bar.dart';

import '../application/get_current_location_state.dart';

class GetCurrentLocationProvider
    extends StateNotifier<GetCurrentLocationState> {
  final NetworkApiServices networkApiServices;
  GetCurrentLocationProvider(this.networkApiServices)
    : super(GetCurrentLocationState.initial()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isDetecting: true);

    final currentPosition = await Geolocator.getCurrentPosition();

    state = state.copyWith(
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
    );

    await geocodedAddress(state.latitude, state.longitude);

    AppLog.showLog(
      tag: 'Latitude And Longitude',
      message:
          'Latitude: ${state.latitude}, \nLongitude: ${state.longitude}, \nAddress: ${state.address}',
    );
  }

  Future<void> geocodedAddress(double? latitude, double? longitude) async {
    try {
      var (response, dioException) = await networkApiServices.getApiRequest(
        url: Url.googleApi,
        parameters:
            '/geocode/json?latlng=$latitude,$longitude&key=${Env.googleMapsApiKey}',
      );

      state = state.copyWith(isDetecting: false);

      if (response == null && dioException == null) {
        state = state.copyWith(isDetecting: false);
        showConnectionInterrupted();
      } else if (dioException != null) {
        state = state.copyWith(isDetecting: false);

        AppLog.showLog(error: dioException.toString());
        showDioError(dioException);
      } else {
        AppLog.showLog(
          tag: 'Current Location',
          message: json.encode(response.data),
        );

        final currentLocation = CurrentLocationResponse.fromJson(response.data);

        state = state.copyWith(
          address:
              currentLocation.results
                  .where((result) => result.types.contains('premise'))
                  .map((result) => result.formattedAddress)
                  .firstOrNull ??
              currentLocation.results.first.formattedAddress ??
              'Address Not Found',
        );
        state = state.copyWith(isDetecting: false);
      }
    } catch (error, stackTrace) {
      state = state.copyWith(isDetecting: false);

      AppLog.showLog(error: error, stackTrace: stackTrace);

      showDioError(error);
    }
  }
}

final currentLocation =
    StateNotifierProvider.autoDispose<
      GetCurrentLocationProvider,
      GetCurrentLocationState
    >((ref) => GetCurrentLocationProvider(ref.read(networkProvider)));
