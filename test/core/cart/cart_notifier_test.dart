import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/cart_item.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

final _appleKg = ProductVariant(id: 'v1', label: '1 kg', pricePaise: 10000);
final _apple = Product(
  id: 'p1',
  name: 'Apple',
  categoryId: 'c1',
  variants: [_appleKg],
);
final _pearKg = ProductVariant(id: 'v2', label: '1 kg', pricePaise: 5000);
final _pear = Product(
  id: 'p2',
  name: 'Pear',
  categoryId: 'c1',
  variants: [_pearKg],
);

class _CountingCatalog implements CatalogRepository {
  int calls = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    calls++;
    return [_apple, _pear];
  }

  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    calls++;
    return [_apple, _pear].where((p) => ids.contains(p.id)).toList();
  }

  @override
  Future<List<Category>> fetchCategories() async => [];

  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async => [];

  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> searchProducts(String query) async => [];
}

class _FakeCoupons implements CouponRepository {
  @override
  Future<Coupon?> findByCode(String code, {String? serviceAreaId}) async =>
      null;
}

/// The server cart, in memory.
class _FakeRemote implements CartRepository {
  final Map<String, CartItem> server = {};
  final List<CartItem> writes = [];
  bool fail = false;

  @override
  Future<List<CartItem>> getItems() async {
    if (fail) throw Exception('offline');
    return server.values.toList();
  }

  @override
  Future<void> setQuantity(CartItem item) async {
    writes.add(item);
    if (fail) throw Exception('offline');
    if (item.quantity == 0) {
      server.remove(item.variantId);
    } else {
      server[item.variantId] = item;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // AppLifecycleListener

  late Directory dir;
  late LocalCartStore store;
  late _FakeRemote remote;
  late _CountingCatalog catalog;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('cart_test');
    Hive.init(dir.path);
  });

  tearDownAll(() => dir.delete(recursive: true));

  var boxCount = 0;
  setUp(() async {
    // In-memory box: no disk IO to fight with fakeAsync.
    store = LocalCartStore(
      await Hive.openBox('cart${boxCount++}', bytes: Uint8List(0)),
    );
    remote = _FakeRemote();
    catalog = _CountingCatalog();
  });

  CartNotifier build({bool withRemote = true}) =>
      CartNotifier(store, withRemote ? remote : null, catalog, _FakeCoupons());

  testWidgets('a tap updates the cart and device copy synchronously', (
    tester,
  ) async {
    final cart = build();
    await tester.pump();

    cart.setQuantity(product: _apple, variant: _appleKg, quantity: 2);

    // No time has passed and nothing was awaited.
    expect(cart.state.lines.single.quantity, 2);
    expect(cart.state.bill.itemTotalPaise, 20000);
    expect(store.readLines().single.quantity, 2);
    expect(remote.writes, isEmpty);

    cart.dispose();
  });

  testWidgets('rapid taps cost one server write with the final quantity', (
    tester,
  ) async {
    final cart = build();
    await tester.pump();

    for (var q = 1; q <= 3; q++) {
      cart.setQuantity(product: _apple, variant: _appleKg, quantity: q);
    }
    await tester.pump(CartNotifier.pushDebounce);

    expect(remote.writes, hasLength(1));
    expect(remote.writes.single.quantity, 3);
    expect(store.dirtyVariantIds(), isEmpty);

    cart.dispose();
  });

  testWidgets('a failed sync keeps the local cart and retries with backoff', (
    tester,
  ) async {
    final cart = build();
    await tester.pump();
    remote.fail = true;

    cart.setQuantity(product: _apple, variant: _appleKg, quantity: 1);
    await tester.pump(CartNotifier.pushDebounce);

    expect(remote.writes, hasLength(1));
    expect(cart.state.lines.single.quantity, 1); // not reverted
    expect(store.dirtyVariantIds(), {'v1'});

    remote.fail = false;
    await tester.pump(const Duration(seconds: 2));

    expect(remote.writes, hasLength(2));
    expect(remote.server['v1']?.quantity, 1);
    expect(store.dirtyVariantIds(), isEmpty);

    cart.dispose();
  });

  testWidgets(
    'startup merge: server wins for synced lines, device for unsynced',
    (tester) async {
      store.writeLines([
        CartLine(product: _apple, variant: _appleKg, quantity: 1),
        CartLine(product: _pear, variant: _pearKg, quantity: 2),
      ]);
      store.markDirty('v2'); // pear changed offline
      remote.server['v1'] = CartItem(
        productId: 'p1',
        variantId: 'v1',
        quantity: 5,
      );
      remote.server['v2'] = CartItem(
        productId: 'p2',
        variantId: 'v2',
        quantity: 9,
      );

      final cart = build();
      await tester.pump();

      final byVariant = {for (final l in cart.state.lines) l.variant.id: l};
      expect(byVariant['v1']!.quantity, 5);
      expect(byVariant['v2']!.quantity, 2);
      expect(remote.server['v2']!.quantity, 2); // pushed up
      expect(catalog.calls, 1); // one batched read to refresh prices

      cart.dispose();
    },
  );

  testWidgets('sync refreshes a stale price saved on the device', (
    tester,
  ) async {
    final stale = ProductVariant(id: 'v1', label: '1 kg', pricePaise: 9000);
    store.writeLines([CartLine(product: _apple, variant: stale, quantity: 1)]);
    remote.server['v1'] = CartItem(
      productId: 'p1',
      variantId: 'v1',
      quantity: 1,
    );

    final cart = build();
    await tester.pump();

    expect(cart.state.lines.single.variant.pricePaise, 10000);
    expect(cart.state.bill.itemTotalPaise, 10000);

    cart.dispose();
  });

  testWidgets('clear resets tip and coupon for the next order', (tester) async {
    final cart = build(withRemote: false);
    cart.setQuantity(product: _apple, variant: _appleKg, quantity: 1);
    cart.setTip(3000);

    await tester.runAsync(cart.clear);

    expect(cart.state.tipPaise, 0);
    expect(cart.state.appliedCoupon, isNull);
    expect(cart.state.lines, isEmpty);

    cart.dispose();
  });

  test('cold start shows the saved cart without loading or catalog', () {
    store.writeLines([
      CartLine(product: _apple, variant: _appleKg, quantity: 3),
    ]);

    final cart = build(withRemote: false);

    expect(cart.state.loading, isFalse);
    expect(cart.state.lines.single.quantity, 3);
    expect(catalog.calls, 0);

    cart.dispose();
  });

  testWidgets('flush pushes pending changes now and throws when offline', (
    tester,
  ) async {
    final cart = build();
    await tester.pump();

    cart.setQuantity(product: _apple, variant: _appleKg, quantity: 4);
    cart.flush();
    await tester.pump();
    expect(remote.server['v1']?.quantity, 4); // before the debounce

    remote.fail = true;
    cart.setQuantity(product: _apple, variant: _appleKg, quantity: 5);
    Object? error;
    cart.flush().catchError((Object e) => error = e);
    await tester.pump();
    expect(error, isA<StateError>());

    cart.dispose();
  });
}
