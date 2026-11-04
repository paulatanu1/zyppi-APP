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
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/product_details/presentation/product_details_screen.dart';

import '../helpers/fake_repositories.dart';

final _apples = Product(
  id: 'p1',
  name: 'Shimla Apples',
  categoryId: 'c1',
  description: 'Crisp and sweet.',
  variants: [
    ProductVariant(id: 'v500', label: '500 g', pricePaise: 9500),
    ProductVariant(
      id: 'v1kg',
      label: '1 kg',
      pricePaise: 17900,
      mrpPaise: 19900,
    ),
  ],
);

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('product_screen_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    ThemeData? theme,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final catalog = FakeCatalog([_apples]);
    final container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          CachedCatalogRepository(catalog),
        ),
        ...await cartAndFavouritesOverrides(tester, catalog: catalog),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: theme ?? ZyppiTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const ProductDetailsScreen(productId: 'p1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('shows the first pack size; switching updates the price', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Shimla Apples'), findsOneWidget);
    expect(find.text('500 g'), findsOneWidget);
    expect(find.text('1 kg'), findsOneWidget);
    expect(find.text('inclusiveOfTaxes'), findsOneWidget);
    // ₹95: headline price, pack-size card and bottom bar.
    expect(find.text('₹95'), findsNWidgets(3));

    await tester.tap(find.text('1 kg'));
    await tester.pumpAndSettle();
    expect(find.text('₹179'), findsNWidgets(3));
    expect(find.text('mrpPrice'), findsOneWidget);
    expect(find.text('offPercent'), findsOneWidget);
  });

  testWidgets('Add to basket adds the selected pack; stepper edits it', (
    tester,
  ) async {
    final container = await pumpScreen(tester);
    await tester.tap(find.text('1 kg'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('addToBasket'));
    await tester.pumpAndSettle();
    var lines = container.read(cartProvider).lines;
    expect(lines.single.variant.id, 'v1kg');
    expect(lines.single.quantity, 1);
    expect(find.text('addToBasket'), findsNothing);

    await tester.tap(find.bySemanticsLabel('addOne'));
    await tester.tap(find.bySemanticsLabel('addOne'));
    await tester.pumpAndSettle();
    lines = container.read(cartProvider).lines;
    expect(lines.single.quantity, 3);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.bySemanticsLabel('removeOne'));
    }
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).lines, isEmpty);
    expect(find.text('addToBasket'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
