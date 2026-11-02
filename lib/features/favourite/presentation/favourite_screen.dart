import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/favourite/application/favourite_products_provider.dart';
import 'package:zippy/features/favourite/widgets/favourite_item.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(favouriteProductsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text('favourite'.tr(), style: AppTypography.headlineSmall),
            ),
            Divider(height: 1, color: context.colors.divider),
            Expanded(
              child: productsAsync.when(
                // Removing a heart refreshes the list; keep it on screen.
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                loading: () => ListView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  children: [
                    for (var i = 0; i < 4; i++)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.lg),
                        child: ZSkeleton(height: 56, radius: ZRadius.control),
                      ),
                  ],
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'somethingWentWrong'.tr(),
                        style: AppTypography.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(favouriteProductsProvider),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
                data: (products) => products.isEmpty
                    ? Center(
                        child: Text(
                          'noFavouritesYet'.tr(),
                          style: AppTypography.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) =>
                            FavouriteItem(product: products[index]),
                      ),
              ),
            ),
            productsAsync.maybeWhen(
              data: (products) => products.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: PrimaryButton(
                        buttonTitle: 'addAllToCart'.tr(),
                        action: () {
                          final cart = ref.read(cartProvider.notifier);
                          var added = 0;
                          for (final product in products) {
                            if (product.variants.isEmpty) continue;
                            final variant = product.variants.first;
                            // Already in the cart: leave its quantity alone,
                            // so tapping twice doesn't double everything.
                            if (cart.quantityOf(product.id, variant.id) > 0) {
                              continue;
                            }
                            cart.addItem(product: product, variant: variant);
                            added++;
                          }
                          showSuccessToast(
                            message: added == 0
                                ? 'allFavouritesInCart'.tr()
                                : 'addedNToCart'.plural(added),
                          );
                        },
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
