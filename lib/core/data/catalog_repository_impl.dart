import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/cached_catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/firebase_catalog_repository_impl.dart';
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
  Future<List<Product>> fetchProductsByCategory(String categoryId) async =>
      (await fetchProducts()).where((p) => p.categoryId == categoryId).toList();

  @override
  Future<Product?> fetchProductById(String id) async {
    final products = await fetchProducts();

    for (final product in products) {
      if (product.id == id) return product;
    }

    return null;
  }

  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    final wanted = ids.toSet();
    final products = await fetchProducts();

    return products.where((p) => wanted.contains(p.id)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final products = await fetchProducts();

    return products
        .where((p) => p.name.toLowerCase().contains(normalized))
        .toList();
  }
}

/// Typed as the cache so pull-to-refresh can call `invalidate()`.
final catalogRepositoryProvider = Provider<CachedCatalogRepository>(
  (ref) => CachedCatalogRepository(
    Env.isMockDataSource
        ? MockCatalogRepository()
        : FirebaseCatalogRepository(FirebaseFirestore.instance),
  ),
);
