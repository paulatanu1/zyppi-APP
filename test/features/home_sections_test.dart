import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:zippy/core/common_widgets/app_error_widget.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/home_section_item.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/home_screen/widgets/sections/banner_carousel_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_cluster_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_grid_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_tabs_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/spotlight_cards_section.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/domain/product.dart';

const _screenWidth = 390.0;

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ZyppiTheme.light,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: _screenWidth, child: child),
      ),
    ),
  );
}

HomeSection _section(
  String type,
  List<Map<String, dynamic>> items, {
  Map<String, dynamic> config = const {},
}) {
  return HomeSection(
    id: type,
    type: type,
    config: config,
    items: [
      for (var i = 0; i < items.length; i++)
        HomeSectionItem(id: '$i', data: items[i]),
    ],
  );
}

void main() {
  testWidgets('banner card spans the content width', (tester) async {
    await tester.pumpWidget(
      _wrap(
        BannerCarouselSection(
          section: _section('banner_carousel', [
            {'title': 'Free delivery above ₹299', 'cta_text': 'Order now'},
          ]),
        ),
      ),
    );

    // The yellow card itself (its DecoratedBox), not just the tap area.
    final card = find.descendant(
      of: find.byType(BannerCarouselSection),
      matching: find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color ==
                ZyppiTheme.light.extension<AppColorsExt>()!.accent,
      ),
    );
    expect(tester.getSize(card.first).width, _screenWidth - 2 * AppSpacing.xxl);
  });

  testWidgets('mistyped admin data renders instead of throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            BannerCarouselSection(
              section: _section('banner_carousel', [
                {'title': 123, 'cta_text': true, 'link_target': 5},
              ]),
            ),
            CategoryTabsSection(
              section: _section('category_tabs', [
                {'label': 7, 'category_id': 5, 'icon': []},
              ]),
            ),
            CategoryGridSection(
              section: _section('category_grid', [], config: {'columns': 'x'}),
              categoriesById: const {},
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  for (final (name, theme) in [
    ('light', ZyppiTheme.light),
    ('dark', ZyppiTheme.dark),
  ]) {
    testWidgets('AppErrorWidget renders in $name theme', (tester) async {
      await tester.pumpWidget(_wrap(const AppErrorWidget(), theme: theme));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cart bar fits three thumbnails and a large total', (
    tester,
  ) async {
    // The bar uses `.plural()`, which needs a real EasyLocalization locale.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    // Translation assets load with real I/O, so let them finish outside
    // the fake clock before settling.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'UK')],
          fallbackLocale: const Locale('en', 'UK'),
          startLocale: const Locale('en', 'UK'),
          path: Constants.translationPath,
          child: Builder(
            builder: (context) => MaterialApp(
              theme: ZyppiTheme.light,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: _screenWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: ZCartBar(
                        thumbnails: [
                          for (var i = 0; i < 3; i++)
                            const ColoredBox(color: Colors.green),
                        ],
                        itemCount: 12,
                        total: 12345600,
                        saved: 50000,
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('View cart'), findsOneWidget);
    expect(find.textContaining('12 items'), findsOneWidget);
  });

  testWidgets('frequently-bought tiles share one height', (tester) async {
    // Home puts sections in a scroll view (unbounded height), which is
    // where unequal tiles show up.
    await tester.pumpWidget(
      _wrap(
        SingleChildScrollView(
          child: CategoryClusterSection(
            section: _section('category_cluster', [
              {'label': 'Fruits & Vegetables', 'count': 8},
              {'label': 'Atta, Rice & Dals', 'count': 10},
              {'label': 'Oil', 'count': 3},
            ]),
            categoriesById: const {},
          ),
        ),
      ),
    );

    final tiles = find.descendant(
      of: find.byType(CategoryClusterSection),
      matching: find.byType(InkWell),
    );
    final heights = tiles
        .evaluate()
        .map((e) => tester.getSize(find.byWidget(e.widget)).height)
        .toSet();
    expect(heights, hasLength(1));
  });

  testWidgets('long spotlight badge fits its card', (tester) async {
    final product = Product(
      id: 'p1',
      name: 'Bread',
      categoryId: 'c1',
      image: '',
      variants: const [],
    );

    await tester.pumpWidget(
      _wrap(
        SpotlightCardsSection(
          section: _section('spotlight_cards', [
            {'product_id': 'p1', 'badge': 'Customer favourite'},
          ]),
          productsById: {'p1': product},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Customer favourite'), findsOneWidget);
  });

  testWidgets('spotlight skips items whose product is missing', (tester) async {
    final product = Product(
      id: 'p1',
      name: 'Bread',
      categoryId: 'c1',
      image: '',
      variants: const [],
    );

    await tester.pumpWidget(
      _wrap(
        SpotlightCardsSection(
          section: _section('spotlight_cards', [
            {'product_id': 'gone', 'badge': 'Missing'},
            {'product_id': 'p1', 'badge': 'Fresh'},
          ]),
          productsById: {'p1': product},
        ),
      ),
    );

    expect(find.text('Missing'), findsNothing);
    // The real card is first in the row, not pushed along by an empty slot.
    final rowLeft = tester.getTopLeft(find.byType(SpotlightCardsSection)).dx;
    expect(
      tester.getTopLeft(find.byType(InkWell)).dx - rowLeft,
      AppSpacing.xxl,
    );
  });

  testWidgets('category tabs strip matches its sticky header height', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CategoryTabsSection(
          section: _section('category_tabs', [
            {'label': 'All', 'icon': 'grid'},
          ]),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CategoryTabsSection)).height,
      CategoryTabsSection.height,
    );
  });

  for (final dark in [false, true]) {
    testWidgets('pinned header: search + tabs on the brand surface '
        '(${dark ? 'dark' : 'light'})', (tester) async {
      final tabs = _section(
        'category_tabs',
        [
          {'label': 'All', 'icon': 'grid_view'},
          {'label': 'Fruits & Veg', 'icon': 'eco', 'category_id': 'c1'},
          {'label': 'Dairy & Bakery', 'icon': 'bakery', 'category_id': 'c2'},
        ],
        config: {'sticky': true},
      );
      final delegate = HomePinnedHeaderDelegate(
        tabs: tabs,
        onSearch: () {},
        onAllTap: () {},
      );
      await tester.pumpWidget(
        _wrap(
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          SizedBox(
            height: 600,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(pinned: true, delegate: delegate),
                const SliverToBoxAdapter(child: SizedBox(height: 2000)),
              ],
            ),
          ),
        ),
      );
      final colors = dark ? ZColors.dark : ZColors.light;
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((box.decoration as BoxDecoration).color, colors.header);
      expect(find.byType(ZSearchBar), findsOneWidget);
      expect(find.text('Dairy & Bakery'), findsOneWidget);
      expect(
        tester.getSize(find.byType(CategoryTabsSection)).height,
        CategoryTabsSection.height,
      );
      // Stays pinned after scrolling.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.byType(ZSearchBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
