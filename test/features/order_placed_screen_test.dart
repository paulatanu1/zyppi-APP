import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/application/order_by_id_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/order_placed/presentation/order_placed_screen.dart';

import '../helpers/localized_app.dart';

final _order = Order(
  id: 'abcdef123456',
  items: const [],
  status: OrderStatus.placed,
  placedAt: DateTime(2026, 11, 5),
  itemTotalPaise: 44700,
  deliveryFeePaise: 2500,
  handlingFeePaise: 500,
  tipPaise: 0,
  discountPaise: 0,
  totalPaise: 47700,
  paymentMethod: 'Cash on delivery',
  addressText: 'Ranchi Road, Purulia',
  etaMinutes: 12,
);

void main() {
  ProviderContainer container(FutureOr<Order?> Function() load) {
    final c = ProviderContainer(
      overrides: [orderByIdProvider('o1').overrideWith((ref) async => load())],
    );
    addTearDown(c.dispose);
    return c;
  }

  testWidgets('shows the ETA, order details and both actions', (tester) async {
    await pumpLocalizedApp(
      tester,
      container: container(() => _order),
      home: const OrderPlacedScreen(orderId: 'o1'),
      // The illustration bobs forever; off so the page settles.
      disableAnimations: true,
    );

    expect(find.text('Order placed!'), findsOneWidget);
    expect(find.textContaining('12 minutes'), findsOneWidget);
    expect(find.text('₹477'), findsOneWidget);
    expect(find.text('Ranchi Road, Purulia'), findsOneWidget);
    expect(find.text('Track order'), findsOneWidget);
    expect(find.text('Continue shopping'), findsOneWidget);
  });

  testWidgets('details that fail to load offer a retry', (tester) async {
    await pumpLocalizedApp(
      tester,
      container: container(() => null),
      home: const OrderPlacedScreen(orderId: 'o1'),
      // The illustration bobs forever; off so the page settles.
      disableAnimations: true,
    );
    expect(find.text('Track order'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
        tester,
      ) async {
        await pumpLocalizedApp(
          tester,
          container: container(() => _order),
          home: const OrderPlacedScreen(orderId: 'o1'),
          disableAnimations: true,
          // The illustration bobs forever; off so the page settles.
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
