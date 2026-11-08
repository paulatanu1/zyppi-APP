import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/domain/order.dart';

/// Adds a past [order]'s items to the cart at today's catalog prices.
/// Products no longer sold (inactive, or the variant is gone) are
/// skipped. Returns how many lines were added and how many skipped.
Future<({int added, int skipped})> reorderToCart({
  required Order order,
  required CatalogRepository catalog,
  required CartNotifier cart,
}) async {
  final ids = order.items
      .map((i) => i.productId)
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();
  final products = {
    for (final p in await catalog.fetchProductsByIds(ids)) p.id: p,
  };

  var added = 0;
  var skipped = 0;
  for (final item in order.items) {
    final product = products[item.productId];
    final variant = product?.variants
        .where((v) => v.id == item.variantId)
        .firstOrNull;
    if (product == null || variant == null) {
      skipped++;
      continue;
    }
    cart.addItem(product: product, variant: variant, quantity: item.quantity);
    added++;
  }
  return (added: added, skipped: skipped);
}
