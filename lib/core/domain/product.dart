import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/product_variant.dart';

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

    /// Optional sub-category of [categoryId] (admin `subcategoryId`).
    String? subcategoryId,
    required List<ProductVariant> variants,
    @Default(false) bool isFavourite,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

extension ProductPricing on Product {
  /// The variant cards show and add; null for a product with no variants
  /// (shown as unavailable rather than crashing).
  ProductVariant? get defaultVariant => variants.firstOrNull;
}
