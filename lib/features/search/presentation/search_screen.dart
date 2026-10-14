import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/search/application/search_provider.dart';
import 'package:zippy/features/search/widgets/product_list_row.dart';

/// docs/mockups/Search.dc.html, minus the recent/trending-search chips
/// (no search-history persistence yet).
class SearchScreen extends ConsumerWidget {
  SearchScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
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
              else if (state.query.isNotEmpty && state.results.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'noProductsFound'.tr(),
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                )
              else if (state.query.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    itemCount: state.results.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final product = state.results[index];
                      final variant = product.variants.isNotEmpty
                          ? product.variants.first
                          : null;
                      if (variant == null) return const SizedBox.shrink();

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
                            .addItem(
                              productId: product.id,
                              variantId: variant.id,
                            ),
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .setQuantity(
                              productId: product.id,
                              variantId: variant.id,
                              quantity: cartQuantity + 1,
                            ),
                        onDecrement: () => ref
                            .read(cartProvider.notifier)
                            .setQuantity(
                              productId: product.id,
                              variantId: variant.id,
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
