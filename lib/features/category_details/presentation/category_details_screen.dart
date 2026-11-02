import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/item_card.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/category_details/application/category_details_provider.dart';
import 'package:zippy/features/category_details/widgets/category_details_header.dart';

/// docs/mockups/Category.dc.html, minus the sub-category rail (no
/// sub-category relationship in the catalog data model yet).
class CategoryDetailsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryDetailsProvider(categoryId));
    final notifier = ref.read(categoryDetailsProvider(categoryId).notifier);
    final cart = ref.watch(cartProvider);
    final filter = ref.watch(productFilterProvider(categoryId));
    final products = filter.apply(state.products);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryDetailsHeader(
                categoryId: categoryId,
                title: state.category?.name ?? '',
                itemCount: products.length,
                loading: state.loading,
                activeFilters: filter.activeCount,
              ),
              const SizedBox(height: AppSpacing.base),
              if (state.error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'somethingWentWrong'.tr(),
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: 160,
                          child: PrimaryButton(
                            buttonTitle: 'retry'.tr(),
                            action: notifier.retry,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!state.loading && state.category == null)
                Expanded(
                  child: Center(
                    child: Text(
                      'categoryNotFound'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ),
                )
              else if (!state.loading && products.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter.isActive
                              ? 'noProductsMatchFilter'.tr()
                              : 'noProductsFound'.tr(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                        if (filter.isActive)
                          TextButton(
                            onPressed: () =>
                                ref
                                        .read(
                                          productFilterProvider(categoryId)
                                              .notifier,
                                        )
                                        .state =
                                    ProductFilter.none,
                            child: Text('clearFilters'.tr()),
                          ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: AppSkeleton(
                    enabled: state.loading,
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.base,
                            mainAxisSpacing: AppSpacing.base,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: state.loading ? 6 : products.length,
                      itemBuilder: (context, index) {
                        if (state.loading) {
                          return ItemCard(
                            productName: 'productNamePlaceholder'.tr(),
                          );
                        }

                        final product = products[index];
                        final variant = product.variants.isNotEmpty
                            ? product.variants.first
                            : null;
                        final cartLine = cart.lines.where(
                          (l) =>
                              l.product.id == product.id &&
                              variant != null &&
                              l.variant.id == variant.id,
                        );
                        final cartQuantity = cartLine.isEmpty
                            ? 0
                            : cartLine.first.quantity;

                        return ItemCard(
                          productName: product.name,
                          quantity: variant?.label ?? '',
                          pricePaise: variant?.pricePaise,
                          mrpPaise: variant?.mrpPaise,
                          imagePath: product.image,
                          cartQuantity: cartQuantity,
                          onClicked: () => context.push(
                            '/productDetailsScreen?productId=${product.id}',
                          ),
                          onAddClicked: variant == null
                              ? null
                              : () => ref
                                    .read(cartProvider.notifier)
                                    .addItem(
                                      product: product,
                                      variant: variant,
                                    ),
                          onIncrement: variant == null
                              ? null
                              : () => ref
                                    .read(cartProvider.notifier)
                                    .setQuantity(
                                      product: product,
                                      variant: variant,
                                      quantity: cartQuantity + 1,
                                    ),
                          onDecrement: variant == null
                              ? null
                              : () => ref
                                    .read(cartProvider.notifier)
                                    .setQuantity(
                                      product: product,
                                      variant: variant,
                                      quantity: cartQuantity - 1,
                                    ),
                        );
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
