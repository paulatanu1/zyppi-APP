import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/home_section_item.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/shared_providers/location/application/get_current_location_state.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/features/home_screen/application/home_sections_provider.dart';
import 'package:zippy/features/home_screen/presentation/home_screen.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_tabs_section.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_app.dart';

class _FixedLocation extends GetCurrentLocationProvider {
  _FixedLocation(super.ref) {
    state = GetCurrentLocationState.initial().copyWith(
      isDetecting: false,
      address: 'Ranchi Road, Purulia',
    );
  }

  @override
  Future<void> getCurrentLocation({bool requestPermission = false}) async {}
}

HomeSection _section(
  String type,
  String title,
  int items, {
  Map<String, dynamic> config = const {},
}) => HomeSection(
  id: '$type-$title',
  type: type,
  title: title,
  config: config,
  items: [
    for (var i = 0; i < items; i++)
      HomeSectionItem(id: '$i', data: {'title': 'Item $i', 'label': 'L$i'}),
  ],
);

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('home_violet_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<void> pumpHome(
    WidgetTester tester, {
    ThemeData? theme,
    double textScale = 1,
    bool tabsFirst = false,
  }) async {
    final container = ProviderContainer(
      overrides: [
        ...await cartAndFavouritesOverrides(tester),
        currentLocation.overrideWith((ref) => _FixedLocation(ref)),
        profileProvider.overrideWith((ref) => Completer<Profile>().future),
        homeSectionsProvider.overrideWith(
          (ref) async => (
            sections: [
              if (tabsFirst)
                _section(
                  'category_tabs',
                  'Tabs',
                  4,
                  config: const {'sticky': true},
                ),
              _section('banner_carousel', 'Offers', 1),
              // Enough content to scroll the header shut.
              for (var i = 0; i < 6; i++)
                _section('category_grid', 'Shop by category $i', 8),
            ],
            categoriesById: const <String, Category>{},
            productsById: const <String, Product>{},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Reduced motion: no looping ⚡ or entrance timers to wait out.
    await pumpLocalizedApp(
      tester,
      container: container,
      home: const HomeScreen(),
      theme: theme,
      textScale: textScale,
      disableAnimations: true,
    );
  }

  ZColors colorsOf(WidgetTester tester, Finder finder) =>
      Theme.of(tester.element(finder)).extension<ZColors>()!;

  testWidgets('Home is logo purple and textured', (tester) async {
    await pumpHome(tester);

    expect(
      colorsOf(tester, find.byType(HomeScreenHeader)).brand,
      const Color(0xFF673AB7),
    );
    expect(find.byType(ZBrandTexture), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('section headers use the See-all pill on Home', (tester) async {
    await pumpHome(tester);
    final header = tester.widget<ZSectionHeader>(
      find.byType(ZSectionHeader).first,
    );
    expect(header.pill, isTrue);
  });

  testWidgets('scrolling folds the header down to the search bar', (
    tester,
  ) async {
    await pumpHome(tester);
    HomeScreenHeader header() =>
        tester.widget<HomeScreenHeader>(find.byType(HomeScreenHeader));
    expect(header().collapse, 0);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();

    expect(header().collapse, 1);
    expect(find.byType(ZSearchBar), findsOneWidget);
    expect(tester.getRect(find.byType(ZSearchBar)).top, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  for (final (name, theme, scale) in [
    ('dark', ZyppiTheme.dark, 1.0),
    ('large text', ZyppiTheme.light, 2.0),
  ]) {
    testWidgets('renders without overflow: $name', (tester) async {
      await pumpHome(tester, theme: theme, textScale: scale);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a first category strip sits on the purple and pins solid', (
    tester,
  ) async {
    await pumpHome(tester, tabsFirst: true);
    CategoryTabsSection strip() =>
        tester.widget<CategoryTabsSection>(find.byType(CategoryTabsSection));
    expect(strip().onHero, isTrue);
    expect(strip().pinned, isFalse);
    // Its chips sit on the textured hero panel, under the search bar.
    expect(
      tester.getRect(find.byType(CategoryTabsSection)).top,
      greaterThanOrEqualTo(tester.getRect(find.byType(ZSearchBar)).bottom),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    expect(strip().pinned, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category strip further down uses light chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ZyppiTheme.light,
        home: Scaffold(
          body: CategoryTabsSection(
            section: _section('category_tabs', 'Tabs', 3),
          ),
        ),
      ),
    );
    final strip = tester.widget<CategoryTabsSection>(
      find.byType(CategoryTabsSection),
    );
    expect(strip.onHero, isFalse);
    expect(
      tester.getSize(find.byType(CategoryTabsSection)).height,
      CategoryTabsSection.height,
    );
  });

  test('shared widgets default to their existing look', () {
    expect(const ZSectionHeader('x').pill, isFalse);
    expect(const ZSearchBar().glow, isFalse);
  });
}
