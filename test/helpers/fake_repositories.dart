import 'dart:typed_data';

import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';
import 'package:zippy/core/favourites/domain/favourites_repository.dart';

/// Catalog serving a fixed product list.
class FakeCatalog implements CatalogRepository {
  FakeCatalog([this.products = const []]);
  final List<Product> products;

  @override
  Future<List<Product>> fetchProducts() async => products;
  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async =>
      products.where((p) => ids.contains(p.id)).toList();
  @override
  Future<List<Category>> fetchCategories() async => [];
  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async =>
      products.where((p) => p.categoryId == categoryId).toList();
  @override
  Future<Product?> fetchProductById(String id) async =>
      products.where((p) => p.id == id).firstOrNull;
  @override
  Future<List<Product>> searchProducts(String query) async => products
      .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

class NoCoupons implements CouponRepository {
  @override
  Future<Coupon?> findByCode(String code) async => null;
}

class MemoryFavourites implements FavouritesRepository {
  final ids = <String>{};
  @override
  Future<Set<String>> getIds() async => {...ids};
  @override
  Future<void> add(String productId) async => ids.add(productId);
  @override
  Future<void> remove(String productId) async => ids.remove(productId);
  @override
  Stream<void> watch() => const Stream.empty();
}

var _boxCount = 0;

/// Cart (guest: local Hive store, no remote) and favourites overrides.
/// Call `Hive.init` in `setUpAll` first.
Future<List<Override>> cartAndFavouritesOverrides(
  WidgetTester tester, {
  CatalogRepository? catalog,
}) async {
  final box = await tester.runAsync(
    () => Hive.openBox('cart${_boxCount++}', bytes: Uint8List(0)),
  );
  final favourites = MemoryFavourites();
  return [
    cartProvider.overrideWith(
      (ref) => CartNotifier(
        LocalCartStore(box!),
        null,
        catalog ?? FakeCatalog(),
        NoCoupons(),
      ),
    ),
    favouritesProvider.overrideWith((ref) => FavouritesNotifier(favourites)),
  ];
}
