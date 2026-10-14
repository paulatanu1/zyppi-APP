import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_current_location_state.freezed.dart';

@freezed
abstract class GetCurrentLocationState with _$GetCurrentLocationState {
  factory GetCurrentLocationState({
    required bool? isDetecting,
    required double? latitude,
    required double? longitude,
    required String? address,
  }) = _GetCurrentLocationState;

  factory GetCurrentLocationState.initial() => GetCurrentLocationState(
    isDetecting: true,
    latitude: 0.0,
    longitude: 0.0,
    address: '',
  );
}
