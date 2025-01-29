import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../application/checkLocationState.dart';

class CheckLocationPermissionProvider
    extends StateNotifier<CheckLocationState> {
  CheckLocationPermissionProvider() : super(CheckLocationState()) {
    checkLocationService();
  }

  Future<void> checkLocationService() async {
    state =
        state.copyWith(isEnabled: await Geolocator.isLocationServiceEnabled());
    log('Permission Status: ${state.isEnabled}');
  }
}

final checkLocationPermission = StateNotifierProvider.autoDispose<
    CheckLocationPermissionProvider,
    CheckLocationState>((ref) => CheckLocationPermissionProvider());
