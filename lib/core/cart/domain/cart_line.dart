import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';

/// A cart row with its catalog [Product]/[ProductVariant]. Persisted whole
/// by LocalCartStore so the cart renders on launch without a catalog fetch.
///
/// [offer] is the marketplace seller the line buys from; null = Zyppi's
/// own stock, priced from the variant (as before the marketplace). The
/// same variant from two sellers is two lines.
class CartLine {
  final Product product;
  final ProductVariant variant;
  final int quantity;
  final OfferPick? offer;

  const CartLine({
    required this.product,
    required this.variant,
    required this.quantity,
    this.offer,
  });

  /// How the line is told apart (local dirty set, server cart doc id):
  /// the offer id for a seller's line, the variant id for Zyppi's.
  String get key => keyFor(variant.id, offer);

  static String keyFor(String variantId, OfferPick? offer) =>
      offer?.offerId ?? variantId;

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    variant: ProductVariant.fromJson(json['variant'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
    offer: json['offer'] == null
        ? null
        : OfferPick.fromJson(json['offer'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'variant': variant.toJson(),
    'quantity': quantity,
    if (offer != null) 'offer': offer!.toJson(),
  };

  CartLine copyWith({int? quantity, OfferPick? offer}) => CartLine(
    product: product,
    variant: variant,
    quantity: quantity ?? this.quantity,
    offer: offer ?? this.offer,
  );

  int get unitPricePaise => offer?.pricePaise ?? variant.pricePaise;

  int get lineTotalPaise => unitPricePaise * quantity;

  int get lineMrpPaise =>
      (offer?.mrpPaise ?? variant.mrpPaise ?? unitPricePaise) * quantity;
}

/// Zyppi's own offer is stored as "no offer" (lines keyed by variant id),
/// exactly as CartNotifier does.
OfferPick? cartKeyPick(OfferPick? offer) =>
    offer == null || offer.isZyppi ? null : offer;
