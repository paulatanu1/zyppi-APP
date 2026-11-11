import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/delivery_config.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

const _delivery = DeliveryConfig(
  feePaise: 2500,
  freeAbovePaise: 49900,
  minOrderPaise: 9900,
);

Future<void> _pump(
  WidgetTester tester,
  int itemTotal, {
  DeliveryConfig delivery = _delivery,
  bool compact = false,
  bool dark = false,
}) => tester.pumpWidget(
  MaterialApp(
    theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
    home: Scaffold(
      body: SizedBox(
        width: 360,
        child: ZDeliveryProgress(
          itemTotalPaise: itemTotal,
          delivery: delivery,
          compact: compact,
        ),
      ),
    ),
  ),
);

double _barValue(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
    .value!;

void main() {
  testWidgets('below the minimum: asks for more to place the order', (
    tester,
  ) async {
    await _pump(tester, 5000);
    await tester.pumpAndSettle();
    expect(find.text('addMoreToOrder'), findsOneWidget);
    expect(_barValue(tester), closeTo(5000 / 9900, .001));
  });

  testWidgets('between minimum and free: counts down to free delivery', (
    tester,
  ) async {
    await _pump(tester, 20000, dark: true);
    await tester.pumpAndSettle();
    expect(find.text('addMoreForFreeDelivery'), findsOneWidget);
    expect(_barValue(tester), closeTo(20000 / 49900, .001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('unlocked: celebrates; compact pill hides itself', (
    tester,
  ) async {
    await _pump(tester, 50000);
    await tester.pumpAndSettle();
    expect(find.text('freeDeliveryUnlocked'), findsOneWidget);
    expect(_barValue(tester), 1);

    await _pump(tester, 50000, compact: true);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('always-free delivery and no minimum: renders nothing', (
    tester,
  ) async {
    await _pump(tester, 100, delivery: DeliveryConfig.free);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
