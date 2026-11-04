import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/zyppi_tokens.dart';
import 'package:zippy/core/widgets/z_product_card.dart';

/// Blinkit-referenced horizontally scrolling product carousel (their
/// "Deals for you" / "Festive Specials" pattern).
class ProductCarouselSection extends ConsumerWidget {
  /// Card width in the carousel (docs/screens/light/05-home.png).
  static const double _cardWidth = 150;

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
      height: ZProductCard.height(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: ZSpace.x3),
        itemBuilder: (context, index) =>
            CatalogProductCard(product: products[index], width: _cardWidth),
      ),
    );
  }
}
