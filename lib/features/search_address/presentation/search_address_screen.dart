import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/my_address/application/addresses_provider.dart';
import 'package:zippy/features/search_address/application/place_prediction_provider.dart';
import 'package:zippy/features/search_address/domain/place_prediction.dart';

/// docs/mockups/Location.dc.html: a full-screen map-pin picker. The pin
/// stays centered; dragging the map re-geocodes whatever is under it.
/// `addLocation == true` means "save this as a new address" (reached from
/// MyAddressScreen's "Add new address"); `false` just picks a location for
/// the home screen's delivery context (reached from the header/search bar).
class SearchAddressScreen extends ConsumerStatefulWidget {
  final bool addLocation;

  const SearchAddressScreen({super.key, required this.addLocation});

  @override
  ConsumerState<SearchAddressScreen> createState() =>
      _SearchAddressScreenState();
}

class _SearchAddressScreenState extends ConsumerState<SearchAddressScreen> {
  final _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _lastCameraTarget = _defaultCenter;
  String _label = 'Home';

  static const _defaultCenter = LatLng(23.3324, 86.3617); // Purulia

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(currentLocation);
    final predictions =
        ref.watch(placePredictionProvider).placePrediction?.predictions ??
        const [];

    ref.listen(currentLocation, (previous, next) {
      final moved =
          previous?.latitude != next.latitude ||
          previous?.longitude != next.longitude;
      if (moved && !next.isDetecting) {
        final target = LatLng(next.latitude, next.longitude);
        _lastCameraTarget = target;
        _mapController?.animateCamera(CameraUpdate.newLatLng(target));
      }
    });

    final initialTarget = location.latitude == 0.0 && location.longitude == 0.0
        ? _defaultCenter
        : LatLng(location.latitude, location.longitude);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 16,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) => _lastCameraTarget = position.target,
            onCameraIdle: () => ref
                .read(currentLocation.notifier)
                .resolveLatLng(
                  _lastCameraTarget.latitude,
                  _lastCameraTarget.longitude,
                ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          const IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.location_pin,
                size: 44,
                color: AppColors.primary,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xxl,
            child: _SearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
                ref
                    .read(placePredictionProvider.notifier)
                    .placePrediction(input: value);
              },
              onBack: () => context.pop(),
            ),
          ),
          if (predictions.isNotEmpty && _searchController.text.isNotEmpty)
            Positioned(
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              top: 72,
              child: _PredictionsList(
                predictions: predictions,
                onSelected: (prediction) async {
                  _searchController.clear();
                  await ref
                      .read(placePredictionProvider.notifier)
                      .placeDetails(
                        placeId: prediction.placeId,
                        selectedAddress: prediction.description,
                      );
                  setState(() {});
                },
              ),
            ),
          Positioned(
            right: AppSpacing.xxl,
            top: 220,
            child: _CurrentLocationButton(
              onPressed: () =>
                  ref.read(currentLocation.notifier).getCurrentLocation(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ConfirmSheet(
              addLocation: widget.addLocation,
              label: _label,
              onLabelChanged: (value) => setState(() => _label = value),
              onConfirm: () async {
                if (widget.addLocation) {
                  await ref
                      .read(placePredictionProvider.notifier)
                      .addAddress(label: _label);
                }
                if (context.mounted) context.pop();
              },
              onSavedAddressTap: (address) async {
                await ref
                    .read(currentLocation.notifier)
                    .selectSavedAddress(address);
                if (context.mounted) context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.inputMin,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A17201B),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.muted),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'searchAreaPlaceholder'.tr(),
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.muted,
                ),
              ),
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionsList extends StatelessWidget {
  final List<Prediction> predictions;
  final ValueChanged<Prediction> onSelected;

  const _PredictionsList({required this.predictions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A17201B),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: predictions.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) {
          final prediction = predictions[index];

          return ListTile(
            leading: const Icon(Icons.location_pin, color: AppColors.primary),
            title: Text(
              prediction.description ?? '',
              style: AppTypography.bodyMedium,
            ),
            onTap: () => onSelected(prediction),
          );
        },
      ),
    );
  }
}

class _CurrentLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CurrentLocationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.my_location, color: AppColors.primary),
      ),
    );
  }
}

const _addressLabels = ['Home', 'Work', 'Other'];

class _ConfirmSheet extends ConsumerWidget {
  final bool addLocation;
  final String label;
  final ValueChanged<String> onLabelChanged;
  final VoidCallback onConfirm;
  final ValueChanged<Address> onSavedAddressTap;

  const _ConfirmSheet({
    required this.addLocation,
    required this.label,
    required this.onLabelChanged,
    required this.onConfirm,
    required this.onSavedAddressTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(currentLocation);
    final savedAddresses = ref.watch(addressesProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(Icons.location_pin, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.line1.isNotEmpty
                          ? location.line1
                          : location.address,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      location.address,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.muted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (location.isDetecting || location.checkingServiceability)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: LinearProgressIndicator(color: AppColors.primary),
            )
          else
            _ServiceabilityBanner(serviceable: location.serviceArea != null),
          if (addLocation) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.base,
              children: _addressLabels
                  .map(
                    (value) => ChoiceChip(
                      label: Text(value),
                      selected: label == value,
                      onSelected: (_) => onLabelChanged(value),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Builder(
            builder: (context) {
              final canConfirm =
                  !location.isDetecting &&
                  !location.checkingServiceability &&
                  location.serviceArea != null;

              return PrimaryButton(
                buttonTitle: 'confirmLocation'.tr(),
                buttonColor: canConfirm ? null : AppColors.line,
                action: canConfirm ? onConfirm : () {},
              );
            },
          ),
          if (!addLocation)
            savedAddresses.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const SizedBox.shrink(),
              data: (addresses) => addresses.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'yourSavedAddress'.tr(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        for (final address in addresses)
                          InkWell(
                            onTap: () => onSavedAddressTap(address),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.base,
                              ),
                              child: Text(
                                '${address.label} · ${address.line1}, ${address.area}',
                                style: AppTypography.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

class _ServiceabilityBanner extends StatelessWidget {
  final bool serviceable;

  const _ServiceabilityBanner({required this.serviceable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: serviceable ? AppColors.primaryTint : AppColors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Icon(
            serviceable ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: serviceable ? AppColors.primaryDark : AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              serviceable
                  ? 'weDeliverHere'.tr(args: ['12'])
                  : 'notServiceableYet'.tr(),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: serviceable ? AppColors.primaryDark : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
