import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

/// In-memory view model joining a persisted [CartItem] with its catalog
/// [Product]/[ProductVariant] — never persisted itself.
class CartLine {
  final Product product;
  final ProductVariant variant;
  final int quantity;

  const CartLine({
    required this.product,
    required this.variant,
    required this.quantity,
  });

  int get lineTotalPaise => variant.pricePaise * quantity;

  int get lineMrpPaise => (variant.mrpPaise ?? variant.pricePaise) * quantity;
}
