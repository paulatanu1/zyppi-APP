import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// Requests location permission once at app start (see bootstrap.dart);
/// the map-pin picker re-checks and re-requests on its own if the user
/// denied it here and later wants "use current location".
class CheckAndRequestLocationProvider
    extends StateNotifier<LocationPermission> {
  CheckAndRequestLocationProvider()
    : super(LocationPermission.unableToDetermine) {
    checkAndRequestLocationPermission();
  }

  Future<void> checkAndRequestLocationPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      showSuccessToast(message: 'locationPermissionRequired'.tr());
    }

    state = permission;
  }
}

final checkAndRequestLocation =
    StateNotifierProvider<CheckAndRequestLocationProvider, LocationPermission>(
      (ref) => CheckAndRequestLocationProvider(),
    );
