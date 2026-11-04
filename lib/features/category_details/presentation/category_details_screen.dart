import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/zyppi_tokens.dart';
import 'package:zippy/core/widgets/z_product_card.dart';
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
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: ZSpace.x4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ZSpace.x3,
                      mainAxisSpacing: ZSpace.x3,
                      // Cards share one height that grows with text size.
                      mainAxisExtent: ZProductCard.height(context),
                    ),
                    itemCount: state.loading ? 6 : products.length,
                    itemBuilder: (context, index) => state.loading
                        ? const ZProductCardSkeleton()
                        : CatalogProductCard(product: products[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
