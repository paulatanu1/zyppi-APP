import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/account/presentation/account_screen.dart';
import 'package:zippy/features/your_order/application/orders_provider.dart';
import 'package:zippy/features/your_order/presentation/your_order_screen.dart';

import '../helpers/localized_app.dart';

Order _order(String id, OrderStatus status, {int? eta, int items = 1}) => Order(
  id: id,
  items: [
    for (var i = 0; i < items; i++)
      OrderItem(
        productId: 'p$i',
        variantId: 'v$i',
        name: 'Item $i',
        unit: '1 kg',
        quantity: 1,
        pricePaise: 10000,
      ),
  ],
  status: status,
  placedAt: DateTime(2026, 11, 5, 19, 42),
  itemTotalPaise: 10000 * items,
  deliveryFeePaise: 0,
  handlingFeePaise: 0,
  tipPaise: 0,
  discountPaise: 0,
  totalPaise: 10000 * items,
  paymentMethod: 'upi',
  etaMinutes: eta,
);

final _orders = [
  _order('a', OrderStatus.outForDelivery, eta: 6, items: 3),
  _order('b', OrderStatus.delivered, items: 7),
  _order('c', OrderStatus.cancelled),
];

void main() {
  Future<ProviderContainer> container() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ordersProvider.overrideWith((ref) async => _orders),
        profileProvider.overrideWith(
          (ref) async =>
              Profile(id: 'u1', fullName: 'Atanu', phone: '+91 98765 43210'),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('Orders', () {
    testWidgets('filter chips narrow the list; cards show their actions', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        container: (await tester.runAsync(container))!,
        home: const YourOrderScreen(),
      );

      expect(find.text('Track order · arriving in 6 min'), findsOneWidget);
      expect(find.text('Reorder'), findsOneWidget);
      expect(find.text('+4'), findsOneWidget); // 7 items, 3 photos shown

      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();
      expect(find.text('Reorder'), findsNothing);
      expect(find.text('Track order · arriving in 6 min'), findsOneWidget);

      // The test font is wide; scroll the chip into view first.
      await tester.ensureVisible(find.text('Cancelled').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelled').first);
      await tester.pumpAndSettle();
      expect(find.text('Track order · arriving in 6 min'), findsNothing);
      // Chip + the card's badge.
      expect(find.text('Cancelled'), findsNWidgets(2));
    });

    for (final dark in [false, true]) {
      testWidgets('no overflow at 2× text (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        await pumpLocalizedApp(
          tester,
          container: (await tester.runAsync(container))!,
          home: const YourOrderScreen(),
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Account', () {
    testWidgets('header, quick actions and settings rows', (tester) async {
      await pumpLocalizedApp(
        tester,
        container: (await tester.runAsync(container))!,
        home: const AccountScreen(),
      );

      expect(find.text('Atanu'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Your Orders'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);
    });

    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
          tester,
        ) async {
          await pumpLocalizedApp(
            tester,
            container: (await tester.runAsync(container))!,
            home: const AccountScreen(),
            theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
