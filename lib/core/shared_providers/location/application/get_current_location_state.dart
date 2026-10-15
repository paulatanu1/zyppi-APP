import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/service_area.dart';

part 'get_current_location_state.freezed.dart';

@freezed
abstract class GetCurrentLocationState with _$GetCurrentLocationState {
  factory GetCurrentLocationState({
    required bool isDetecting,
    required double latitude,
    required double longitude,
    required String address,
    @Default('') String line1,
    @Default('') String area,
    @Default('') String city,
    @Default('') String state,
    @Default('') String postalCode,
    @Default(false) bool checkingServiceability,
    ServiceArea? serviceArea,
    String? error,
  }) = _GetCurrentLocationState;

  factory GetCurrentLocationState.initial() => GetCurrentLocationState(
    isDetecting: true,
    latitude: 0.0,
    longitude: 0.0,
    address: '',
  );
}
