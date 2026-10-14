import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/product.dart';

part 'product_detail_state.freezed.dart';

@freezed
abstract class ProductDetailState with _$ProductDetailState {
  factory ProductDetailState({
    Product? product,
    int? currentIndex,
    @Default(1) int quantity,
    @Default(true) bool loading,
    String? error,
  }) = _ProductDetailState;

  factory ProductDetailState.initial() =>
      ProductDetailState(currentIndex: 0, loading: true);
}
