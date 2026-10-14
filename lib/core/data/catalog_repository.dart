import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

/// Shared by home_screen, explore, product_details, search and
/// favourites — the catalog is cross-feature, so it lives in core/
/// rather than any one feature's domain/ (CLAUDE.md: "features import
/// only core/ and themselves").
abstract class CatalogRepository {
  Future<List<Category>> fetchCategories();

  Future<List<Product>> fetchProducts();

  Future<Product?> fetchProductById(String id);
}
