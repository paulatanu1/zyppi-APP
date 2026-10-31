import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/add_new_address_row.dart';
import 'package:zippy/features/home_screen/widgets/search_places_widget.dart';
import 'package:zippy/features/my_address/application/addresses_provider.dart';
import 'package:zippy/features/my_address/widgets/saved_address_row.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// Tapping the home header's address row opens this sheet — a compact
/// version of docs/mockups/Location.dc.html's "Select Address" step; the
/// full map-pin picker lives at search_address_screen.dart.
void bottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheetTop),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('selectAddress'.tr(), style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.xxl),
            const SearchPlacesWidget(),
            const SizedBox(height: AppSpacing.base),
            const AddNewAddressRow(),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'yourSavedAddress'.tr(),
              style: AppTypography.labelSmall.copyWith(
                color: context.colors.muted,
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final addressesAsync = ref.watch(addressesProvider);

                return addressesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                  data: (addresses) => Column(
                    children: addresses
                        .map(
                          (address) => InkWell(
                            onTap: () async {
                              await ref
                                  .read(currentLocation.notifier)
                                  .selectSavedAddress(address);
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: SavedAddressRow(address: address),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
