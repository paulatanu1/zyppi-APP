import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/home_screen/widgets/add_new_address_row.dart';
import 'package:zippy/features/home_screen/widgets/search_places_widget.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/features/my_address/widgets/saved_address_row.dart';

/// Tapping the home header's address row opens this sheet — a compact
/// version of docs/mockups/Location.dc.html's "Select Address" step; the
/// full map-pin picker lives at search_address_screen.dart.
void bottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.z.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(ZRadius.sheet)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(ZSpace.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('selectAddress'.tr(), style: AppTypography.titleMedium),
            const SizedBox(height: ZSpace.x4),
            const SearchPlacesWidget(),
            const SizedBox(height: ZSpace.x3),
            const AddNewAddressRow(),
            const SizedBox(height: ZSpace.x4),
            Text(
              'yourSavedAddress'.tr(),
              style: AppTypography.labelSmall.copyWith(color: context.z.ink2),
            ),
            Consumer(
              builder: (context, ref, _) {
                final addressesAsync = ref.watch(addressesProvider);

                return addressesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: ZSpace.x3),
                    child: ZSkeleton(height: 44, radius: ZRadius.control),
                  ),
                  error: (error, stackTrace) => TextButton(
                    onPressed: () => ref.invalidate(addressesProvider),
                    child: Text('retry'.tr()),
                  ),
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
