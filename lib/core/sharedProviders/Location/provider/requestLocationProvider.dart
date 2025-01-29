import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zippy/core/utils/snackBar.dart';

class CheckAndRequestLocationProvider
    extends StateNotifier<LocationPermission> {
  CheckAndRequestLocationProvider()
      : super(LocationPermission.unableToDetermine) {
    checkAndRequestLocationPermission();
  }

  Future<void> checkAndRequestLocationPermission() async {
    log('Clicked');

    LocationPermission locationPermission = await Geolocator.checkPermission();

    log(locationPermission.name);

    log('Clicked 2');

    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      locationPermission = await Geolocator.requestPermission();
    }

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();

      showSuccessToast(message: 'locationPermissionRequired'.tr());
    } else if (locationPermission == LocationPermission.deniedForever) {
      locationPermission = await Geolocator.requestPermission();

      showSuccessToast(message: 'locationPermissionRequired'.tr());
    }
  }
}

final checkAndRequestLocation =
    StateNotifierProvider<CheckAndRequestLocationProvider, LocationPermission>(
        (ref) => CheckAndRequestLocationProvider());
