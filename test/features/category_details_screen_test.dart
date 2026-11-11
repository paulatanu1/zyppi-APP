import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/data/cached_catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/category_details/presentation/category_details_screen.dart';
import 'package:zippy/features/category_details/widgets/subcategory_rail.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_app.dart';

Category _cat(String id, String name, {String? parentId}) => Category(
  id: id,
  name: name,
  colorHex: 'FFFFFFFF',
  borderColorHex: 'FFFFFFFF',
  parentId: parentId,
);

Product _product(String id, String name, {String? sub}) => Product(
  id: id,
  name: name,
  categoryId: 'c1',
  subcategoryId: sub,
  variants: [ProductVariant(id: 'v$id', label: '1 kg', pricePaise: 5000)],
);

class _TreeCatalog extends FakeCatalog {
  _TreeCatalog(super.products, this.categories);
  final List<Category> categories;
  @override
  Future<List<Category>> fetchCategories() async => categories;
}

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('category_details_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<void> pump(
    WidgetTester tester,
    List<Category> categories, {
    ThemeData? theme,
  }) async {
    final catalog = _TreeCatalog([
      _product('1', 'Apple', sub: 's-fruit'),
      _product('2', 'Tomato', sub: 's-veg'),
      _product('3', 'Mystery Box'),
    ], categories);
    final container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          CachedCatalogRepository(catalog),
        ),
        ...await cartAndFavouritesOverrides(tester, catalog: catalog),
      ],
    );
    addTearDown(container.dispose);
    await pumpLocalizedApp(
      tester,
      container: container,
      theme: theme,
      home: const CategoryDetailsScreen(categoryId: 'c1'),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    testWidgets('rail filters the grid by sub-category '
        '(${dark ? 'dark' : 'light'})', (tester) async {
      await pump(tester, theme: dark ? ZyppiTheme.dark : ZyppiTheme.light, [
        _cat('c1', 'Fruits & Vegetables'),
        _cat('s-fruit', 'Fresh Fruits', parentId: 'c1'),
        _cat('s-veg', 'Daily Veggies', parentId: 'c1'),
        _cat('c2', 'Other'),
      ]);

      expect(find.byType(SubcategoryRail), findsOneWidget);
      // "All" shows untagged products too.
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Mystery Box'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Daily Veggies'));
      await tester.pumpAndSettle();
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Mystery Box'), findsNothing);

      await tester.tap(find.bySemanticsLabel('All'));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('no sub-categories: no rail, full-width grid', (tester) async {
    await pump(tester, [_cat('c1', 'Fruits & Vegetables')]);
    expect(find.byType(SubcategoryRail), findsNothing);
    expect(find.text('Apple'), findsOneWidget);
  });
}
