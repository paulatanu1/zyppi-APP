import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:zippy/core/data/address_repository.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/data/coupon_repository_impl.dart';
import 'package:zippy/core/data/delivery_slot_repository.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/data/delivery_slot_repository_impl.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/domain/delivery_slot.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/checkout/presentation/checkout_screen.dart';

final _home = Address(
  id: 'a1',
  label: 'Home',
  line1: 'Ranchi Road, near Saheb Bandh',
  area: 'Purulia',
  city: 'Purulia',
  state: 'West Bengal',
  postalCode: '723101',
  lat: 23.33,
  lng: 86.36,
  isDefault: true,
);

final _slots = [
  DeliverySlot(
    id: 's1',
    label: 'In 12 minutes',
    etaMinutes: 12,
    isExpress: true,
  ),
  DeliverySlot(id: 's2', label: 'Today, 6–8 PM', etaMinutes: 120),
];

/// [result] null = still loading (never completes).
class _Addresses implements AddressRepository {
  final List<Address>? result;
  _Addresses(this.result);

  @override
  Future<List<Address>> fetchAddresses() =>
      result == null ? Completer<List<Address>>().future : Future.value(result);

  @override
  Future<void> addAddress(
    Address address, {
    required String serviceAreaId,
  }) async {}

  @override
  Future<void> updateAddress(Address address) async {}

  @override
  Future<void> deleteAddress(String id) async {}

  @override
  Future<void> setDefault(String id) async {}
}

class _Slots implements DeliverySlotRepository {
  final List<DeliverySlot>? result;
  _Slots(this.result);

  @override
  Future<List<DeliverySlot>> fetchSlots() => result == null
      ? Completer<List<DeliverySlot>>().future
      : Future.value(result);
}

void main() {
  late Directory dir;
  var boxCount = 0;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('checkout_test');
    Hive.init(dir.path);
  });

  tearDownAll(() => dir.delete(recursive: true));

  Future<void> pumpCheckout(
    WidgetTester tester, {
    required List<Address>? addresses,
    required List<DeliverySlot>? slots,
    ThemeData? theme,
  }) async {
    // A typical phone screen, so overflow checks mean something.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final box = await tester.runAsync(
      () => Hive.openBox('checkout${boxCount++}', bytes: Uint8List(0)),
    );

    // `.plural()` needs a real EasyLocalization locale; translation assets
    // load with real I/O, so pump them outside the fake clock.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'UK')],
          fallbackLocale: const Locale('en', 'UK'),
          startLocale: const Locale('en', 'UK'),
          path: Constants.translationPath,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              addressRepositoryProvider.overrideWithValue(
                _Addresses(addresses),
              ),
              deliverySlotRepositoryProvider.overrideWithValue(_Slots(slots)),
              cartProvider.overrideWith(
                (ref) => CartNotifier(
                  LocalCartStore(box!),
                  null,
                  ref.read(catalogRepositoryProvider),
                  ref.read(couponRepositoryProvider),
                ),
              ),
            ],
            child: Builder(
              builder: (context) => MaterialApp(
                theme: theme ?? ZyppiTheme.light,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: const CheckoutScreen(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    // Let data land and the skeleton→content fade finish (skeletons
    // shimmer forever, so no pumpAndSettle).
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  for (final (name, theme) in [
    ('light', ZyppiTheme.light),
    ('dark', ZyppiTheme.dark),
  ]) {
    group('$name theme', () {
      testWidgets('loading: payment shows at once, other cards are shaped '
          'skeletons', (tester) async {
        await pumpCheckout(tester, addresses: null, slots: null, theme: theme);

        // Online payments are off unless ONLINE_PAYMENTS_ENABLED is set.
        expect(find.text('UPI'), findsNothing);
        expect(find.text('Cash on delivery'), findsOneWidget);
        expect(find.byType(ZSkeleton), findsWidgets);
        expect(find.byType(RadioListTile<String>), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('no saved address: add-address card, Pay disabled', (
        tester,
      ) async {
        await pumpCheckout(tester, addresses: [], slots: _slots, theme: theme);

        expect(find.text('Add a delivery address'), findsOneWidget);
        final pay = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(pay.onPressed, isNull);
        expect(tester.takeException(), isNull);
      });

      testWidgets('data: address with Change, slots, payment selection', (
        tester,
      ) async {
        await pumpCheckout(
          tester,
          addresses: [_home],
          slots: _slots,
          theme: theme,
        );

        expect(find.text(_home.line1), findsOneWidget);
        expect(find.text('Change'), findsOneWidget);
        expect(find.text('In 12 minutes'), findsOneWidget);
        expect(find.byType(ZSkeleton), findsNothing);

        // Cash on delivery is the only, pre-selected method.
        expect(find.textContaining('Place order'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
