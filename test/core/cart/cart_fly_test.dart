import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/cart/presentation/cart_fly.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

const _thumbKey = ValueKey('thumb');

Future<void> _pump(WidgetTester tester, {bool reduceMotion = false}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: ZyppiTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: Scaffold(
          body: Column(
            children: [
              Builder(
                builder: (card) => SizedBox(
                  width: 160,
                  height: 200,
                  child: TextButton(
                    onPressed: () =>
                        CartFly.launch(card, const SizedBox(key: _thumbKey)),
                    child: const Text('ADD'),
                  ),
                ),
              ),
              const Spacer(),
              const CartFlyTarget(
                child: SizedBox(height: 60, child: Text('cart')),
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  testWidgets('the picture flies into the cart bar, then goes away', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('ADD'));
    await tester.pump();
    expect(find.byKey(_thumbKey), findsOneWidget);

    await tester.pump(CartFly.duration ~/ 2);
    expect(find.byKey(_thumbKey), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(_thumbKey), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion: nothing flies', (tester) async {
    await _pump(tester, reduceMotion: true);
    await tester.tap(find.text('ADD'));
    await tester.pump();
    expect(find.byKey(_thumbKey), findsNothing);
  });
}
