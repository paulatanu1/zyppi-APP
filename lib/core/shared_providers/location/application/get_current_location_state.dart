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
    String? landmark,

    /// The saved address's label ('Home', 'Work', 'Other') when one was
    /// picked; null for a GPS or searched location.
    String? label,
    @Default(false) bool checkingServiceability,
    ServiceArea? serviceArea,

    /// The serviceability check itself failed (offline…), as opposed to
    /// "checked: we don't deliver here".
    @Default(false) bool serviceabilityError,

    /// A serviceability check has completed for the current point. Until
    /// then (no permission, nothing picked yet) [serviceArea] being null
    /// means "unknown", not "we don't deliver here".
    @Default(false) bool serviceabilityChecked,
    String? error,
  }) = _GetCurrentLocationState;

  factory GetCurrentLocationState.initial() => GetCurrentLocationState(
    isDetecting: true,
    latitude: 0.0,
    longitude: 0.0,
    address: '',
  );
}
