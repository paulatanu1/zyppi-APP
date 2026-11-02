import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/search/application/search_provider.dart';
import 'package:zippy/features/search/widgets/product_list_row.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Search.dc.html, minus the recent/trending-search chips
/// (no search-history persistence yet).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  // Owned by the State so it survives rebuilds and is disposed; starts
  // from the provider's query so the box and the results always agree.
  late final searchController = TextEditingController(
    text: ref.read(searchProvider).query,
  );

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final cart = ref.watch(cartProvider);
    // A product with no variant can't be shown or added; dropping it here
    // (not in the list builder) keeps the dividers even.
    final results = state.results.where((p) => p.variants.isNotEmpty).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    tooltip: 'back'.tr(),
                  ),
                  Expanded(
                    child: TextformField(
                      prefixIcon: true,
                      textFormFieldController: searchController,
                      labelText: 'searchStoreHint'.tr(),
                      onChanged: notifier.search,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
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
                        const SizedBox(height: AppSpacing.base),
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
              else if (state.loading && results.isEmpty)
                Expanded(
                  child: ListView(
                    children: [
                      for (var i = 0; i < 5; i++)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: ZSkeleton(height: 56, radius: ZRadius.control),
                        ),
                    ],
                  ),
                )
              else if (state.query.trim().isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 48,
                          color: context.colors.muted,
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          'searchIdleHint'.tr(),
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (results.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'noProductsFound'.tr(),
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: context.colors.divider),
                    itemBuilder: (context, index) {
                      final product = results[index];
                      final variant = product.variants.first;

                      final cartLine = cart.lines.where(
                        (l) =>
                            l.product.id == product.id &&
                            l.variant.id == variant.id,
                      );
                      final cartQuantity = cartLine.isEmpty
                          ? 0
                          : cartLine.first.quantity;

                      return ProductListRow(
                        name: product.name,
                        imagePath: product.image,
                        unit: variant.label,
                        pricePaise: variant.pricePaise,
                        cartQuantity: cartQuantity,
                        onClicked: () => context.push(
                          '/productDetailsScreen?productId=${product.id}',
                        ),
                        onAddClicked: () => ref
                            .read(cartProvider.notifier)
                            .addItem(product: product, variant: variant),
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .setQuantity(
                              product: product,
                              variant: variant,
                              quantity: cartQuantity + 1,
                            ),
                        onDecrement: () => ref
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
            ],
          ),
        ),
      ),
    );
  }
}
