import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/data/cached_catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/marketplace/application/marketplace_providers.dart';
import 'package:zippy/core/marketplace/data/marketplace_repository_impl.dart';
import 'package:zippy/core/marketplace/domain/marketplace_repository.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/marketplace/domain/seller_profile.dart';
import 'package:zippy/core/marketplace/presentation/seller_screen.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/product_details/presentation/product_details_screen.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_app.dart';

Offer _offer(
  String seller,
  int price, {
  bool inStock = true,
  double rank = 0.5,
}) => Offer(
  id: '${seller}_pur_v1',
  productId: 'p1',
  variantId: 'v1',
  serviceAreaId: 'pur',
  sellerId: seller,
  sellerName: seller == 'zyppi' ? 'Zyppi' : 'Sima Store',
  sellerRating: 4.6,
  ratingCount: seller == 'zyppi' ? 0 : 40,
  pricePaise: price,
  mrpPaise: 6400,
  regularPricePaise: price,
  inStock: inStock,
  rankScore: rank,
);

final _milk = Product(
  id: 'p1',
  name: 'Toned Milk',
  categoryId: 'c1',
  variants: [
    ProductVariant(id: 'v1', label: '1 L', pricePaise: 6000, mrpPaise: 6400),
  ],
  areaBest: {
    'pur': {
      'v1': const BestOffer(
        offerId: 'sima_pur_v1',
        sellerId: 'sima',
        sellerName: 'Sima Store',
        pricePaise: 5800,
        mrpPaise: 6400,
        offerCount: 2,
      ),
    },
  },
);

class _Market implements MarketplaceRepository {
  _Market(this.offers);
  final List<Offer> offers;

  @override
  Future<List<Offer>> fetchOffers(String productId, String areaId) async =>
      offers;
  @override
  Future<List<Offer>> fetchOffersByIds(List<String> ids) async =>
      offers.where((o) => ids.contains(o.id)).toList();
  @override
  Future<SellerProfile?> fetchSellerProfile(String sellerId) async => null;
}

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('product_market_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required List<Offer> offers,
    String? area = 'pur',
    ThemeData? theme,
    double textScale = 1,
  }) async {
    final catalog = FakeCatalog([_milk]);
    final container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          CachedCatalogRepository(catalog),
        ),
        marketplaceRepositoryProvider.overrideWithValue(_Market(offers)),
        ...await cartAndFavouritesOverrides(tester, catalog: catalog),
      ],
    );
    addTearDown(container.dispose);
    container.read(shoppingAreaIdProvider.notifier).set(area);
    // Real English strings: the "+1 more seller" plural needs a locale.
    await pumpLocalizedApp(
      tester,
      container: container,
      theme: theme,
      textScale: textScale,
      home: const ProductDetailsScreen(productId: 'p1'),
    );
    return container;
  }

  testWidgets('sells the best match, names the seller and lists the others', (
    tester,
  ) async {
    final container = await pump(
      tester,
      offers: [_offer('sima', 5800, rank: 0.9), _offer('zyppi', 6000)],
    );

    // Headline and bottom bar (one pack size: no pack cards).
    expect(find.text('₹58'), findsNWidgets(2));
    expect(find.textContaining('Sold by Sima Store'), findsOneWidget);
    expect(find.textContaining('4.6'), findsOneWidget);
    expect(find.text('+1 more seller'), findsOneWidget);

    await tester.tap(find.text('Add To Basket'));
    await tester.pumpAndSettle();
    final line = container.read(cartProvider).lines.single;
    expect(line.offer?.sellerId, 'sima');
    expect(line.lineTotalPaise, 5800);
  });

  testWidgets('picking Zyppi in the sheet switches price and the cart line', (
    tester,
  ) async {
    final container = await pump(
      tester,
      offers: [_offer('sima', 5800, rank: 0.9), _offer('zyppi', 6000)],
    );

    await tester.tap(find.text('+1 more seller'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a seller'), findsOneWidget);
    expect(find.text('Best match'), findsOneWidget);
    expect(find.text('New seller'), findsOneWidget); // Zyppi has no ratings yet
    await tester.tap(find.text('Zyppi'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a seller'), findsNothing);
    expect(find.text('₹60'), findsNWidgets(2)); // headline + bottom bar
    expect(find.textContaining('Sold by Zyppi'), findsOneWidget);
    await tester.tap(find.text('Add To Basket'));
    await tester.pumpAndSettle();
    // Zyppi's line stays variant-keyed, as before the marketplace.
    final line = container.read(cartProvider).lines.single;
    expect(line.offer, isNull);
    expect(line.key, 'v1');
  });

  testWidgets("a sold-out seller can't be added", (tester) async {
    await pump(tester, offers: [_offer('sima', 5800, inStock: false)]);
    // The best match is out of stock and nobody else sells it here.
    expect(find.text('Out of stock'), findsNWidgets(2)); // note + button
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('without an area (or offers) it is Zyppi only, as before', (
    tester,
  ) async {
    await pump(tester, offers: const [], area: null);
    expect(find.text('₹60'), findsNWidgets(2));
    expect(find.textContaining('Sold by'), findsNothing);
  });

  test('chooseOffer: pick, else best in stock, else first in stock', () {
    final a = _offer('sima', 5800, inStock: false);
    final b = _offer('zyppi', 6000);
    expect(chooseOffer(const [], picked: null, best: null), isNull);
    expect(chooseOffer([a, b], picked: null, best: a.id), b);
    expect(chooseOffer([a, b], picked: a.id, best: null), a);
    expect(chooseOffer([b, a], picked: null, best: b.id), b);
  });

  test('cardPrice uses the area best, keeps Zyppi lines offer-less', () {
    final v = _milk.variants.single;
    expect(cardPrice(_milk, v, 'pur'), (
      price: 5800,
      mrp: 6400,
      pick: _milk.areaBest['pur']!['v1']!.pick,
    ));
    expect(cardPrice(_milk, v, 'rag'), (price: 6000, mrp: 6400, pick: null));
    final zyppiBest = _milk.copyWith(
      areaBest: {
        'pur': {
          'v1': const BestOffer(
            offerId: 'zyppi_pur_v1',
            sellerId: 'zyppi',
            pricePaise: 6000,
            mrpPaise: 6400,
          ),
        },
      },
    );
    expect(cardPrice(zyppiBest, v, 'pur').pick, isNull);
  });

  testWidgets('dark theme and large text: details and sheet lay out', (
    tester,
  ) async {
    await pump(
      tester,
      offers: [_offer('sima', 5800, rank: 0.9), _offer('zyppi', 6000)],
      theme: ZyppiTheme.dark,
      textScale: 1.6,
    );
    await tester.tap(find.text('+1 more seller'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a seller'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seller page: details, and a gone seller', (tester) async {
    final container = ProviderContainer(
      overrides: [
        marketplaceRepositoryProvider.overrideWithValue(_ProfileMarket()),
      ],
    );
    addTearDown(container.dispose);
    await pumpLocalizedApp(
      tester,
      container: container,
      theme: ZyppiTheme.dark,
      home: const SellerScreen(sellerId: 'sima'),
    );
    expect(find.text('Sima Store'), findsOneWidget);
    expect(find.text('Station Road, Purulia'), findsOneWidget);
    expect(find.text('12345678901234'), findsOneWidget);

    await pumpLocalizedApp(
      tester,
      container: container,
      home: const SellerScreen(sellerId: 'gone'),
    );
    expect(
      find.text("This seller isn't selling on Zyppi right now."),
      findsOneWidget,
    );
  });
}

class _ProfileMarket extends _Market {
  _ProfileMarket() : super(const []);

  @override
  Future<SellerProfile?> fetchSellerProfile(String sellerId) async =>
      sellerId == 'sima'
      ? const SellerProfile(
          id: 'sima',
          shopName: 'Sima Store',
          address: 'Station Road, Purulia',
          phone: '+919800022222',
          fssaiNo: '12345678901234',
          ratingAvg: 4.6,
          ratingCount: 40,
        )
      : null;
}
