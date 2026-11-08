import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/shared_providers/location/application/get_current_location_state.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/features/search_address/application/place_prediction_provider.dart';
import 'package:zippy/features/search_address/domain/place_prediction.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_map.dart';
import 'package:zippy/core/widgets/z_motion.dart';

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
  final _searchFocus = FocusNode();
  final _scroll = ScrollController();
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
    _searchFocus.dispose();
    _scroll.dispose();
    _line1Controller.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  static const double _mapHeight = 320;

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

    final z = context.z;
    final t = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;
    final showPredictions =
        predictions.isNotEmpty && _searchController.text.isNotEmpty;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _restoreHomeLocation();
      },
      child: Scaffold(
        backgroundColor: z.surface,
        body: SingleChildScrollView(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 04-location.png's map header (decorative, see ZMapBackdrop):
              // back + search on top, the delivery pin in the middle and
              // "Use current location" bottom-right.
              SizedBox(
                height: top + _mapHeight,
                child: Stack(
                  children: [
                    const Positioned.fill(child: ZMapBackdrop()),
                    Align(
                      alignment: const Alignment(0, .15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ZSpace.x3,
                              vertical: ZSpace.x2,
                            ),
                            decoration: BoxDecoration(
                              color: z.ink,
                              borderRadius: ZRadius.all(ZRadius.control),
                            ),
                            child: Text(
                              'deliveredHereTip'.tr(),
                              style: t.labelMedium!.copyWith(color: z.bg),
                            ),
                          ),
                          const SizedBox(height: ZSpace.x2),
                          Icon(
                            Icons.location_on_rounded,
                            size: 52,
                            color: z.brand,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: ZSpace.screen,
                      bottom: ZRadius.sheet + ZSpace.x3,
                      child: _MapPill(
                        icon: Icons.my_location_rounded,
                        label: 'useCurrentLocation'.tr(),
                        onTap: () => ref
                            .read(currentLocation.notifier)
                            .getCurrentLocation(requestPermission: true),
                      ),
                    ),
                    Positioned(
                      left: ZSpace.screen,
                      right: ZSpace.screen,
                      top: top + ZSpace.x2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Material(
                                color: z.surface,
                                borderRadius: ZRadius.all(ZRadius.input),
                                elevation: 1,
                                shadowColor: z.shadow,
                                child: IconButton(
                                  onPressed: () => context.pop(),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                    color: z.ink,
                                  ),
                                  tooltip: 'back'.tr(),
                                ),
                              ),
                              const SizedBox(width: ZSpace.x2),
                              Expanded(
                                child: _SearchBar(
                                  controller: _searchController,
                                  focusNode: _searchFocus,
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
                          if (showPredictions)
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: _mapHeight - 100,
                              ),
                              child: _PredictionsList(
                                predictions: predictions,
                                onSelected: (prediction) async {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // The sheet overlaps the map by its corner radius.
              Transform.translate(
                offset: const Offset(0, -ZRadius.sheet),
                // Material (not a coloured box) so the saved-address
                // tiles' ink shows.
                child: Material(
                  color: z.surface,
                  borderRadius: ZRadius.sheetTop,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      ZSpace.x5,
                      ZSpace.x3,
                      ZSpace.x5,
                      ZSpace.x5 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: z.line2,
                              borderRadius: ZRadius.all(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: ZSpace.x4),
                        _ConfirmSheet(
                          addLocation: widget.addLocation,
                          label: _label,
                          onLabelChanged: (value) =>
                              setState(() => _label = value),
                          line1Controller: _line1Controller,
                          landmarkController: _landmarkController,
                          onChange: () {
                            _scroll.animateTo(
                              0,
                              duration: ZMotion.ui,
                              curve: ZMotion.standard,
                            );
                            _searchFocus.requestFocus();
                          },
                          saving: _saving,
                          onConfirm: () async {
                            ref
                                .read(currentLocation.notifier)
                                .applyEditedText(
                                  line1: _line1Controller.text.trim(),
                                  landmark:
                                      _landmarkController.text.trim().isEmpty
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
                      ],
                    ),
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

/// White pill over the map ("Use current location").
class _MapPill extends StatelessWidget {
  const _MapPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Semantics(
      button: true,
      child: ZPressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: ZSize.touch),
          padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
          decoration: BoxDecoration(
            color: z.surface,
            borderRadius: ZRadius.all(ZRadius.input),
            border: Border.all(color: z.line),
            boxShadow: [
              BoxShadow(
                color: z.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: z.brandText),
              const SizedBox(width: ZSpace.x2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge!
                    .copyWith(color: z.brandText),
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
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: ZSize.touch),
      padding: const EdgeInsets.symmetric(horizontal: ZSpace.x3),
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.input),
        border: Border.all(color: z.line),
        boxShadow: [
          BoxShadow(
            color: z.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: z.ink3),
          const SizedBox(width: ZSpace.x2),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'searchAreaPlaceholder'.tr(),
                hintStyle: t.bodyMedium!.copyWith(color: z.ink3),
              ),
              style: t.bodyMedium,
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
    final z = context.z;
    return Container(
      margin: const EdgeInsets.only(top: ZSpace.x2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.card),
        border: Border.all(color: z.line),
        boxShadow: [
          BoxShadow(
            color: z.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: ZSpace.x1),
          itemCount: predictions.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: z.line),
          itemBuilder: (context, index) {
            final prediction = predictions[index];

            return ListTile(
              leading: Icon(Icons.location_on_outlined, color: z.brandText),
              title: Text(
                prediction.description ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () => onSelected(prediction),
            );
          },
        ),
      ),
    );
  }
}

/// The sheet's content: the resolved address with "Change", the
/// serviceability note, editable address line + landmark, label chips
/// (when saving a new address), Confirm, then saved addresses.
class _ConfirmSheet extends ConsumerWidget {
  final bool addLocation;
  final String label;
  final ValueChanged<String> onLabelChanged;
  final TextEditingController line1Controller;
  final TextEditingController landmarkController;
  final VoidCallback onChange;
  final VoidCallback onConfirm;
  final ValueChanged<Address> onSavedAddressTap;

  const _ConfirmSheet({
    required this.addLocation,
    required this.label,
    required this.onLabelChanged,
    required this.line1Controller,
    required this.landmarkController,
    required this.onChange,
    required this.onConfirm,
    required this.onSavedAddressTap,
    this.saving = false,
  });

  final bool saving;

  static IconData _labelIcon(String value) => switch (value) {
    'Home' => Icons.home_outlined,
    'Work' => Icons.work_outline_rounded,
    _ => Icons.add_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final location = ref.watch(currentLocation);
    final savedAddresses = ref.watch(addressesProvider);
    final busy = location.isDetecting || location.checkingServiceability;
    final title = location.line1.isNotEmpty
        ? location.line1
        : location.address.isNotEmpty
        ? location.address.split(',').first
        : 'yourDeliveryLocation'.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ZSize.touch,
              height: ZSize.touch,
              decoration: BoxDecoration(
                color: z.brandSoft,
                borderRadius: ZRadius.all(ZRadius.input),
              ),
              child: Icon(Icons.location_on_outlined, color: z.brandText),
            ),
            const SizedBox(width: ZSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleLarge,
                  ),
                  if (location.address.isNotEmpty)
                    Text(
                      location.address,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium!.copyWith(color: z.ink2),
                    ),
                ],
              ),
            ),
            TextButton(onPressed: onChange, child: Text('change'.tr())),
          ],
        ),
        const SizedBox(height: ZSpace.x4),
        if (busy)
          ClipRRect(
            borderRadius: ZRadius.all(ZRadius.badge),
            child: LinearProgressIndicator(
              color: z.brand,
              backgroundColor: z.surface3,
            ),
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
        const SizedBox(height: ZSpace.x4),
        TextField(
          controller: line1Controller,
          decoration: InputDecoration(labelText: 'addressLine'.tr()),
        ),
        const SizedBox(height: ZSpace.x3),
        TextField(
          controller: landmarkController,
          decoration: InputDecoration(labelText: 'landmarkOptional'.tr()),
        ),
        if (addLocation) ...[
          const SizedBox(height: ZSpace.x3),
          Wrap(
            spacing: ZSpace.x2,
            children: [
              for (final value in addressLabels)
                ZChip(
                  icon: _labelIcon(value),
                  label: addressLabelText(value),
                  selected: label == value,
                  onTap: () => onLabelChanged(value),
                ),
            ],
          ),
        ],
        const SizedBox(height: ZSpace.x4),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, ZSize.button),
          ),
          onPressed: !saving && !busy && location.serviceArea != null
              ? onConfirm
              : null,
          child: saving
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text('confirmLocation'.tr()),
        ),
        if (!addLocation)
          savedAddresses.maybeWhen(
            orElse: () => const SizedBox.shrink(),
            data: (addresses) => addresses.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: ZSpace.x5),
                      Text(
                        'yourSavedAddress'.tr().toUpperCase(),
                        style: t.labelSmall!.copyWith(letterSpacing: 1.1),
                      ),
                      const SizedBox(height: ZSpace.x1),
                      for (final address in addresses)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => onSavedAddressTap(address),
                          leading: Icon(
                            _labelIcon(address.label),
                            color: z.ink2,
                          ),
                          title: Text(
                            addressLabelText(address.label),
                            style: t.labelLarge,
                          ),
                          subtitle: Text(
                            '${address.line1}, ${address.area}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall,
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: z.ink3,
                          ),
                        ),
                    ],
                  ),
          ),
      ],
    );
  }
}

/// Coloured note under the address: icon + one line of text.
class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
    this.action,
  });

  final IconData icon;
  final String text;
  final Color background, foreground;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ZSpace.x4,
        vertical: ZSpace.x3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: ZRadius.all(ZRadius.input),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: ZSpace.x2),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge!
                  .copyWith(color: foreground),
            ),
          ),
          ?action,
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
    final z = context.z;
    return serviceable
        ? _Note(
            icon: Icons.bolt_rounded,
            text: 'weDeliverHereShort'.tr(),
            background: z.okSoft,
            foreground: z.ok,
          )
        : _Note(
            icon: Icons.error_outline_rounded,
            text: 'notServiceableYet'.tr(),
            background: z.dangerSoft,
            foreground: z.danger,
          );
  }
}

class _ServiceabilityError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ServiceabilityError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return _Note(
      icon: Icons.wifi_off_rounded,
      text: 'serviceabilityCheckFailed'.tr(),
      background: z.dangerSoft,
      foreground: z.danger,
      action: TextButton(onPressed: onRetry, child: Text('retry'.tr())),
    );
  }
}

class _PickLocationHint extends StatelessWidget {
  const _PickLocationHint();

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return _Note(
      icon: Icons.my_location_rounded,
      text: 'pickLocationToCheck'.tr(),
      background: z.surface2,
      foreground: z.ink2,
    );
  }
}
