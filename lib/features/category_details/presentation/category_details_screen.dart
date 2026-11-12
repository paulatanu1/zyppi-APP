import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/cart/presentation/floating_cart_bar.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_product_card.dart';
import 'package:zippy/features/category_details/application/category_details_provider.dart';
import 'package:zippy/features/category_details/widgets/category_details_header.dart';
import 'package:zippy/features/category_details/widgets/category_filter_chips.dart';
import 'package:zippy/features/category_details/widgets/category_rail.dart';

/// The product list page (Blinkit/Zepto style): purple header, filter
/// chips, then a left menu of sub-categories (or of every category) beside
/// a two-column product grid. The menu switches the products in place.
///
/// [categoryId] may be a top-level category, a sub-category, or '' for
/// All (Home's "All" chip).
class CategoryDetailsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryDetailsProvider(categoryId));
    final notifier = ref.read(categoryDetailsProvider(categoryId).notifier);
    final key = state.selectionKey;
    final filter = ref.watch(productFilterProvider(key));
    final products = filter.apply(state.visibleProducts);
    final t = Theme.of(context).textTheme;
    final notFound =
        !state.loading &&
        state.parentId != null &&
        state.category == null &&
        state.error == null;

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

    final Widget grid;
    if (state.error != null) {
      grid = message(
        'somethingWentWrong'.tr(),
        action: SizedBox(
          width: 160,
          child: PrimaryButton(
            buttonTitle: 'retry'.tr(),
            action: notifier.retry,
          ),
        ),
      );
    } else if (notFound) {
      grid = message('categoryNotFound'.tr());
    } else if (!state.loading && products.isEmpty) {
      grid = message(
        filter.isActive ? 'noProductsMatchFilter'.tr() : 'noProductsFound'.tr(),
        action: filter.isActive
            ? TextButton(
                onPressed: () =>
                    ref.read(productFilterProvider(key).notifier).state =
                        ProductFilter.none,
                child: Text('clearFilters'.tr()),
              )
            : null,
      );
    } else {
      grid = GridView.builder(
        // A new list per selection, so it starts at the top.
        key: ValueKey(key),
        physics: const BouncingScrollPhysics(),
        // Room at the end for the floating cart bar.
        padding: const EdgeInsets.fromLTRB(
          ZSpace.x3,
          ZSpace.x3,
          ZSpace.x3,
          ZSize.cartBar + ZSpace.x6,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: ZSpace.x2,
          mainAxisSpacing: ZSpace.x2,
          // Narrow cards beside the menu: compact layout, one height that
          // grows with text size.
          mainAxisExtent: ZProductCard.height(context, compact: true),
        ),
        itemCount: state.loading ? 6 : products.length,
        itemBuilder: (context, index) => state.loading
            ? const ZProductCardSkeleton()
            : CatalogProductCard(product: products[index], compact: true),
      );
    }

    return Scaffold(
      body: SafeArea(
        // The purple header runs under the status bar.
        top: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategoryDetailsHeader(
                  title: state.parentId == null
                      ? 'allProducts'.tr()
                      : state.category?.name ?? '',
                  itemCount: products.length,
                  loading: state.loading,
                ),
                if (state.error == null && !notFound) ...[
                  const SizedBox(height: ZSpace.x2),
                  CategoryFilterChips(categoryId: key),
                ],
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.categories.isNotEmpty)
                        CategoryRail(
                          state: state,
                          onSelectParent: notifier.selectParent,
                          onSelectSub: notifier.selectSub,
                        ),
                      Expanded(child: grid),
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
