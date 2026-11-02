import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

/// A cart row with its catalog [Product]/[ProductVariant]. Persisted whole
/// by LocalCartStore so the cart renders on launch without a catalog fetch.
class CartLine {
  final Product product;
  final ProductVariant variant;
  final int quantity;

  const CartLine({
    required this.product,
    required this.variant,
    required this.quantity,
  });

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    variant: ProductVariant.fromJson(json['variant'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'variant': variant.toJson(),
    'quantity': quantity,
  };

  CartLine copyWith({int? quantity}) => CartLine(
    product: product,
    variant: variant,
    quantity: quantity ?? this.quantity,
  );

  int get lineTotalPaise => variant.pricePaise * quantity;

  int get lineMrpPaise => (variant.mrpPaise ?? variant.pricePaise) * quantity;
}
