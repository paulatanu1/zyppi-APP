import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:zippy/core/data/service_area_repository_impl.dart';
import 'package:zippy/core/shared_providers/location/provider/request_location_provider.dart';
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

  Future<void>? _inFlight;

  /// Detects the device's position. Pass [requestPermission] when the user
  /// asked for it (the "use current location" button): a denied
  /// permission is then requested again, and a permanently denied one
  /// opens the app's settings. Automatic calls never prompt.
  ///
  /// Concurrent callers share one lookup — startup and the permission
  /// grant listener below can otherwise both fire at once.
  Future<void> getCurrentLocation({bool requestPermission = false}) =>
      _inFlight ??= _detect(requestPermission)
          .whenComplete(() => _inFlight = null);

  Future<void> _detect(bool requestPermission) async {
    state = state.copyWith(isDetecting: true, error: null);

    try {
      // CheckAndRequestLocationProvider owns the permission request, so the
      // whole app sees the new grant.
      if (requestPermission) {
        await ref
            .read(checkAndRequestLocation.notifier)
            .checkAndRequestLocationPermission();
      }
      final permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isDetecting: false,
          checkingServiceability: false,
          serviceabilityChecked: false,
          serviceArea: null,
        );
        if (requestPermission &&
            permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      await resolveLatLng(position.latitude, position.longitude);
    } catch (error) {
      if (!mounted) return;
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
      landmark: null, // belonged to the previous location
      label: null,
      checkingServiceability: true,
      serviceabilityError: false,
      serviceabilityChecked: false,
      error: null,
    );

    try {
      final placemarks = await geocoding.Geocoding().placemarkFromCoordinates(
        lat,
        lng,
      );
      if (!mounted) return;
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
      if (!mounted) return;
      // The coordinates changed; the old address text no longer describes
      // them. Leave the fields empty for the user to type instead.
      state = state.copyWith(
        isDetecting: false,
        address: 'addressNotFound'.tr(),
        line1: '',
        area: '',
        city: '',
        state: '',
        postalCode: '',
        error: error.toString(),
      );
    }

    if (!mounted) return;
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
      landmark: null,
      label: null,
      checkingServiceability: true,
      serviceabilityError: false,
      serviceabilityChecked: false,
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
      landmark: address.landmark,
      label: address.label,
      checkingServiceability: true,
      serviceabilityError: false,
      serviceabilityChecked: false,
      error: null,
    );

    return _checkServiceability(address.lat, address.lng);
  }

  /// Puts back a location captured earlier — the add-address flow uses
  /// this so picking a new address to save doesn't also move the home
  /// screen's delivery location.
  void restore(GetCurrentLocationState snapshot) {
    _checkSeq++; // ignore any check still running for the discarded point
    state = snapshot;
  }

  /// Retries a serviceability check that failed (e.g. offline).
  Future<void> retryServiceability() {
    state = state.copyWith(
      checkingServiceability: true,
      serviceabilityError: false,
      serviceabilityChecked: false,
    );
    return _checkServiceability(state.latitude, state.longitude);
  }

  /// Applies user-edited `line1`/`landmark` text (typed in the confirm
  /// screen in place of the old map-pin visual check) without touching the
  /// resolved coordinates or re-running serviceability.
  void applyEditedText({required String line1, String? landmark}) {
    state = state.copyWith(line1: line1, landmark: landmark);
  }

  /// Only the latest check may write its result: checks for an earlier
  /// point can finish after a newer one.
  int _checkSeq = 0;

  Future<void> _checkServiceability(double lat, double lng) async {
    final seq = ++_checkSeq;
    try {
      final area = await ref
          .read(serviceAreaRepositoryProvider)
          .findServiceableArea(lat, lng);

      if (!mounted || seq != _checkSeq) return;
      state = state.copyWith(
        checkingServiceability: false,
        serviceArea: area,
        serviceabilityChecked: true,
      );
    } catch (_) {
      if (!mounted || seq != _checkSeq) return;
      state = state.copyWith(
        checkingServiceability: false,
        serviceArea: null,
        serviceabilityError: true,
      );
    }
  }
}

final currentLocation =
    StateNotifierProvider.autoDispose<
      GetCurrentLocationProvider,
      GetCurrentLocationState
    >((ref) {
      final notifier = GetCurrentLocationProvider(ref);
      // On first launch the grant arrives after this provider is built;
      // detect again once it does.
      ref.listen(checkAndRequestLocation, (previous, next) {
        if (next == LocationPermission.always ||
            next == LocationPermission.whileInUse) {
          notifier.getCurrentLocation();
        }
      });
      return notifier;
    });
