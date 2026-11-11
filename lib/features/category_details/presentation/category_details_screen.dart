import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/cart/presentation/floating_cart_bar.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_product_card.dart';
import 'package:zippy/features/category_details/application/category_details_provider.dart';
import 'package:zippy/features/category_details/widgets/category_details_header.dart';
import 'package:zippy/features/category_details/application/category_details_state.dart';
import 'package:zippy/features/category_details/widgets/category_filter_chips.dart';
import 'package:zippy/features/category_details/widgets/subcategory_rail.dart';

/// docs/screens/light/06-category.png: header, the sub-category rail on
/// the left (hidden when the category has none), filter chips and a
/// two-column product grid.
class CategoryDetailsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryDetailsProvider(categoryId));
    final notifier = ref.read(categoryDetailsProvider(categoryId).notifier);
    final filter = ref.watch(productFilterProvider(categoryId));
    final products = filter.apply(state.visibleProducts);
    final showRail =
        state.error == null &&
        state.category != null &&
        state.subcategories.isNotEmpty;
    final gutter = showRail ? ZSpace.x2 + 2 : ZSpace.screen;
    final t = Theme.of(context).textTheme;

    Widget message(String text, {Widget? action}) => Center(
      child: Padding(
        padding: const EdgeInsets.all(ZSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center, style: t.bodyMedium),
            if (action != null) ...[const SizedBox(height: ZSpace.x3), action],
          ],
        ),
      ),
    );

    final Widget body;
    if (state.error != null) {
      body = message(
        'somethingWentWrong'.tr(),
        action: SizedBox(
          width: 160,
          child: PrimaryButton(
            buttonTitle: 'retry'.tr(),
            action: notifier.retry,
          ),
        ),
      );
    } else if (!state.loading && state.category == null) {
      body = message('categoryNotFound'.tr());
    } else if (!state.loading && products.isEmpty) {
      body = message(
        filter.isActive ? 'noProductsMatchFilter'.tr() : 'noProductsFound'.tr(),
        action: filter.isActive
            ? TextButton(
                onPressed: () =>
                    ref.read(productFilterProvider(categoryId).notifier).state =
                        ProductFilter.none,
                child: Text('clearFilters'.tr()),
              )
            : null,
      );
    } else {
      body = RefreshIndicator(
        // A new grid (and a cross-fade) per rail selection.
        key: ValueKey(state.selectedSubcategoryId),
        // Pull down: drop the cached catalog and reload this category.
        onRefresh: () {
          ref.read(catalogRepositoryProvider).invalidate();
          return notifier.retry();
        },
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          // Room at the end for the floating cart bar.
          padding: EdgeInsets.fromLTRB(
            gutter,
            ZSpace.x2,
            gutter,
            ZSize.cartBar + ZSpace.x6,
          ),
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
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategoryDetailsHeader(
                  title: state.category?.name ?? '',
                  itemCount: products.length,
                  loading: state.loading,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showRail)
                        SubcategoryRail(
                          parent: state.category!,
                          subcategories: state.subcategories,
                          selectedId: state.selectedSubcategoryId,
                          onSelect: notifier.selectSubcategory,
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.error == null && state.category != null)
                              CategoryFilterChips(categoryId: categoryId),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : ZMotion.ui,
                                child: body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              left: ZSpace.screen,
              right: ZSpace.screen,
              bottom: ZSpace.x3,
              child: FloatingCartBar(),
            ),
          ],
        ),
      ),
    );
  }
}
