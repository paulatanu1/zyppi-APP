import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/data/cached_catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

class _CountingCatalog implements CatalogRepository {
  int productCalls = 0;
  int byIdsCalls = 0;
  bool fail = false;

  @override
  Future<List<Product>> fetchProducts() async {
    productCalls++;
    await Future<void>.delayed(Duration.zero);
    if (fail) throw Exception('offline');
    return [
      Product(
        id: 'p1',
        name: 'Apple',
        categoryId: 'c1',
        variants: [ProductVariant(id: 'v1', label: '1 kg', pricePaise: 100)],
      ),
    ];
  }

  @override
  Future<List<Category>> fetchCategories() async => [];

  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async => [];

  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    byIdsCalls++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async => [];
}

void main() {
  late _CountingCatalog inner;
  late DateTime now;
  late CachedCatalogRepository cache;

  setUp(() {
    inner = _CountingCatalog();
    now = DateTime(2026, 11, 1);
    cache = CachedCatalogRepository(inner, now: () => now);
  });

  test('serves repeat reads from memory', () async {
    await cache.fetchProducts();
    await cache.fetchProducts();

    expect(inner.productCalls, 1);
  });

  test('concurrent callers share one request', () async {
    await Future.wait([cache.fetchProducts(), cache.fetchProducts()]);

    expect(inner.productCalls, 1);
  });

  test('re-fetches after invalidate() and after the TTL', () async {
    await cache.fetchProducts();
    cache.invalidate();
    await cache.fetchProducts();
    expect(inner.productCalls, 2);

    now = now.add(CachedCatalogRepository.ttl);
    await cache.fetchProducts();
    expect(inner.productCalls, 3);
  });

  test('does not cache failures', () async {
    inner.fail = true;
    await expectLater(cache.fetchProducts(), throwsException);

    inner.fail = false;
    expect(await cache.fetchProducts(), hasLength(1));
    expect(inner.productCalls, 2);
  });

  test('answers by-id lookups from a fresh product list', () async {
    await cache.fetchProducts();

    expect((await cache.fetchProductById('p1'))?.name, 'Apple');
    expect(await cache.fetchProductsByIds(['p1']), hasLength(1));
    expect(inner.byIdsCalls, 0);
  });
}
