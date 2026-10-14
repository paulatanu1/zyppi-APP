import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<Category>> fetchCategories() async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList(
      'assets/mock/categories.json',
    );

    return json
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Product>> fetchProducts() async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList('assets/mock/products.json');

    return json
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    final products = await fetchProducts();

    for (final product in products) {
      if (product.id == id) return product;
    }

    return null;
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => MockCatalogRepository(),
);
