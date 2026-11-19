import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/order/domain/order_repository.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/order_tracking/presentation/order_tracking_screen.dart';

import '../helpers/localized_app.dart';

class _Orders implements OrderRepository {
  _Orders(this.order);
  final Order? order;
  final cancelled = <(String, CancelReason)>[];

  @override
  Future<Order?> getOrderById(String id) async => order;
  @override
  Future<List<Order>> getOrders({int? limit}) async => [?order];
  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {}
  @override
  Future<void> cancelOrder(String orderId, CancelReason reason) async =>
      cancelled.add((orderId, reason));
  @override
  Stream<Order?> watchOrder(String id) => Stream.value(order);
  @override
  Stream<List<Order>> watchOrders({int limit = recentOrdersLimit}) =>
      Stream.value([?order]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Order _order(OrderStatus status) => Order(
  id: 'o1',
  items: [
    OrderItem(
      productId: 'p1',
      variantId: 'v1',
      name: 'Apples',
      unit: '1 kg',
      quantity: 3,
      pricePaise: 15900,
    ),
  ],
  status: status,
  placedAt: DateTime.now(),
  itemTotalPaise: 47700,
  deliveryFeePaise: 0,
  handlingFeePaise: 0,
  tipPaise: 0,
  discountPaise: 0,
  totalPaise: 47700,
  paymentMethod: 'upi',
  riderName: 'Ravi',
  riderPhone: '+919876543210',
  etaMinutes: 12,
);

void main() {
  Future<_Orders> pump(
    WidgetTester tester,
    Order? order, {
    ThemeData? theme,
    double textScale = 1,
  }) async {
    final orders = _Orders(order);
    final c = ProviderContainer(
      overrides: [orderRepositoryProvider.overrideWithValue(orders)],
    );
    addTearDown(c.dispose);
    await pumpLocalizedApp(
      tester,
      container: c,
      home: const OrderTrackingScreen(orderId: 'o1'),
      theme: theme,
      textScale: textScale,
      // The rider marker pulses forever.
      disableAnimations: true,
    );
    return orders;
  }

  /// Unmounts and lets the mock flavour's status timer go.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 5));
  }

  testWidgets('on the way: ETA, progress, rider card and summary', (
    tester,
  ) async {
    await pump(tester, _order(OrderStatus.outForDelivery));

    expect(find.text('ARRIVING IN'), findsOneWidget);
    expect(find.textContaining('min'), findsWidgets);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.byTooltip('Call delivery partner'), findsOneWidget);
    expect(find.byTooltip('Message us about this order'), findsOneWidget);
    expect(find.textContaining('3 items'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('cancelled: explains instead of progress', (tester) async {
    await pump(tester, _order(OrderStatus.cancelled));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('cancelled'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('placed: the customer can cancel with a reason', (tester) async {
    final orders = await pump(tester, _order(OrderStatus.placed));
    final button = find.widgetWithText(TextButton, 'Cancel order');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Why are you cancelling?'), findsOneWidget);
    await tester.tap(find.text('I ordered by mistake'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancel order'));
    await tester.pumpAndSettle();
    expect(orders.cancelled, [('o1', CancelReason.orderedByMistake)]);
    await unmount(tester);
  });

  testWidgets('no cancel once packed or on the way', (tester) async {
    await pump(tester, _order(OrderStatus.packed));
    expect(find.text('Cancel order'), findsNothing);
    await unmount(tester);
    await pump(tester, _order(OrderStatus.outForDelivery));
    expect(find.text('Cancel order'), findsNothing);
    await unmount(tester);
  });

  testWidgets('unknown order', (tester) async {
    await pump(tester, null);
    expect(find.text("We couldn't find this order."), findsOneWidget);
    await unmount(tester);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
        tester,
      ) async {
        await pump(
          tester,
          _order(OrderStatus.outForDelivery),
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
        await unmount(tester);
      });
    }
  }
}
