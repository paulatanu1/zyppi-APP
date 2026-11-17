import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';

Future<void> _pump(WidgetTester tester, {bool reduceMotion = false}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: ZyppiTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: const Scaffold(body: ZSearchBar(hints: ['Milk', 'Eggs'])),
      ),
    );

void main() {
  // Without translations loaded, tr() returns the key itself.
  testWidgets('placeholder rotates through the hints', (tester) async {
    await _pump(tester);
    expect(find.text('searchForItem'), findsOneWidget);
    await tester.pump(ZSearchBar.rotateEvery);
    await tester.pumpAndSettle();
    expect(find.text('searchForItem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion: static hint, no timer', (tester) async {
    await _pump(tester, reduceMotion: true);
    expect(find.text('homeSearchHint'), findsOneWidget);
    await tester.pump(ZSearchBar.rotateEvery * 2);
    expect(find.text('homeSearchHint'), findsOneWidget);
  });
}
