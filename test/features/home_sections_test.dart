import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/common_widgets/app_error_widget.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/home_section_item.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/home_screen/widgets/sections/banner_carousel_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_grid_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_tabs_section.dart';

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
}
