import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/product_detail.dart';

part 'product_detail_state.freezed.dart';

@freezed
abstract class ProductDetailState with _$ProductDetailState {
  factory ProductDetailState({
    int? currentIndex,
    required List<Product>? product,
  }) = _ProductDetailState;

  factory ProductDetailState.initial() =>
      ProductDetailState(currentIndex: 0, product: []);
}
