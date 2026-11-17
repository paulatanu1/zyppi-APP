import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/app_settings/data/app_settings_repository.dart';
import 'package:zippy/core/app_settings/domain/app_settings.dart';
import 'package:zippy/core/app_settings/presentation/app_gate.dart';
import 'package:zippy/core/app_settings/presentation/home_notices.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/checkout/application/checkout_errors.dart';

import '../helpers/localized_app.dart';

class _Settings implements AppSettingsRepository {
  _Settings({
    this.flags = FeatureFlags.defaults,
    this.config = AppConfig.empty,
  });
  final FeatureFlags flags;
  final AppConfig config;

  @override
  Stream<FeatureFlags> watchFlags() => Stream.value(flags);

  @override
  Stream<AppConfig> watchAppConfig() => Stream.value(config);
}

ProviderContainer _container({
  FeatureFlags flags = FeatureFlags.defaults,
  AppConfig config = AppConfig.empty,
  String? version = '1.2.0',
}) {
  final c = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        _Settings(flags: flags, config: config),
      ),
      appVersionProvider.overrideWith((ref) async => version),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('FeatureFlags.fromMap', () {
    test('a missing doc or field means everything on', () {
      expect(FeatureFlags.fromMap(null), FeatureFlags.defaults);
      final f = FeatureFlags.fromMap({'placesSearch': 'nope', 'payments': 3});
      expect(f.placesSearch, isTrue);
      expect(f.upi, isTrue);
      expect(f.maintenance, isFalse);
    });

    test('reads the admin switches', () {
      final f = FeatureFlags.fromMap({
        'phoneOtp': false,
        'payments': {'upi': false, 'card': true},
        'maintenance': {'enabled': true, 'message': 'Back at 6'},
        'closedAreaIds': ['a1', 7],
        'minAppVersion': '1.3.0',
      });
      expect(f.phoneOtp, isFalse);
      expect(f.upi, isFalse);
      expect(f.maintenanceMessage, 'Back at 6');
      expect(f.closedAreaIds, ['a1']);
      expect(f.isAreaClosed('a1'), isTrue);
      expect(f.isAreaClosed(null), isFalse);
      expect(f.minAppVersion, '1.3.0');
      expect(
        FeatureFlags.fromMap({'minAppVersion': 'v2'}).minAppVersion,
        isNull,
      );
    });
  });

  test('isOlderVersion compares x.y.z and ignores build numbers', () {
    expect(isOlderVersion('1.2.9', '1.3.0'), isTrue);
    expect(isOlderVersion('1.3.0+14', '1.3.0'), isFalse);
    expect(isOlderVersion('2.0.0', '1.10.0'), isFalse);
    expect(isOlderVersion('1.9.0', '1.10.0'), isTrue);
    expect(isOlderVersion('1.0.0', null), isFalse);
    expect(isOlderVersion('weird', '1.0.0'), isFalse);
  });

  test('AppConfig reads contacts and only an enabled announcement', () {
    final c = AppConfig.fromMap({
      'supportPhone': '+919830012345',
      'announcement': {
        'enabled': true,
        'text': ' Closed on Diwali ',
        'tone': 'warning',
      },
    });
    expect(c.announcement, 'Closed on Diwali');
    expect(c.announcementTone, AnnouncementTone.warning);
    expect(
      AppConfig.fromMap({
        'announcement': {'enabled': false, 'text': 'x'},
      }).announcement,
      isNull,
    );
    expect(supportDigits(c.supportPhone, '911111111111'), '919830012345');
    expect(supportDigits(null, '911111111111'), '911111111111');
  });

  test('switched-off methods leave cash on delivery', () {
    const off = FeatureFlags(upi: false, card: false);
    expect(enabledPaymentMethods(off), [codPaymentMethod]);
  });

  test('new server refusals get their own messages', () {
    String msg(String m) => friendlyOrderError(
      FirebaseFunctionsException(message: m, code: 'failed-precondition'),
    );
    // Outside a localized app tr() returns the key.
    expect(msg('STORES_CLOSED'), 'errorStoresClosed');
    expect(msg('TOO_MANY_SELLERS:3'), 'errorTooManySellers');
    expect(msg('ACCOUNT_BLOCKED'), 'errorAccountBlocked');
    expect(
      msg('Ordering is paused in your area right now'),
      'errorOrderingPaused',
    );
    expect(
      msg('This payment method is unavailable right now'),
      'errorPaymentMethodOff',
    );
    expect(msg('something else'), 'errorOrderFailed');
  });

  group('AppGate', () {
    const app = Text('the app');

    testWidgets('shows the app when nothing is switched off', (tester) async {
      await pumpLocalizedApp(
        tester,
        container: _container(),
        home: const AppGate(child: app),
      );
      expect(find.text('the app'), findsOneWidget);
    });

    testWidgets('shows maintenance with the admin message', (tester) async {
      await pumpLocalizedApp(
        tester,
        container: _container(
          flags: const FeatureFlags(
            maintenance: true,
            maintenanceMessage: 'Back at 6 pm',
          ),
        ),
        home: const AppGate(child: app),
      );
      expect(find.text('the app'), findsNothing);
      expect(find.text('Back at 6 pm'), findsOneWidget);
    });

    testWidgets('asks an old app to update, in dark theme too', (tester) async {
      await pumpLocalizedApp(
        tester,
        container: _container(
          flags: const FeatureFlags(minAppVersion: '1.3.0'),
        ),
        theme: ZyppiTheme.dark,
        home: const AppGate(child: app),
      );
      expect(find.text('the app'), findsNothing);
      expect(find.text('Update now'), findsOneWidget);
    });
  });

  testWidgets('Home notices: paused area and the announcement', (tester) async {
    await pumpLocalizedApp(
      tester,
      container: _container(
        flags: const FeatureFlags(closedAreaIds: ['a1']),
        config: const AppConfig(
          announcementEnabled: true,
          announcementText: 'Free delivery today',
        ),
      ),
      home: const Scaffold(body: HomeNotices(serviceAreaId: 'a1')),
    );
    expect(find.textContaining('paused'), findsOneWidget);
    expect(find.text('Free delivery today'), findsOneWidget);
  });
}
