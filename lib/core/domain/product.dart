import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  factory Product({
    required String id,
    required String name,
    String? image,

    /// "About this item" on product details; hidden when empty.
    String? description,
    required String categoryId,

    /// Optional sub-category of [categoryId]; untagged products show only
    /// under the category page's "All".
    String? subcategoryId,
    required List<ProductVariant> variants,
    @Default(false) bool isFavourite,

    /// Marketplace: the top offer per area and variant
    /// (products/{id}.areaBest). Empty = Zyppi only (its variant prices).
    @Default({}) Map<String, Map<String, BestOffer>> areaBest,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

extension ProductPricing on Product {
  /// The variant cards show and add; null for a product with no variants
  /// (shown as unavailable rather than crashing).
  ProductVariant? get defaultVariant => variants.firstOrNull;

  /// The top offer for [variantId] where the customer shops, if any.
  BestOffer? bestOfferFor(String? areaId, String variantId) =>
      areaId == null ? null : areaBest[areaId]?[variantId];
}
