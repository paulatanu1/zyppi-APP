import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

part 'category_details_state.freezed.dart';

/// The product page: every category (for the left menu), the selected
/// top-level category ([parentId], null = All) and sub-category ([subId],
/// null = all of the parent), and the parent's products.
@freezed
abstract class CategoryDetailsState with _$CategoryDetailsState {
  const CategoryDetailsState._();

  factory CategoryDetailsState({
    @Default([]) List<Category> categories,
    String? parentId,
    String? subId,
    @Default([]) List<Product> products,
    @Default(true) bool loading,
    String? error,
  }) = _CategoryDetailsState;

  /// The selected top-level category; null for All (or not found).
  Category? get category {
    for (final c in categories) {
      if (c.id == parentId) return c;
    }
    return null;
  }

  /// The parent's sub-categories (empty for All or a flat category).
  List<Category> get subcategories =>
      parentId == null ? const [] : categories.childrenOf(parentId!);

  /// The left menu lists sub-categories when the parent has some, and
  /// every top-level category otherwise.
  bool get menuShowsSubcategories => subcategories.isNotEmpty;

  /// Products of the selected sub-category, or all of the parent's.
  List<Product> get visibleProducts => subId == null
      ? products
      : [
          for (final p in products)
            if (p.subcategoryId == subId) p,
        ];

  /// Key for per-selection state such as the product filter.
  String get selectionKey => subId ?? parentId ?? '';
}
