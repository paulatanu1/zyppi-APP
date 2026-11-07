import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/favourite/application/favourite_products_provider.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/widgets/z_product_card.dart';

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
              padding: const EdgeInsets.all(ZSpace.x4),
              child: Text('favourite'.tr(), style: AppTypography.headlineSmall),
            ),
            Divider(height: 1, color: context.z.line),
            Expanded(
              child: productsAsync.when(
                // Removing a heart refreshes the list; keep it on screen.
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                loading: () => _ProductGrid(
                  itemCount: 4,
                  itemBuilder: (context, index) => const ZProductCardSkeleton(),
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
                    // Tapping a card's heart removes it from this list.
                    : _ProductGrid(
                        itemCount: products.length,
                        itemBuilder: (context, index) =>
                            CatalogProductCard(product: products[index]),
                      ),
              ),
            ),
            productsAsync.maybeWhen(
              data: (products) => products.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.all(ZSpace.x4),
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

/// Two-column grid of product cards, as on the Category screen.
class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) => GridView.builder(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.all(ZSpace.screen),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: ZSpace.x3,
      mainAxisSpacing: ZSpace.x3,
      mainAxisExtent: ZProductCard.height(context),
    ),
    itemCount: itemCount,
    itemBuilder: itemBuilder,
  );
}
