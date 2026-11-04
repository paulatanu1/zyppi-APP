import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';
import 'package:zippy/core/favourites/domain/favourites_repository.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

final _kg = ProductVariant(
  id: 'v1',
  label: '1 kg',
  pricePaise: 17900,
  mrpPaise: 19900,
);
final _apple = Product(
  id: 'p1',
  name: 'Shimla Apples',
  categoryId: 'c1',
  variants: [_kg],
);
final _noVariant = Product(
  id: 'p2',
  name: 'Out of season',
  categoryId: 'c1',
  variants: const [],
);

class _NoCatalog implements CatalogRepository {
  @override
  Future<List<Product>> fetchProducts() async => [];
  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async => [];
  @override
  Future<List<Category>> fetchCategories() async => [];
  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async => [];
  @override
  Future<Product?> fetchProductById(String id) async => null;
  @override
  Future<List<Product>> searchProducts(String query) async => [];
}

class _NoCoupons implements CouponRepository {
  @override
  Future<Coupon?> findByCode(String code) async => null;
}

class _MemoryFavourites implements FavouritesRepository {
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

void main() {
  late Directory dir;
  var boxCount = 0;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('catalog_card_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<ProviderContainer> pumpCard(
    WidgetTester tester,
    Product product,
  ) async {
    final box = await tester.runAsync(
      () => Hive.openBox('cart${boxCount++}', bytes: Uint8List(0)),
    );
    final favourites = _MemoryFavourites();
    final container = ProviderContainer(
      overrides: [
        cartProvider.overrideWith(
          (ref) => CartNotifier(
            LocalCartStore(box!),
            null, // guest: local cart only
            _NoCatalog(),
            _NoCoupons(),
          ),
        ),
        favouritesProvider.overrideWith(
          (ref) => FavouritesNotifier(favourites),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ZyppiTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 173,
                child: CatalogProductCard(product: product),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  int quantity(ProviderContainer c) =>
      c.read(cartProvider).lines.fold(0, (sum, l) => sum + l.quantity);

  testWidgets('ADD and the stepper change the cart for the first variant', (
    tester,
  ) async {
    final container = await pumpCard(tester, _apple);
    expect(find.text('1 kg'), findsOneWidget);
    expect(find.text('₹179'), findsOneWidget);

    await tester.tap(find.text('add'));
    await tester.pumpAndSettle();
    expect(quantity(container), 1);
    expect(container.read(cartProvider).lines.single.variant.id, 'v1');

    await tester.tap(find.bySemanticsLabel('addOne'));
    await tester.pumpAndSettle();
    expect(quantity(container), 2);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('removeOne'));
    await tester.tap(find.bySemanticsLabel('removeOne'));
    await tester.pumpAndSettle();
    expect(quantity(container), 0);
    expect(find.text('add'), findsOneWidget);
  });

  testWidgets('heart toggles the favourite', (tester) async {
    final container = await pumpCard(tester, _apple);

    await tester.tap(find.bySemanticsLabel('addToFavourites'));
    await tester.pump();
    expect(container.read(favouritesProvider), {'p1'});
    expect(find.bySemanticsLabel('removeFromFavourites'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('removeFromFavourites'));
    await tester.pump();
    expect(container.read(favouritesProvider), isEmpty);
  });

  testWidgets('a product without variants shows unavailable', (tester) async {
    await pumpCard(tester, _noVariant);
    expect(find.text('productUnavailable'), findsOneWidget);
    expect(find.text('add'), findsNothing);
  });
}
