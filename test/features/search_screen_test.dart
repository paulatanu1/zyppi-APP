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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/data/search_suggestions_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/search/data/recent_searches.dart';
import 'package:zippy/features/search/presentation/search_screen.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_app.dart';

Product _product(String id, String name, int price, {int? mrp}) => Product(
  id: id,
  name: name,
  categoryId: 'c1',
  variants: [
    ProductVariant(id: 'v$id', label: '1 kg', pricePaise: price, mrpPaise: mrp),
  ],
);

final _catalog = FakeCatalog([
  _product('1', 'Apples, Shimla', 17900, mrp: 19900),
  _product('2', 'Apple Juice, No Added Sugar', 12900),
  _product('3', 'Brown Bread', 4500),
]);

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('search_screen_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<ProviderContainer> pumpSearch(
    WidgetTester tester, {
    ThemeData? theme,
    double textScale = 1,
    List<String> recent = const [],
    List<String> suggestions = const [],
  }) async {
    SharedPreferences.setMockInitialValues({'recentSearches': recent});
    final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        searchSuggestionsProvider.overrideWith((ref) async => suggestions),
        catalogRepositoryProvider.overrideWithValue(
          CachedCatalogRepository(_catalog),
        ),
        ...await cartAndFavouritesOverrides(tester, catalog: _catalog),
      ],
    );
    addTearDown(container.dispose);
    await pumpLocalizedApp(
      tester,
      container: container,
      home: const SearchScreen(),
      theme: theme,
      textScale: textScale,
    );
    return container;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    // Past the 300 ms debounce.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  testWidgets('idle hint, then matching results with a header', (tester) async {
    await pumpSearch(tester);
    expect(
      find.text('Search for groceries, fruits, milk and more'),
      findsOneWidget,
    );

    await type(tester, 'app');
    expect(find.text('RESULTS FOR “APP”'), findsOneWidget);
    expect(find.textContaining('Shimla', findRichText: true), findsOneWidget);
    expect(find.textContaining('Juice', findRichText: true), findsOneWidget);
    expect(find.textContaining('Bread', findRichText: true), findsNothing);
  });

  testWidgets('ADD adds the product; clear empties the query', (tester) async {
    final container = await pumpSearch(tester);
    await type(tester, 'shimla');

    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).lines.single.product.id, '1');

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Clear search'), findsNothing);
    expect(
      find.text('Search for groceries, fruits, milk and more'),
      findsOneWidget,
    );
  });

  testWidgets('no match shows the empty state', (tester) async {
    await pumpSearch(tester);
    await type(tester, 'zzz');
    expect(find.text('No products found'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
        tester,
      ) async {
        await pumpSearch(
          tester,
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: scale,
        );
        await type(tester, 'app');
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('recent searches and suggestions fill the idle screen', (
    tester,
  ) async {
    final container = await pumpSearch(
      tester,
      recent: ['shimla'],
      suggestions: ['Brown Bread'],
    );
    expect(find.text('RECENT SEARCHES'), findsOneWidget);
    expect(find.text('TRY SEARCHING'), findsOneWidget);

    // Tapping a chip runs that search.
    await tester.tap(find.text('Brown Bread'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('RESULTS FOR “BROWN BREAD”'), findsOneWidget);

    // Clear empties the recent list.
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(container.read(recentSearchesProvider), isEmpty);
    expect(find.text('RECENT SEARCHES'), findsNothing);
  });

  test('recent searches: newest first, de-duplicated, capped', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final recent = RecentSearchesNotifier(prefs);
    for (var i = 0; i < 10; i++) {
      recent.add('item $i');
    }
    recent.add('ITEM 9');
    expect(recent.state.first, 'ITEM 9');
    expect(recent.state.length, RecentSearchesNotifier.max);
    expect(prefs.getStringList('recentSearches'), recent.state);
    recent.add('a'); // too short
    expect(recent.state.first, 'ITEM 9');
  });
}
