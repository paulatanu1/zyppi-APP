import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/application/reorder.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

/// Only "milk" is still sold, now at a new price.
class _Catalog implements CatalogRepository {
  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async => [
    Product(
      id: 'milk',
      name: 'Milk',
      categoryId: 'c',
      variants: [ProductVariant(id: 'milk-1l', label: '1 L', pricePaise: 7000)],
    ),
  ];

  @override
  Future<List<Product>> fetchProducts() async => [];
  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async => [];
  @override
  Future<List<Category>> fetchCategories() async => [];
  @override
  Future<Product?> fetchProductById(String id) async => null;
  @override
  Future<List<Product>> searchProducts(String query) async => [];
}

class _Coupons implements CouponRepository {
  @override
  Future<Coupon?> findByCode(String code, {String? serviceAreaId}) async =>
      null;
}

OrderItem _item(String product, String variant, int qty) => OrderItem(
  productId: product,
  variantId: variant,
  name: product,
  unit: '1',
  quantity: qty,
  pricePaise: 5000,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('reorder_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  test(
    'adds what is still sold, at today\'s price, and skips the rest',
    () async {
      final box = await Hive.openBox('reorder', bytes: Uint8List(0));
      final cart = CartNotifier(
        LocalCartStore(box),
        null,
        _Catalog(),
        _Coupons(),
      );
      final order = Order(
        id: 'o1',
        items: [
          _item('milk', 'milk-1l', 2),
          _item('bread', 'bread-1', 1), // discontinued
          _item('milk', 'milk-500ml', 1), // variant gone
        ],
        status: OrderStatus.delivered,
        placedAt: DateTime(2026),
        itemTotalPaise: 0,
        deliveryFeePaise: 0,
        handlingFeePaise: 0,
        tipPaise: 0,
        discountPaise: 0,
        totalPaise: 0,
        paymentMethod: 'UPI',
      );

      final result = await reorderToCart(
        order: order,
        catalog: _Catalog(),
        cart: cart,
      );

      expect(result.added, 1);
      expect(result.skipped, 2);
      expect(cart.state.lines.single.quantity, 2);
      expect(cart.state.lines.single.variant.pricePaise, 7000);
      cart.dispose();
    },
  );
}
