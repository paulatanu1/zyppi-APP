import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

import '../../helpers/fake_repositories.dart';

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

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('catalog_card_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<ProviderContainer> pumpCard(
    WidgetTester tester,
    Product product,
  ) async {
    final container = ProviderContainer(
      overrides: await cartAndFavouritesOverrides(tester),
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

  testWidgets('the same product twice on a screen gets distinct hero tags', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: await cartAndFavouritesOverrides(tester),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ZyppiTheme.light,
          home: Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 173,
                  child: CatalogProductCard(product: _apple),
                ),
                SizedBox(
                  width: 173,
                  child: CatalogProductCard(product: _apple),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final tags = tester.widgetList<Hero>(find.byType(Hero)).map((h) => h.tag);
    expect(tags, hasLength(2));
    expect(tags.toSet(), hasLength(2));
    expect(tags.every((t) => '$t'.startsWith('product-p1-')), isTrue);
  });
}
