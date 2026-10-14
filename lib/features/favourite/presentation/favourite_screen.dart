import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/favourite/application/favourite_products_provider.dart';
import 'package:zippy/features/favourite/widgets/favourite_item.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(favouriteProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text('favourite'.tr(), style: AppTypography.headlineSmall),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: productsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'somethingWentWrong'.tr(),
                    style: AppTypography.bodyMedium,
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
                          for (final product in products) {
                            if (product.variants.isEmpty) continue;
                            ref
                                .read(cartProvider.notifier)
                                .addItem(
                                  productId: product.id,
                                  variantId: product.variants.first.id,
                                );
                          }
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
