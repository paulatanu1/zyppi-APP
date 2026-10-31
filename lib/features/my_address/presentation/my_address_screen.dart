import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/add_new_address_row.dart';
import 'package:zippy/features/my_address/application/addresses_provider.dart';
import 'package:zippy/features/my_address/widgets/saved_address_row.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Location.dc.html's "SAVED ADDRESSES" section; "Add new
/// address" opens the map-pin picker (search_address_screen.dart).
class MyAddressScreen extends ConsumerWidget {
  const MyAddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    tooltip: 'back'.tr(),
                  ),
                  Text('myAddress'.tr(), style: AppTypography.titleMedium),
                ],
              ),
            ),
            Divider(height: 1, color: context.colors.divider),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AddNewAddressRow(),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'yourSavedAddress'.tr(),
                      style: AppTypography.labelSmall.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Expanded(
                      child: addressesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (error, stackTrace) => Text(
                          'somethingWentWrong'.tr(),
                          style: AppTypography.bodyMedium,
                        ),
                        data: (addresses) => ListView.separated(
                          itemCount: addresses.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: context.colors.divider),
                          itemBuilder: (context, index) =>
                              SavedAddressRow(address: addresses[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
