import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

/// Shared by home_screen, explore, product_details, search and
/// favourites — the catalog is cross-feature, so it lives in core/
/// rather than any one feature's domain/ (CLAUDE.md: "features import
/// only core/ and themselves").
abstract class CatalogRepository {
  Future<List<Category>> fetchCategories();

  Future<List<Product>> fetchProducts();

  /// Active products in one category, queried server-side (not by
  /// filtering the whole catalog on the client).
  Future<List<Product>> fetchProductsByCategory(String categoryId);

  Future<Product?> fetchProductById(String id);

  /// Active products among [ids], in no particular order; ids that don't
  /// match an active product are skipped.
  Future<List<Product>> fetchProductsByIds(List<String> ids);

  /// Firebase: prefix match on each product's `keywords` array.
  /// Mock: substring match on product name. Callers should skip calling
  /// this for an empty/blank [query].
  Future<List<Product>> searchProducts(String query);
}

/// Top-level categories vs sub-categories (`Category.parentId`).
extension CategoryTree on List<Category> {
  /// Categories with no parent, by `sortOrder` (ties keep list order).
  List<Category> get topLevel => _sorted((c) => c.parentId == null);

  /// Sub-categories of [parentId], by `sortOrder` (ties keep list order).
  List<Category> childrenOf(String parentId) =>
      _sorted((c) => c.parentId == parentId);

  List<Category> _sorted(bool Function(Category) test) {
    final picked = [
      for (var i = 0; i < length; i++)
        if (test(this[i])) (i, this[i]),
    ];
    picked.sort((a, b) {
      final bySort = a.$2.sortOrder.compareTo(b.$2.sortOrder);
      return bySort != 0 ? bySort : a.$1.compareTo(b.$1);
    });
    return [for (final (_, c) in picked) c];
  }
}
