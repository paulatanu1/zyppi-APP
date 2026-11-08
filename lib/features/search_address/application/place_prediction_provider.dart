import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/utils/parsed_address.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/search_address/data/place_repository_impl.dart';
import 'package:zippy/features/search_address/data/firebase_place_repository_impl.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';
import 'package:zippy/features/search_address/domain/place_prediction.dart';

import 'place_prediction_state.dart';

class PlacePredictionProvider extends StateNotifier<PlacePredictionState> {
  final Ref ref;

  PlacePredictionProvider(this.ref) : super(PlacePredictionState());

  static const _debounce = Duration(milliseconds: 300);
  Timer? _timer;
  int _requestId = 0;

  /// Debounced Places search: one request after the user pauses typing
  /// (each call costs a placesProxy Cloud Function invocation), and only
  /// the latest query's results are ever shown.
  void placePrediction({required String? input}) {
    _timer?.cancel();
    final query = input?.trim() ?? '';
    final requestId = ++_requestId;

    if (query.isEmpty) {
      state = state.copyWith(placePrediction: null);
      return;
    }

    _timer = Timer(_debounce, () async {
      try {
        final json = await ref
            .read(placeRepositoryProvider)
            .fetchPlacePredictions(query);
        if (!mounted || requestId != _requestId) return;
        state = state.copyWith(placePrediction: PlacePrediction.fromJson(json));
      } catch (error) {
        if (requestId == _requestId) showError(error);
      }
    });
  }

  Future<void> placeDetails({
    required String? placeId,
    required String? selectedAddress,
  }) async {
    _timer?.cancel();
    _requestId++; // drop any search still in flight
    state = state.copyWith(placePrediction: null);

    // A device-geocoder result already carries its coordinates; resolve
    // them (reverse-geocode + serviceability) instead of asking Places.
    if (placeId != null && placeId.startsWith(devicePlacePrefix)) {
      final parts = placeId.substring(devicePlacePrefix.length).split(',');
      final lat = double.tryParse(parts.first);
      final lng = parts.length > 1 ? double.tryParse(parts[1]) : null;
      if (lat != null && lng != null) {
        state = state.copyWith(selectedAddress: selectedAddress);
        await ref.read(currentLocation.notifier).resolveLatLng(lat, lng);
      }
      return;
    }

    try {
      final json = await ref
          .read(placeRepositoryProvider)
          .fetchPlaceDetails(placeId);
      if (!mounted) return;
      final placeDetails = PlaceDetails.fromJson(json);
      final location = placeDetails.result?.geometry?.location;

      state = state.copyWith(
        placeDetails: placeDetails,
        selectedAddress: selectedAddress,
      );

      if (location?.lat != null && location?.lng != null) {
        final parsed = ParsedAddress.fromGoogleComponents(
          placeDetails.result?.addressComponents ?? const [],
          fallbackLine1: selectedAddress ?? '',
        );

        await ref
            .read(currentLocation.notifier)
            .setResolvedLocation(
              lat: location!.lat!,
              lng: location.lng!,
              formattedAddress:
                  placeDetails.result?.formattedAddress ??
                  selectedAddress ??
                  '',
              parsed: parsed,
            );
      }
    } catch (error) {
      showError(error);
    }
  }

  /// Saves the currently-resolved [currentLocation] as a new address.
  /// Returns whether it was saved, so the screen only closes on success
  /// (and keeps the user's input otherwise).
  Future<bool> addAddress({required String label}) async {
    final location = ref.read(currentLocation);
    final line1 =
        (location.line1.isNotEmpty ? location.line1 : location.address).trim();
    final serviceArea = location.serviceArea;

    // Never save a placeholder like "Address not found" as a real address.
    if (line1.isEmpty || line1 == 'addressNotFound'.tr()) {
      showError('enterAddressLine'.tr());
      return false;
    }
    if (serviceArea == null) {
      showError('notServiceableYet'.tr());
      return false;
    }

    try {
      await ref
          .read(addressRepositoryProvider)
          .addAddress(
            Address(
              id: 'address-${DateTime.now().millisecondsSinceEpoch}',
              label: label,
              line1: line1,
              area: location.area,
              city: location.city,
              state: location.state,
              postalCode: location.postalCode,
              landmark: location.landmark,
              lat: location.latitude,
              lng: location.longitude,
              isDefault: false,
            ),
            // The area the check actually matched, not "any active area".
            serviceAreaId: serviceArea.id,
          );
    } catch (error) {
      showError(error);
      return false;
    }

    // My Address and checkout's address list refresh with the new one.
    ref.invalidate(addressesProvider);
    showSuccessToast(message: 'addressAddedSuccessfully'.tr());
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final placePredictionProvider =
    StateNotifierProvider<PlacePredictionProvider, PlacePredictionState>(
      (ref) => PlacePredictionProvider(ref),
    );
