import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/quantity_stepper.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/product_details/application/product_detail_provider.dart';
import 'package:zippy/features/product_details/widgets/product_slider.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Product.dc.html (the "Similar items" row is skipped —
/// no cross-product recommendation logic yet).
class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(productId));
    final notifier = ref.read(productDetailProvider(productId).notifier);
    final product = state.product;

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('somethingWentWrong'.tr(), style: AppTypography.bodyMedium),
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
      );
    }

    final variants = product?.variants ?? const <ProductVariant>[];
    final variant = variants.isEmpty
        ? null
        : variants[state.selectedVariantIndex.clamp(0, variants.length - 1)];

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductSlider(productId: productId),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: AppSkeleton(
                    enabled: state.loading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.name ?? 'Product name',
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (variant != null)
                          PriceTag(
                            pricePaise: variant.pricePaise,
                            mrpPaise: variant.mrpPaise,
                            priceStyle: AppTypography.titleMedium,
                          ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'selectPackSize'.tr(),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: List.generate(variants.length, (index) {
                            final v = variants[index];
                            final selected =
                                index == state.selectedVariantIndex;

                            return ChoiceChip(
                              label: Column(
                                children: [
                                  Text(
                                    v.label,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? AppColors.white
                                          : context.colors.ink,
                                    ),
                                  ),
                                  Text(
                                    PriceTag.format(v.pricePaise),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: selected
                                          ? AppColors.white
                                          : context.colors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              selected: selected,
                              onSelected: (_) => notifier.selectVariant(index),
                              selectedColor: context.colors.primary,
                              backgroundColor: context.colors.surface,
                              side: BorderSide(color: context.colors.line),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'aboutThisItem'.tr(),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'aboutThisItemPlaceholder'.tr(),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.line)),
              ),
              child: Row(
                children: [
                  QuantityStepper(
                    quantity: state.quantity,
                    onDecrement: notifier.decrementQuantity,
                    onIncrement: notifier.incrementQuantity,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: PrimaryButton(
                      buttonTitle: 'addToBasket'.tr(),
                      action: variant == null
                          ? () {}
                          : () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(
                                    productId: product!.id,
                                    variantId: variant.id,
                                    quantity: state.quantity,
                                  );
                              showSuccessToast(message: 'addedToCart'.tr());
                            },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  InkWell(
                    onTap: () => context.push('/myCartScreen'),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: Container(
                      width: AppSizes.inputMax,
                      height: AppSizes.inputMax,
                      decoration: BoxDecoration(
                        color: context.colors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
