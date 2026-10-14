import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

part 'category_details_state.freezed.dart';

@freezed
abstract class CategoryDetailsState with _$CategoryDetailsState {
  factory CategoryDetailsState({
    Category? category,
    @Default([]) List<Product> products,
    @Default(true) bool loading,
    String? error,
  }) = _CategoryDetailsState;
}
