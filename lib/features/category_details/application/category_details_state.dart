import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

part 'category_details_state.freezed.dart';

@freezed
abstract class CategoryDetailsState with _$CategoryDetailsState {
  factory CategoryDetailsState({
    Category? category,

    /// The category's sub-categories (left rail); empty hides the rail.
    @Default([]) List<Category> subcategories,

    /// Rail selection; null = "All".
    String? selectedSubcategoryId,
    @Default([]) List<Product> products,
    @Default(true) bool loading,
    String? error,
  }) = _CategoryDetailsState;
}

extension CategoryDetailsView on CategoryDetailsState {
  /// [products] narrowed to the selected sub-category ("All" = every one).
  List<Product> get visibleProducts {
    final sub = selectedSubcategoryId;
    if (sub == null) return products;
    return products.where((p) => p.subcategoryId == sub).toList();
  }
}
