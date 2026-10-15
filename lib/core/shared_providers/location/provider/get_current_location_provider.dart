import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:zippy/core/data/service_area_repository_impl.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/utils/parsed_address.dart';
import 'package:zippy/core/utils/snack_bar.dart';

import '../application/get_current_location_state.dart';

/// Resolves a lat/lng into a displayable address (via [geocoding], which
/// uses the platform's own geocoder — no Google API key needed) and checks
/// it against the launch service areas. Shared by "use current location"
/// and the map-pin picker's camera-idle callback.
class GetCurrentLocationProvider
    extends StateNotifier<GetCurrentLocationState> {
  final Ref ref;

  GetCurrentLocationProvider(this.ref)
    : super(GetCurrentLocationState.initial()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isDetecting: true, error: null);

    try {
      final position = await Geolocator.getCurrentPosition();
      await resolveLatLng(position.latitude, position.longitude);
    } catch (error) {
      state = state.copyWith(isDetecting: false, error: error.toString());
      showError(error);
    }
  }

  /// Reverse-geocodes `(lat, lng)` and checks serviceability. Used both for
  /// "use current location" and whenever the map-pin picker's camera
  /// settles on a new center.
  Future<void> resolveLatLng(double lat, double lng) async {
    state = state.copyWith(
      isDetecting: true,
      latitude: lat,
      longitude: lng,
      checkingServiceability: true,
      error: null,
    );

    try {
      final placemarks = await geocoding.Geocoding().placemarkFromCoordinates(
        lat,
        lng,
      );
      final parsed = placemarks.isNotEmpty
          ? ParsedAddress.fromPlacemark(placemarks.first)
          : const ParsedAddress(
              line1: '',
              area: '',
              city: '',
              state: '',
              postalCode: '',
            );

      final formatted = [
        parsed.line1,
        parsed.area,
        parsed.city,
      ].where((part) => part.isNotEmpty).join(', ');

      state = state.copyWith(
        isDetecting: false,
        address: formatted.isNotEmpty ? formatted : 'addressNotFound'.tr(),
        line1: parsed.line1,
        area: parsed.area,
        city: parsed.city,
        state: parsed.state,
        postalCode: parsed.postalCode,
      );
    } catch (error) {
      state = state.copyWith(isDetecting: false, error: error.toString());
    }

    await _checkServiceability(lat, lng);
  }

  /// Sets the resolved location directly from an already-parsed address
  /// (e.g. a Places Details result picked from search) instead of
  /// reverse-geocoding, then runs the same serviceability check.
  Future<void> setResolvedLocation({
    required double lat,
    required double lng,
    required String formattedAddress,
    required ParsedAddress parsed,
  }) async {
    state = state.copyWith(
      isDetecting: false,
      latitude: lat,
      longitude: lng,
      address: formattedAddress,
      line1: parsed.line1,
      area: parsed.area,
      city: parsed.city,
      state: parsed.state,
      postalCode: parsed.postalCode,
      checkingServiceability: true,
      error: null,
    );

    await _checkServiceability(lat, lng);
  }

  /// Jumps straight to a saved address (no geocoding needed, it's already
  /// structured) and re-checks serviceability.
  Future<void> selectSavedAddress(Address address) {
    state = state.copyWith(
      isDetecting: false,
      latitude: address.lat,
      longitude: address.lng,
      address: '${address.line1}, ${address.area}',
      line1: address.line1,
      area: address.area,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      checkingServiceability: true,
      error: null,
    );

    return _checkServiceability(address.lat, address.lng);
  }

  Future<void> _checkServiceability(double lat, double lng) async {
    try {
      final area = await ref
          .read(serviceAreaRepositoryProvider)
          .findServiceableArea(lat, lng);

      state = state.copyWith(checkingServiceability: false, serviceArea: area);
    } catch (_) {
      state = state.copyWith(checkingServiceability: false, serviceArea: null);
    }
  }
}

final currentLocation =
    StateNotifierProvider.autoDispose<
      GetCurrentLocationProvider,
      GetCurrentLocationState
    >((ref) => GetCurrentLocationProvider(ref));
