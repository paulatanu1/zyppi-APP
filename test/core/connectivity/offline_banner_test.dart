import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/connectivity/connectivity_provider.dart';
import 'package:zippy/core/connectivity/offline_banner.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

class _FakeMonitor implements ConnectivityMonitor {
  _FakeMonitor(this.initial);
  final bool initial;
  final changes = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => initial;
  @override
  Stream<bool> watch() => changes.stream;
}

Future<_FakeMonitor> _pump(
  WidgetTester tester, {
  required bool online,
  bool dark = false,
}) async {
  final monitor = _FakeMonitor(online);
  addTearDown(monitor.changes.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [connectivityMonitorProvider.overrideWithValue(monitor)],
      child: MaterialApp(
        theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
        builder: (context, child) => OfflineBannerHost(child: child!),
        home: const Scaffold(body: Text('screen')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return monitor;
}

const _banner = ValueKey('offline-banner');

void main() {
  testWidgets('online: no banner', (tester) async {
    await _pump(tester, online: true);
    expect(find.byKey(_banner), findsNothing);
    expect(find.text('screen'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets('offline → banner; back online → brief notice, then gone '
        '(${dark ? 'dark' : 'light'})', (tester) async {
      final monitor = await _pump(tester, online: false, dark: dark);
      expect(find.text('offlineBanner'), findsOneWidget);

      monitor.changes.add(true);
      await tester.pumpAndSettle();
      expect(find.text('backOnline'), findsOneWidget);

      await tester.pump(OfflineBannerHost.backOnlineHold);
      await tester.pumpAndSettle();
      expect(find.byKey(_banner), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('going offline mid-session shows the banner', (tester) async {
    final monitor = await _pump(tester, online: true);
    monitor.changes.add(false);
    await tester.pumpAndSettle();
    expect(find.text('offlineBanner'), findsOneWidget);
  });
}
