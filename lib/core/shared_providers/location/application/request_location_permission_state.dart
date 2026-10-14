import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';

part 'request_location_permission_state.freezed.dart';

@freezed
abstract class RequestLocationPermissionState
    with _$RequestLocationPermissionState {
  factory RequestLocationPermissionState({
    LocationPermission? locationPermission,
  }) = _RequestLocationPermissionState;

  factory RequestLocationPermissionState.initial() =>
      RequestLocationPermissionState();
}
