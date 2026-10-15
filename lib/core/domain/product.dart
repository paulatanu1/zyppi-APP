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
    required String categoryId,
    required List<ProductVariant> variants,
    @Default(false) bool isFavourite,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

extension ProductPricing on Product {
  ProductVariant get defaultVariant => variants.first;
}
