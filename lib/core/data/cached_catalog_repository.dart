import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

/// In-memory cache in front of either catalog implementation. Every screen
/// (home, explore, category, cart, favourites) used to re-fetch the whole
/// catalog on each visit; on a ~1s round trip that made every action slow.
/// Concurrent callers share one in-flight request. Search always hits the
/// server.
class CachedCatalogRepository implements CatalogRepository {
  static const ttl = Duration(minutes: 5);

  final CatalogRepository inner;
  final DateTime Function() _now;

  CachedCatalogRepository(this.inner, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  _Entry<List<Category>>? _categories;
  _Entry<List<Product>>? _products;

  /// Drops cached data, e.g. on pull-to-refresh / retry.
  void invalidate() {
    _categories = null;
    _products = null;
  }

  @override
  Future<List<Category>> fetchCategories() {
    final entry = _categories;
    if (entry != null && entry.isFresh(_now())) return entry.future;

    return (_categories = _Entry(
      inner.fetchCategories(),
      _now(),
      onError: () => _categories = null,
    )).future;
  }

  @override
  Future<List<Product>> fetchProducts() {
    final entry = _products;
    if (entry != null && entry.isFresh(_now())) return entry.future;

    return (_products = _Entry(
      inner.fetchProducts(),
      _now(),
      onError: () => _products = null,
    )).future;
  }

  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    if (_products?.isFresh(_now()) ?? false) {
      return (await fetchProducts())
          .where((p) => p.categoryId == categoryId)
          .toList();
    }

    return inner.fetchProductsByCategory(categoryId);
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    if (_products?.isFresh(_now()) ?? false) {
      for (final product in await fetchProducts()) {
        if (product.id == id) return product;
      }
    }

    return inner.fetchProductById(id);
  }

  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    if (_products?.isFresh(_now()) ?? false) {
      final wanted = ids.toSet();
      return (await fetchProducts())
          .where((p) => wanted.contains(p.id))
          .toList();
    }

    return inner.fetchProductsByIds(ids);
  }

  @override
  Future<List<Product>> searchProducts(String query) =>
      inner.searchProducts(query);
}

class _Entry<T> {
  final Future<T> future;
  final DateTime fetchedAt;

  _Entry(Future<T> future, this.fetchedAt, {required void Function() onError})
    : future = future.catchError((Object error) {
        // Don't cache failures; the next call retries.
        onError();
        throw error;
      });

  bool isFresh(DateTime now) =>
      now.difference(fetchedAt) < CachedCatalogRepository.ttl;
}
