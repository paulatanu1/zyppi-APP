import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';
import 'package:zippy/core/widgets/z_product_card.dart';

/// [ZProductCard] for a catalog [Product], wired to the cart (first
/// variant, as everywhere else in the app), favourites and the product
/// screen. A product with no variant shows as unavailable.
class CatalogProductCard extends ConsumerWidget {
  const CatalogProductCard({super.key, required this.product, this.width});

  final Product product;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = product.variants.isNotEmpty ? product.variants.first : null;
    final quantity = variant == null
        ? 0
        : ref.watch(
            cartProvider.select(
              (cart) => cart.lines
                  .where(
                    (l) =>
                        l.product.id == product.id &&
                        l.variant.id == variant.id,
                  )
                  .fold<int>(0, (sum, l) => sum + l.quantity),
            ),
          );
    final favourite = ref.watch(
      favouritesProvider.select((ids) => ids.contains(product.id)),
    );
    final cart = ref.read(cartProvider.notifier);
    // Unique per card on screen (the same product can be in two Home
    // sections) and stable across rebuilds, so the flight back on pop
    // still finds this card.
    final heroTag = 'product-${product.id}-${identityHashCode(context)}';

    return ZProductCard(
      width: width,
      name: product.name,
      weight: variant?.label ?? '',
      image: CatalogImage(image: product.image, fit: BoxFit.contain),
      heroTag: heroTag,
      price: variant?.pricePaise,
      mrp: variant?.mrpPaise,
      quantity: quantity,
      favourite: favourite,
      onTap: () => context.push(
        Uri(
          path: '/productDetailsScreen',
          queryParameters: {'productId': product.id, 'hero': heroTag},
        ).toString(),
      ),
      onFavourite: () =>
          ref.read(favouritesProvider.notifier).toggle(product.id),
      // Read the live quantity at tap time: two quick taps before a
      // rebuild must count twice.
      onAdd: variant == null
          ? null
          : () {
              final current = cart.quantityOf(product.id, variant.id);
              current == 0
                  ? cart.addItem(product: product, variant: variant)
                  : cart.setQuantity(
                      product: product,
                      variant: variant,
                      quantity: current + 1,
                    );
            },
      onRemove: variant == null
          ? null
          : () => cart.setQuantity(
              product: product,
              variant: variant,
              quantity: cart.quantityOf(product.id, variant.id) - 1,
            ),
    );
  }
}
