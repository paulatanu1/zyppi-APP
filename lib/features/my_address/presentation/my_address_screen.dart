import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/add_new_address_row.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/my_address/widgets/address_actions.dart';
import 'package:zippy/features/my_address/widgets/saved_address_row.dart';

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
              padding: const EdgeInsets.all(ZSpace.x3),
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
            Divider(height: 1, color: context.z.line),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ZSpace.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AddNewAddressRow(),
                    const SizedBox(height: ZSpace.x4),
                    Text(
                      'yourSavedAddress'.tr(),
                      style: AppTypography.labelSmall.copyWith(
                        color: context.z.ink2,
                      ),
                    ),
                    const SizedBox(height: ZSpace.x3),
                    Expanded(
                      child: addressesAsync.when(
                        // Keep the list on screen while an edit refreshes it.
                        skipLoadingOnRefresh: true,
                        skipLoadingOnReload: true,
                        loading: () => ListView(
                          children: [
                            for (var i = 0; i < 3; i++)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: ZSpace.x2,
                                ),
                                child: ZSkeleton(
                                  height: 48,
                                  radius: ZRadius.control,
                                ),
                              ),
                          ],
                        ),
                        error: (error, stackTrace) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'somethingWentWrong'.tr(),
                              style: AppTypography.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () =>
                                  ref.invalidate(addressesProvider),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                        data: (addresses) => addresses.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: ZSpace.x4),
                                child: Text(
                                  'noSavedAddresses'.tr(),
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: context.z.ink2,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: addresses.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1, color: context.z.line),
                                itemBuilder: (context, index) =>
                                    SavedAddressRow(
                                      address: addresses[index],
                                      trailing: AddressActions(
                                        address: addresses[index],
                                      ),
                                    ),
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
