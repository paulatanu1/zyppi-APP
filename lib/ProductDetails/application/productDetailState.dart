import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/productDetail.dart';

part 'productDetailState.freezed.dart';

@freezed
class ProductDetailState with _$ProductDetailState {
  factory ProductDetailState(
      {int? currentIndex,
      required List<Product>? product}) = _ProductDetailState;

  factory ProductDetailState.initial() =>
      ProductDetailState(currentIndex: 0, product: []);
}
