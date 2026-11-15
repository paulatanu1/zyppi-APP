import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/data/cached_catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/order/domain/order_repository.dart';
import 'package:zippy/features/home_screen/application/buy_again_provider.dart';

import '../helpers/fake_repositories.dart';

class _Orders implements OrderRepository {
  _Orders(this.orders, {this.fail = false});
  final List<Order> orders;
  final bool fail;

  @override
  Future<List<Order>> getOrders() async =>
      fail ? throw StateError('offline') : orders;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Order _order(String id, OrderStatus status, DateTime at, List<String> pids) =>
    Order(
      id: id,
      status: status,
      placedAt: at,
      items: [
        for (final p in pids)
          OrderItem(
            productId: p,
            variantId: 'v$p',
            name: p,
            unit: '1',
            quantity: 1,
            pricePaise: 100,
          ),
      ],
      itemTotalPaise: 0,
      deliveryFeePaise: 0,
      handlingFeePaise: 0,
      tipPaise: 0,
      discountPaise: 0,
      totalPaise: 0,
      paymentMethod: 'COD',
    );

Product _product(String id) => Product(
  id: id,
  name: id,
  categoryId: 'c1',
  variants: [ProductVariant(id: 'v$id', label: '1', pricePaise: 100)],
);

Future<List<Product>> _read(OrderRepository orders) async {
  final container = ProviderContainer(
    overrides: [
      orderRepositoryProvider.overrideWithValue(orders),
      catalogRepositoryProvider.overrideWithValue(
        // 'gone' is no longer in the catalog.
        CachedCatalogRepository(FakeCatalog([_product('a'), _product('b')])),
      ),
    ],
  );
  addTearDown(container.dispose);
  final sub = container.listen(buyAgainProvider, (_, _) {});
  addTearDown(sub.close);
  return container.read(buyAgainProvider.future);
}

void main() {
  test('delivered orders only, newest first, unavailable dropped', () async {
    final products = await _read(
      _Orders([
        _order('1', OrderStatus.delivered, DateTime(2026, 1, 1), ['a']),
        _order('2', OrderStatus.delivered, DateTime(2026, 2, 1), ['b', 'gone']),
        _order('3', OrderStatus.cancelled, DateTime(2026, 3, 1), ['x']),
      ]),
    );
    expect(products.map((p) => p.id), ['b', 'a']);
  });

  test('hides (empty) when orders cannot be read', () async {
    expect(await _read(_Orders(const [], fail: true)), isEmpty);
  });
}
