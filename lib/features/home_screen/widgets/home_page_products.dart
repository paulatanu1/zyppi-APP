import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/item_card.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/application/home_products_provider.dart';

class HomePageProducts extends ConsumerWidget {
  final void Function(String productId)? onClicked;

  const HomePageProducts({super.key, this.onClicked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final productsAsync = ref.watch(homeProductsProvider);

    return productsAsync.when(
      loading: () => AppSkeleton(
        enabled: true,
        child: _ProductGrid(
          height: height,
          width: width,
          products: List.generate(
            6,
            (_) => Product(
              id: '',
              name: 'Product name',
              image: 'assets/images/item.png',
              categoryId: '',
              variants: [],
            ),
          ),
          onClicked: null,
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.04),
        child: Column(
          children: [
            Text('somethingWentWrong'.tr(), style: AppTypography.bodyMedium),
            SizedBox(height: height * 0.01),
            SizedBox(
              width: width * 0.4,
              child: PrimaryButton(
                buttonTitle: 'retry'.tr(),
                action: () => ref.invalidate(homeProductsProvider),
              ),
            ),
          ],
        ),
      ),
      data: (products) => _ProductGrid(
        height: height,
        width: width,
        products: products,
        onClicked: onClicked,
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  final double height;
  final double width;
  final List<Product> products;
  final void Function(String productId)? onClicked;

  const _ProductGrid({
    required this.height,
    required this.width,
    required this.products,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: width * 0.04,
        mainAxisSpacing: height * 0.02,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final variant = product.variants.isNotEmpty
            ? product.variants.first
            : null;

        return ItemCard(
          onClicked: onClicked == null ? null : () => onClicked!(product.id),
          productName: product.name,
          quantity: variant?.label ?? '',
          pricePaise: variant?.pricePaise,
          mrpPaise: variant?.mrpPaise,
          imagePath: product.image,
          onAddClicked: variant == null
              ? null
              : () => ref
                    .read(cartProvider.notifier)
                    .addItem(productId: product.id, variantId: variant.id),
        );
      },
    );
  }
}
