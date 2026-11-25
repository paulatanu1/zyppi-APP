import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/shared_providers/location/application/get_current_location_state.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/my_cart/presentation/my_cart_screen.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_app.dart';

/// Fixed address instead of Geolocator.
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

final _kg = ProductVariant(
  id: 'v1',
  label: '1 kg',
  pricePaise: 17900,
  mrpPaise: 19900,
);
final _apples = Product(
  id: 'p1',
  name: 'Shimla Apples',
  categoryId: 'c1',
  variants: [_kg],
);
final _juiceL = ProductVariant(id: 'v2', label: '1 L', pricePaise: 11900);
final _juice = Product(
  id: 'p2',
  name: 'Mixed Fruit Juice',
  categoryId: 'c1',
  variants: [_juiceL],
);

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('cart_screen_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<ProviderContainer> pumpCart(
    WidgetTester tester, {
    ThemeData? theme,
    double textScale = 1,
    bool empty = false,
  }) async {
    final container = ProviderContainer(
      overrides: [
        ...await cartAndFavouritesOverrides(tester),
        currentLocation.overrideWith((ref) => _FixedLocation(ref)),
      ],
    );
    addTearDown(container.dispose);
    if (!empty) {
      container
        ..read(cartProvider.notifier).addItem(product: _apples, variant: _kg)
        ..read(cartProvider.notifier)
            .addItem(product: _juice, variant: _juiceL);
    }

    await pumpLocalizedApp(
      tester,
      container: container,
      home: const MyCartScreen(),
      theme: theme,
      textScale: textScale,
    );
    return container;
  }

  testWidgets('lists the lines with steppers, bill and checkout bar', (
    tester,
  ) async {
    await pumpCart(tester);

    expect(find.text('Your cart'), findsOneWidget);
    expect(find.text('Shimla Apples'), findsOneWidget);
    expect(find.text('Mixed Fruit Juice'), findsOneWidget);
    // The full bill opens from the sticky sheet's one-line summary.
    expect(find.text('Bill details'), findsNothing);
    await tester.tap(find.text('Bill'));
    await tester.pumpAndSettle();
    expect(find.text('Bill details'), findsOneWidget);
    expect(find.text('Ranchi Road, Purulia'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
  });

  testWidgets('a tip box sets the tip in the bill', (tester) async {
    final container = await pumpCart(tester);

    // The tip boxes open from the "Tip rider" card.
    await tester.tap(find.text('Tip rider'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('₹20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('₹20'));
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).tipPaise, 2000);

    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).tipPaise, 0);
  });

  testWidgets('− at 1 removes the line; empty cart has no checkout bar', (
    tester,
  ) async {
    final container = await pumpCart(tester);

    await tester.tap(find.bySemanticsLabel('Remove one').first);
    await tester.tap(find.bySemanticsLabel('Remove one').last);
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).lines, isEmpty);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Checkout'), findsNothing);
  });

  testWidgets('the coupon sheet sits above the navigation bar', (tester) async {
    // A 48 dp Android navigation bar (edge-to-edge).
    final dpr = tester.view.devicePixelRatio;
    tester.view.viewPadding = FakeViewPadding(bottom: 48 * dpr);
    tester.view.padding = FakeViewPadding(bottom: 48 * dpr);
    addTearDown(tester.view.reset);
    await pumpCart(tester);

    await tester.tap(find.text('Coupons'));
    await tester.pumpAndSettle();

    final screen = tester.view.physicalSize.height / dpr;
    final apply = tester.getRect(find.text('Apply coupon'));
    expect(apply.bottom, lessThanOrEqualTo(screen - 48));
    final field = tester.getRect(find.byType(TextField));
    expect(field.bottom, lessThanOrEqualTo(screen - 48));
  });

  testWidgets('+ stops at 5 of an item', (tester) async {
    final container = await pumpCart(tester);

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.bySemanticsLabel('Add one').first);
      await tester.pump();
    }
    final apples = container
        .read(cartProvider)
        .lines
        .firstWhere((l) => l.product.id == 'p1');
    expect(apples.quantity, CartNotifier.maxPerItem);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
        tester,
      ) async {
        await pumpCart(
          tester,
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
