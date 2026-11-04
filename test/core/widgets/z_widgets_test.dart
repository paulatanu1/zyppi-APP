import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_product_card.dart';

// easy_localization isn't initialised here, so `.tr()` returns the key.
Widget _wrap(
  Widget child, {
  ThemeData? theme,
  double textScale = 1,
  double width = 180,
}) {
  return MaterialApp(
    theme: theme ?? ZyppiTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

ZProductCard _card({
  int quantity = 0,
  VoidCallback? onAdd,
  VoidCallback? onRemove,
  VoidCallback? onFavourite,
  int? mrp,
}) => ZProductCard(
  name: 'Shimla Apples',
  weight: '1 kg',
  image: const SizedBox(),
  price: 17900,
  mrp: mrp,
  quantity: quantity,
  onAdd: onAdd ?? () {},
  onRemove: onRemove ?? () {},
  onFavourite: onFavourite,
);

void main() {
  group('ZProductCard', () {
    testWidgets('shows name, weight, price, ETA and a localized ADD', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_card(mrp: 19900)));

      expect(find.text('Shimla Apples'), findsOneWidget);
      expect(find.text('1 kg'), findsOneWidget);
      expect(find.text('₹179'), findsOneWidget);
      expect(find.text('₹199'), findsOneWidget);
      expect(find.text('etaBadge'), findsOneWidget);
      expect(find.text('offPercent'), findsOneWidget);
      expect(find.text('add'), findsOneWidget);
    });

    testWidgets('ADD calls onAdd; the stepper calls onAdd and onRemove', (
      tester,
    ) async {
      var adds = 0, removes = 0;
      await tester.pumpWidget(
        _wrap(_card(onAdd: () => adds++, onRemove: () => removes++)),
      );
      await tester.tap(find.text('add'));
      expect(adds, 1);

      await tester.pumpWidget(
        _wrap(
          _card(quantity: 2, onAdd: () => adds++, onRemove: () => removes++),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('addOne'));
      await tester.tap(find.bySemanticsLabel('removeOne'));
      expect(adds, 2);
      expect(removes, 1);
    });

    testWidgets('heart is hidden without onFavourite', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    });

    testWidgets('heart has a 44 pt tap target and a label', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(_card(onFavourite: () => taps++)));

      final target = find.bySemanticsLabel('addToFavourites');
      expect(target, findsOneWidget);
      final size = tester.getSize(target);
      expect(size.width, greaterThanOrEqualTo(ZSize.touch));
      expect(size.height, greaterThanOrEqualTo(ZSize.touch));
      await tester.tap(target);
      expect(taps, 1);
    });

    testWidgets('lays out without overflow at 1.5× text', (tester) async {
      await tester.pumpWidget(_wrap(_card(mrp: 19900), textScale: 1.5));
      expect(tester.takeException(), isNull);
    });
  });

  group('ZNavBar', () {
    testWidgets('localized labels, selection, taps and cart badge', (
      tester,
    ) async {
      int? tapped;
      await tester.pumpWidget(
        _wrap(
          ZNavBar(index: 1, cartCount: 120, onTap: (i) => tapped = i),
          width: 390,
        ),
      );

      for (final key in [
        'home',
        'explore',
        'navCart',
        'favourite',
        'navAccount',
      ]) {
        expect(find.text(key), findsOneWidget);
      }
      expect(find.text('99+'), findsOneWidget);

      await tester.tap(find.text('favourite'));
      expect(tapped, 3);

      expect(
        tester.getSemantics(find.text('explore')),
        isSemantics(isSelected: true),
      );
    });
  });

  group('ZSearchBar', () {
    testWidgets('hides the mic when there is no voice search', (tester) async {
      await tester.pumpWidget(_wrap(const ZSearchBar(), width: 390));
      expect(find.byIcon(Icons.mic_none_rounded), findsNothing);
      expect(find.text('homeSearchHint'), findsOneWidget);

      await tester.pumpWidget(_wrap(ZSearchBar(onMic: () {}), width: 390));
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    });
  });

  group('zTileTint', () {
    testWidgets('keeps catalog pastels in light, mutes them in dark', (
      tester,
    ) async {
      const pastel = Color(0xFFFFE0E0);
      late Color light, dark;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (c) {
              light = zTileTint(c, pastel);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (c) {
              dark = zTileTint(c, pastel);
              return const SizedBox();
            },
          ),
          theme: ZyppiTheme.dark,
        ),
      );
      await tester.pumpAndSettle(); // let the theme animation finish
      expect(light, pastel);
      expect(dark, isNot(pastel));
    });
  });
}
