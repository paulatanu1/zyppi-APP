import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/data/cached_catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_product_card.dart';
import 'package:zippy/features/category_details/application/category_details_provider.dart';
import 'package:zippy/features/category_details/presentation/category_details_screen.dart';
import 'package:zippy/features/category_details/widgets/category_rail.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_app.dart';

Category _cat(String id, String name, {String? parent, int sort = 0}) =>
    Category(
      id: id,
      name: name,
      colorHex: 'FFEEEEEE',
      borderColorHex: 'FFDDDDDD',
      parentId: parent,
      sortOrder: sort,
    );

Product _prod(String id, String cat, {String? sub}) => Product(
  id: id,
  name: 'Item $id',
  categoryId: cat,
  subcategoryId: sub,
  variants: [ProductVariant(id: '$id-v', label: '1 pc', pricePaise: 1000)],
);

final _categories = [
  _cat('fruit', 'Fruits & Veg', sort: 1),
  _cat('dairy', 'Dairy'), // flat: no sub-categories
  _cat('veg', 'Vegetables', parent: 'fruit', sort: 1),
  _cat('fresh', 'Fresh Fruits', parent: 'fruit'),
];
final _products = [
  _prod('apple', 'fruit', sub: 'fresh'),
  _prod('onion', 'fruit', sub: 'veg'),
  _prod('milk', 'dairy'),
];

class _Catalog extends FakeCatalog {
  _Catalog() : super(_products);

  @override
  Future<List<Category>> fetchCategories() async => _categories;
}

void main() {
  group('CategoryTree', () {
    test('top level and children, by sortOrder then list order', () {
      expect(_categories.topLevel.map((c) => c.id), ['dairy', 'fruit']);
      expect(_categories.childrenOf('fruit').map((c) => c.id), [
        'fresh',
        'veg',
      ]);
      expect(_categories.childrenOf('dairy'), isEmpty);
    });
  });

  group('CategoryDetailsProvider', () {
    Future<CategoryDetailsProvider> open(String id) async {
      final container = ProviderContainer(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(
            CachedCatalogRepository(_Catalog()),
          ),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(categoryDetailsProvider(id), (_, _) {});
      addTearDown(sub.close);
      final n = container.read(categoryDetailsProvider(id).notifier);
      await pumpEventQueue();
      return n;
    }

    test('All: every product, menu of top-level categories', () async {
      final n = await open('');
      expect(n.state.parentId, isNull);
      expect(n.state.visibleProducts, hasLength(3));
      expect(n.state.menuShowsSubcategories, isFalse);
    });

    test('a parent with sub-categories filters per sub', () async {
      final n = await open('fruit');
      expect(n.state.menuShowsSubcategories, isTrue);
      expect(n.state.visibleProducts.map((p) => p.id), ['apple', 'onion']);
      n.selectSub('veg');
      expect(n.state.visibleProducts.map((p) => p.id), ['onion']);
      n.selectSub(null);
      expect(n.state.visibleProducts, hasLength(2));
    });

    test('a flat category keeps the top-level menu', () async {
      final n = await open('dairy');
      expect(n.state.menuShowsSubcategories, isFalse);
      expect(n.state.visibleProducts.map((p) => p.id), ['milk']);
    });

    test('opening a sub-category selects it under its parent', () async {
      final n = await open('fresh');
      expect(n.state.parentId, 'fruit');
      expect(n.state.subId, 'fresh');
      expect(n.state.visibleProducts.map((p) => p.id), ['apple']);
    });

    test('switching parent in place loads its products', () async {
      final n = await open('');
      await n.selectParent('dairy');
      expect(n.state.parentId, 'dairy');
      expect(n.state.visibleProducts.map((p) => p.id), ['milk']);
      await n.selectParent(null);
      expect(n.state.visibleProducts, hasLength(3));
    });
  });

  group('CategoryDetailsScreen', () {
    late Directory dir;
    setUpAll(() async {
      dir = await Directory.systemTemp.createTemp('category_browser_test');
      Hive.init(dir.path);
    });
    tearDownAll(() => dir.delete(recursive: true));

    Future<void> pump(
      WidgetTester tester,
      String id, {
      ThemeData? theme,
      double textScale = 1,
    }) async {
      final container = ProviderContainer(
        overrides: [
          ...await cartAndFavouritesOverrides(tester, catalog: _Catalog()),
          catalogRepositoryProvider.overrideWithValue(
            CachedCatalogRepository(_Catalog()),
          ),
        ],
      );
      addTearDown(container.dispose);
      await pumpLocalizedApp(
        tester,
        container: container,
        home: CategoryDetailsScreen(categoryId: id),
        theme: theme,
        textScale: textScale,
        disableAnimations: true,
      );
    }

    testWidgets('left menu lists sub-categories and filters in place', (
      tester,
    ) async {
      await pump(tester, 'fruit');
      expect(find.byType(CategoryRail), findsOneWidget);
      expect(find.text('Fresh Fruits'), findsOneWidget);
      expect(find.text('Item apple'), findsOneWidget);
      expect(find.text('Item onion'), findsOneWidget);

      await tester.tap(find.text('Vegetables'));
      await tester.pumpAndSettle();
      expect(find.text('Item apple'), findsNothing);
      expect(find.text('Item onion'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('All lists every category and switches in place', (
      tester,
    ) async {
      await pump(tester, '');
      expect(find.text('All products'), findsOneWidget);
      expect(find.text('Item milk'), findsOneWidget);

      await tester.tap(find.text('Dairy'));
      await tester.pumpAndSettle();
      expect(find.text('Item apple'), findsNothing);
      expect(find.text('Item milk'), findsOneWidget);
    });

    for (final (name, theme, scale) in [
      ('dark', ZyppiTheme.dark, 1.0),
      ('2x text', ZyppiTheme.light, 2.0),
    ]) {
      testWidgets('compact cards fit beside the menu ($name)', (tester) async {
        await pump(tester, 'fruit', theme: theme, textScale: scale);
        expect(tester.takeException(), isNull);
        final card = tester.getSize(find.byType(ZProductCard).first);
        expect(card.width, lessThan(150));
        expect(
          tester.widget<ZProductCard>(find.byType(ZProductCard).first).compact,
          isTrue,
        );
      });
    }
  });
}
