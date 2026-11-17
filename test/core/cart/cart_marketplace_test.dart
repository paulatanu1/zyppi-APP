import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/cart_item.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/marketplace/domain/marketplace_repository.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/marketplace/domain/seller_profile.dart';

final _milkL = ProductVariant(
  id: 'v1',
  label: '1 L',
  pricePaise: 6000,
  mrpPaise: 6400,
);
final _milk = Product(
  id: 'p1',
  name: 'Milk',
  categoryId: 'c',
  variants: [_milkL],
);

const _sima = OfferPick(
  offerId: 'sima_pur_v1',
  sellerId: 'sima',
  sellerName: 'Sima Store',
  pricePaise: 5800,
  mrpPaise: 6400,
);
const _zyppi = OfferPick(
  offerId: 'zyppi_pur_v1',
  sellerId: 'zyppi',
  sellerName: 'Zyppi',
  pricePaise: 6000,
  mrpPaise: 6400,
);

Offer _offer(String id, String seller, int price) => Offer(
  id: id,
  productId: 'p1',
  variantId: 'v1',
  serviceAreaId: 'pur',
  sellerId: seller,
  sellerName: seller,
  pricePaise: price,
  mrpPaise: 6400,
  regularPricePaise: price,
);

class _Catalog implements CatalogRepository {
  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async => [_milk];
  @override
  Future<List<Product>> fetchProducts() async => [_milk];
  @override
  Future<List<Category>> fetchCategories() async => [];
  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async => [];
  @override
  Future<Product?> fetchProductById(String id) async => _milk;
  @override
  Future<List<Product>> searchProducts(String query) async => [];
}

class _Coupons implements CouponRepository {
  @override
  Future<Coupon?> findByCode(String code, {String? serviceAreaId}) async =>
      null;
}

class _Marketplace implements MarketplaceRepository {
  List<Offer> live = [];

  @override
  Future<List<Offer>> fetchOffers(String productId, String areaId) async =>
      live;
  @override
  Future<List<Offer>> fetchOffersByIds(List<String> ids) async =>
      live.where((o) => ids.contains(o.id)).toList();
  @override
  Future<SellerProfile?> fetchSellerProfile(String sellerId) async => null;
}

/// The server cart, keyed like Firestore: offer id, else variant id.
class _Remote implements CartRepository {
  final Map<String, CartItem> server = {};
  final List<CartItem> writes = [];

  @override
  Future<List<CartItem>> getItems() async => server.values.toList();

  @override
  Future<void> setQuantity(CartItem item) async {
    writes.add(item);
    final id = item.offerId ?? item.variantId;
    item.quantity == 0 ? server.remove(id) : server[id] = item;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late LocalCartStore store;
  late _Remote remote;
  late _Marketplace market;
  var boxes = 0;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('cart_market_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  setUp(() async {
    store = LocalCartStore(
      await Hive.openBox('m${boxes++}', bytes: Uint8List(0)),
    );
    remote = _Remote();
    market = _Marketplace();
  });

  CartNotifier build() =>
      CartNotifier(store, remote, _Catalog(), _Coupons(), marketplace: market);

  testWidgets(
    'the same pack from Zyppi and a seller is two lines, priced apart',
    (tester) async {
      final cart = build();
      await tester.pump();

      cart.addItem(product: _milk, variant: _milkL);
      cart.addItem(product: _milk, variant: _milkL, offer: _sima, quantity: 2);

      expect(cart.state.lines.map((l) => (l.key, l.quantity)).toList(), [
        ('v1', 1),
        ('sima_pur_v1', 2),
      ]);
      expect(cart.state.bill.itemTotalPaise, 6000 + 2 * 5800);
      expect(cart.quantityOf('p1', 'v1'), 1);
      expect(cart.quantityOf('p1', 'v1', offer: _sima), 2);

      // Zyppi's own offer stays a variant-keyed line (the server reads it as
      // Zyppi's stock).
      cart.addItem(product: _milk, variant: _milkL, offer: _zyppi);
      expect(cart.quantityOf('p1', 'v1'), 2);
      expect(cart.state.lines, hasLength(2));
      cart.dispose();
    },
  );

  testWidgets(
    'pushes seller lines under their offer id, Zyppi lines as before',
    (tester) async {
      final cart = build();
      await tester.pump();

      cart.addItem(product: _milk, variant: _milkL);
      cart.addItem(product: _milk, variant: _milkL, offer: _sima);
      await tester.pump(CartNotifier.pushDebounce);

      expect(remote.server.keys.toSet(), {'v1', 'sima_pur_v1'});
      expect(remote.server['v1']!.offerId, isNull);
      expect(remote.server['sima_pur_v1']!.variantId, 'v1');

      cart.setQuantity(
        product: _milk,
        variant: _milkL,
        offer: _sima,
        quantity: 0,
      );
      await tester.pump(CartNotifier.pushDebounce);
      expect(remote.server.keys, ['v1']);
      cart.dispose();
    },
  );

  testWidgets('removeOne takes from the preferred seller, else the last line', (
    tester,
  ) async {
    final cart = build();
    await tester.pump();
    cart.addItem(product: _milk, variant: _milkL, quantity: 2);
    cart.addItem(product: _milk, variant: _milkL, offer: _sima);

    cart.removeOne(product: _milk, variant: _milkL, prefer: _sima);
    expect(cart.quantityOf('p1', 'v1', offer: _sima), 0);
    cart.removeOne(product: _milk, variant: _milkL, prefer: _sima);
    expect(cart.quantityOf('p1', 'v1'), 1);
    cart.dispose();
  });

  testWidgets(
    "pull refreshes a seller's price and drops offers that are gone",
    (tester) async {
      remote.server['sima_pur_v1'] = CartItem(
        productId: 'p1',
        variantId: 'v1',
        quantity: 1,
        offerId: 'sima_pur_v1',
      );
      remote.server['gone_pur_v1'] = CartItem(
        productId: 'p1',
        variantId: 'v1',
        quantity: 1,
        offerId: 'gone_pur_v1',
      );
      market.live = [_offer('sima_pur_v1', 'sima', 5500)];

      final cart = build();
      await tester.pumpAndSettle();

      final line = cart.state.lines.single;
      expect(line.key, 'sima_pur_v1');
      expect(line.unitPricePaise, 5500);
      expect(cart.state.bill.itemTotalPaise, 5500);
      cart.dispose();
    },
  );

  test('a seller line survives the device copy (JSON round trip)', () async {
    final cart = CartNotifier(store, null, _Catalog(), _Coupons());
    cart.addItem(product: _milk, variant: _milkL, offer: _sima);
    final again = store.readLines().single;
    expect(again.offer, _sima);
    expect(again.lineTotalPaise, 5800);
    cart.dispose();
  });
}
