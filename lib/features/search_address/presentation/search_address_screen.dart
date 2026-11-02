import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/shared_providers/location/application/get_current_location_state.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/features/search_address/application/place_prediction_provider.dart';
import 'package:zippy/features/search_address/domain/place_prediction.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Location.dc.html, minus the embedded Google Maps pin-picker:
/// delivery here only ever needs a GPS `lat`/`lng` (the rider navigates with
/// their own phone's Maps app), so this screen resolves a location via GPS
/// or place search and lets the customer edit the address text directly
/// instead of dragging a pin to confirm it visually.
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
  final _line1Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  String _label = 'Home';
  String? _syncedForAddress;
  bool _saving = false;

  /// The home screen's delivery location when this screen opened. Adding
  /// a new address resolves locations through the same provider, so it's
  /// put back on the way out — saving an address shouldn't silently move
  /// where the current order is delivered.
  GetCurrentLocationState? _homeLocation;

  @override
  void initState() {
    super.initState();
    if (widget.addLocation) _homeLocation = ref.read(currentLocation);
  }

  void _restoreHomeLocation() {
    final snapshot = _homeLocation;
    if (snapshot == null) return;
    _homeLocation = null;
    ref.read(currentLocation.notifier).restore(snapshot);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _line1Controller.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(currentLocation);
    final predictions =
        ref.watch(placePredictionProvider).placePrediction?.predictions ??
        const [];

    // Re-sync the editable text fields whenever a fresh resolution comes in
    // (GPS, search result or saved address) — but not on every rebuild, so
    // the user's own edits aren't clobbered while they type.
    if (_syncedForAddress != location.address) {
      _syncedForAddress = location.address;
      _line1Controller.text = location.line1.isNotEmpty
          ? location.line1
          : location.address;
      _landmarkController.text = location.landmark ?? '';
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _restoreHomeLocation();
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back, color: context.colors.muted),
                      tooltip: 'back'.tr(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SearchBar(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                          ref
                              .read(placePredictionProvider.notifier)
                              .placePrediction(input: value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (predictions.isNotEmpty && _searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
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
                      if (mounted) setState(() {});
                    },
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: _ConfirmSheet(
                    addLocation: widget.addLocation,
                    label: _label,
                    onLabelChanged: (value) => setState(() => _label = value),
                    line1Controller: _line1Controller,
                    landmarkController: _landmarkController,
                    onUseCurrentLocation: () => ref
                        .read(currentLocation.notifier)
                        .getCurrentLocation(requestPermission: true),
                    saving: _saving,
                    onConfirm: () async {
                      ref
                          .read(currentLocation.notifier)
                          .applyEditedText(
                            line1: _line1Controller.text.trim(),
                            landmark: _landmarkController.text.trim().isEmpty
                                ? null
                                : _landmarkController.text.trim(),
                          );
                      if (widget.addLocation) {
                        setState(() => _saving = true);
                        final saved = await ref
                            .read(placePredictionProvider.notifier)
                            .addAddress(label: _label);
                        if (!mounted) return;
                        setState(() => _saving = false);
                        // Stay (with the user's input) if it didn't save.
                        if (!saved) return;
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.inputMin,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: 'searchAreaPlaceholder'.tr(),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: context.colors.muted,
          ),
        ),
        style: AppTypography.bodyMedium,
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
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: predictions.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: context.colors.divider),
          itemBuilder: (context, index) {
            final prediction = predictions[index];

            return ListTile(
              leading: Icon(Icons.location_pin, color: context.colors.primary),
              title: Text(
                prediction.description ?? '',
                style: AppTypography.bodyMedium,
              ),
              onTap: () => onSelected(prediction),
            );
          },
        ),
      ),
    );
  }
}

class _ConfirmSheet extends ConsumerWidget {
  final bool addLocation;
  final String label;
  final ValueChanged<String> onLabelChanged;
  final TextEditingController line1Controller;
  final TextEditingController landmarkController;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onConfirm;
  final ValueChanged<Address> onSavedAddressTap;

  const _ConfirmSheet({
    required this.addLocation,
    required this.label,
    required this.onLabelChanged,
    required this.line1Controller,
    required this.landmarkController,
    required this.onUseCurrentLocation,
    required this.onConfirm,
    required this.onSavedAddressTap,
    this.saving = false,
  });

  final bool saving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(currentLocation);
    final savedAddresses = ref.watch(addressesProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'yourDeliveryLocation'.tr(),
                  style: AppTypography.titleMedium,
                ),
              ),
              Material(
                color: context.colors.primaryTint,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onUseCurrentLocation,
                  icon: Icon(Icons.my_location, color: context.colors.primary),
                  tooltip: 'useCurrentLocation'.tr(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (location.isDetecting || location.checkingServiceability)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: LinearProgressIndicator(color: context.colors.primary),
            )
          else if (location.serviceabilityError)
            _ServiceabilityError(
              onRetry: () =>
                  ref.read(currentLocation.notifier).retryServiceability(),
            )
          else if (!location.serviceabilityChecked)
            // No point checked yet (permission off, nothing picked): ask
            // for a location rather than claiming we don't deliver.
            const _PickLocationHint()
          else
            _ServiceabilityBanner(serviceable: location.serviceArea != null),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: line1Controller,
            decoration: InputDecoration(labelText: 'addressLine'.tr()),
          ),
          const SizedBox(height: AppSpacing.base),
          TextField(
            controller: landmarkController,
            decoration: InputDecoration(labelText: 'landmarkOptional'.tr()),
          ),
          if (addLocation) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.base,
              children: addressLabels
                  .map(
                    (value) => ChoiceChip(
                      label: Text(addressLabelText(value)),
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
                  !saving &&
                  !location.isDetecting &&
                  !location.checkingServiceability &&
                  location.serviceArea != null;

              return FilledButton(
                onPressed: canConfirm ? onConfirm : null,
                child: saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text('confirmLocation'.tr()),
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
                            color: context.colors.muted,
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
                                '${addressLabelText(address.label)} · ${address.line1}, ${address.area}',
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
        color: serviceable
            ? context.colors.primaryTint
            : context.colors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Icon(
            serviceable ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: serviceable
                ? context.colors.primaryDark
                : context.colors.danger,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              serviceable
                  ? 'weDeliverHereShort'.tr()
                  : 'notServiceableYet'.tr(),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: serviceable
                    ? context.colors.primaryDark
                    : context.colors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceabilityError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ServiceabilityError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: context.colors.danger),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'serviceabilityCheckFailed'.tr(),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.danger,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }
}

class _PickLocationHint extends StatelessWidget {
  const _PickLocationHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location, size: 16, color: context.colors.muted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'pickLocationToCheck'.tr(),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
