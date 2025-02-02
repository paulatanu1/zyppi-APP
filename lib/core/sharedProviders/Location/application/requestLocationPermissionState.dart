import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';

part 'requestLocationPermissionState.freezed.dart';

@freezed
class RequestLocationPermissionState with _$RequestLocationPermissionState {
  factory RequestLocationPermissionState({
     LocationPermission? locationPermission
  }) = _RequestLocationPermissionState;
  
  factory RequestLocationPermissionState.initial() => RequestLocationPermissionState();
}