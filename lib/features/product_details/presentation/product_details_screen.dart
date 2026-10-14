import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/quantity_stepper.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/product_details/application/product_detail_provider.dart';
import 'package:zippy/features/product_details/widgets/dropdown_expentiantile.dart';
import 'package:zippy/features/product_details/widgets/product_slider.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;

    final state = ref.watch(productDetailProvider(productId));
    final notifier = ref.read(productDetailProvider(productId).notifier);
    final product = state.product;

    if (state.error != null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('somethingWentWrong'.tr(), style: AppTypography.bodyMedium),
              SizedBox(height: height * 0.015),
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

    final variant = product?.variants.first;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSlider(productId: productId),
            Padding(
              padding: EdgeInsets.only(
                left: height * 0.02,
                right: height * 0.02,
              ),
              child: AppSkeleton(
                enabled: state.loading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product?.name ?? 'Product name',
                          style: AppTypography.titleMedium,
                        ),
                        Icon(
                          product?.isFavourite == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 30,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.015),
                    Text(
                      variant?.label ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.grey3,
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuantityStepper(
                          quantity: state.quantity,
                          onDecrement: notifier.decrementQuantity,
                          onIncrement: notifier.incrementQuantity,
                        ),
                        if (variant != null)
                          PriceTag(
                            pricePaise: variant.pricePaise * state.quantity,
                            mrpPaise: variant.mrpPaise != null
                                ? variant.mrpPaise! * state.quantity
                                : null,
                            priceStyle: AppTypography.titleMedium,
                          ),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    Divider(height: 1, color: AppColors.grey5),
                    DropdownExpansionTile(
                      dropDownTitle: 'Product Detail',
                      dropDownContent: 'Freshly sourced and delivered from our local partner stores — matched for quality on every order.',
                    ),
                    Divider(height: 1, color: AppColors.grey5),
                    SizedBox(height: height * 0.015),
                    PrimaryButton(
                      buttonTitle: 'addToBasket'.tr(),
                      action: () {},
                    ),
                    SizedBox(height: height * 0.025),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
