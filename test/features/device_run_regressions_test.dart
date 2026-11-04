import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_product_card.dart';

Widget _wrap(Widget child, {required ThemeData theme, double width = 150}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

Color? _effectiveColor(WidgetTester tester, String text) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
  return paragraph.text.style?.color;
}

void main() {
  testWidgets('price + MRP beside ADD does not overflow a 150px card', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ZProductCard(
          name: 'Basmati Rice',
          weight: '1 kg',
          image: const SizedBox(),
          price: 14500,
          mrp: 16000,
          onAdd: () {},
          onRemove: () {},
        ),
        theme: ZyppiTheme.light,
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('product name uses the dark-theme ink in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ZProductCard(
          name: 'Fresh Tomatoes',
          weight: '500 g',
          image: const SizedBox(),
          price: 2500,
          onAdd: () {},
          onRemove: () {},
        ),
        theme: ZyppiTheme.dark,
      ),
    );

    // Text merges DefaultTextStyle into the painted span, so this is the
    // colour actually drawn.
    expect(_effectiveColor(tester, 'Fresh Tomatoes'), AppColorsExt.dark.ink);
  });
}
