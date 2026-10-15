import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/utils/parsed_address.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/search_address/data/place_repository_impl.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';
import 'package:zippy/features/search_address/domain/place_prediction.dart';

import 'place_prediction_state.dart';

class PlacePredictionProvider extends StateNotifier<PlacePredictionState> {
  final Ref ref;

  PlacePredictionProvider(this.ref) : super(PlacePredictionState());

  Future<void> placePrediction({required String? input}) async {
    try {
      final json = await ref
          .read(placeRepositoryProvider)
          .fetchPlacePredictions(input);

      state = state.copyWith(placePrediction: PlacePrediction.fromJson(json));
    } catch (error) {
      showError(error);
    }
  }

  Future<void> placeDetails({
    required String? placeId,
    required String? selectedAddress,
  }) async {
    try {
      final json = await ref
          .read(placeRepositoryProvider)
          .fetchPlaceDetails(placeId);
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

  /// Saves the currently-resolved [currentLocation] (either the map-pin
  /// picker's center or a search result) as a new address.
  Future<void> addAddress({required String label}) async {
    final location = ref.read(currentLocation);

    try {
      await ref
          .read(addressRepositoryProvider)
          .addAddress(
            Address(
              id: 'address-${DateTime.now().millisecondsSinceEpoch}',
              label: label,
              line1: location.line1.isNotEmpty
                  ? location.line1
                  : location.address,
              area: location.area,
              city: location.city,
              state: location.state,
              postalCode: location.postalCode,
              lat: location.latitude,
              lng: location.longitude,
              isDefault: false,
            ),
          );

      showSuccessToast(message: 'addressAddedSuccessfully'.tr());
    } catch (error) {
      showError(error);
    }
  }
}

final placePredictionProvider =
    StateNotifierProvider<PlacePredictionProvider, PlacePredictionState>(
      (ref) => PlacePredictionProvider(ref),
    );
