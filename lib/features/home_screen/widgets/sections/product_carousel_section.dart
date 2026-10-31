import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/item_card.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/product.dart';

/// Blinkit-referenced horizontally scrolling product carousel (their
/// "Deals for you" / "Festive Specials" pattern).
class ProductCarouselSection extends ConsumerWidget {
  final HomeSection section;
  final Map<String, Product> productsById;

  const ProductCarouselSection({
    super.key,
    required this.section,
    required this.productsById,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = section.items
        .map((item) => productsById[item.data['product_id']])
        .whereType<Product>()
        .toList();

    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          final variant = product.variants.isNotEmpty
              ? product.variants.first
              : null;

          return SizedBox(
            width: 150,
            child: ItemCard(
              productName: product.name,
              quantity: variant?.label ?? '',
              pricePaise: variant?.pricePaise,
              mrpPaise: variant?.mrpPaise,
              imagePath: product.image,
              onClicked: () =>
                  context.push('/productDetailsScreen?productId=${product.id}'),
              onAddClicked: variant == null
                  ? null
                  : () => ref
                        .read(cartProvider.notifier)
                        .addItem(productId: product.id, variantId: variant.id),
            ),
          );
        },
      ),
    );
  }
}
