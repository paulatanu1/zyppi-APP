import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/notifications/application/notifications_providers.dart';
import 'package:zippy/features/notifications/data/firebase_notifications_repository.dart';
import 'package:zippy/features/notifications/data/mock_notifications_repository.dart';
import 'package:zippy/features/notifications/domain/app_notification.dart';
import 'package:zippy/features/notifications/presentation/notifications_screen.dart';

import '../helpers/localized_app.dart';

void main() {
  group('FirebaseNotificationsRepository.fromDoc', () {
    test('reads the entry functions write', () {
      final n = FirebaseNotificationsRepository.fromDoc('o_1_delivered', {
        'kind': 'order',
        'title': 'Delivered',
        'body': 'Your order has been delivered.',
        'at': Timestamp.fromMillisecondsSinceEpoch(1000),
        'read': false,
        'data': {'orderId': 'o1', 'status': 'delivered', 'n': 3},
      });
      expect(n.kind, AppNotificationKind.order);
      expect(n.at, DateTime.fromMillisecondsSinceEpoch(1000));
      expect(n.data, {'orderId': 'o1', 'status': 'delivered'});
      expect(n.read, isFalse);
    });

    test('falls back safely on unknown or missing fields', () {
      final n = FirebaseNotificationsRepository.fromDoc('x', {'kind': 'new'});
      expect(n.kind, AppNotificationKind.account);
      expect(n.title, '');
      expect(n.data, isEmpty);
      expect(n.at, isNull);
    });
  });

  group('NotificationsScreen', () {
    final items = [
      AppNotification(
        id: 'a',
        kind: AppNotificationKind.order,
        title: 'Out for delivery',
        body: 'Your order is on its way.',
        at: DateTime.now().subtract(const Duration(minutes: 5)),
        data: const {'orderId': 'o1'},
      ),
      AppNotification(
        id: 'b',
        kind: AppNotificationKind.offer,
        title: 'Fresh mangoes',
        body: '20% off till Sunday',
        at: DateTime.now().subtract(const Duration(days: 3)),
        read: true,
      ),
    ];

    Future<MockNotificationsRepository> pump(
      WidgetTester tester,
      List<AppNotification> seed, {
      ThemeData? theme,
    }) async {
      final repo = MockNotificationsRepository(seed);
      final container = ProviderContainer(
        overrides: [notificationsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await pumpLocalizedApp(
        tester,
        container: container,
        home: const NotificationsScreen(),
        theme: theme,
        disableAnimations: true,
      );
      return repo;
    }

    testWidgets('shows the empty state', (tester) async {
      await pump(tester, const []);
      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('lists entries newest first with their times', (tester) async {
      await pump(tester, items);
      expect(find.text('Out for delivery'), findsOneWidget);
      expect(find.text('Fresh mangoes'), findsOneWidget);
      expect(find.text('5 min ago'), findsOneWidget);
    });

    testWidgets('marks everything read', (tester) async {
      await pump(tester, items);
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('swipe removes an entry', (tester) async {
      await pump(tester, items);
      await tester.drag(find.text('Fresh mangoes'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Fresh mangoes'), findsNothing);
    });

    testWidgets('renders in dark theme', (tester) async {
      await pump(tester, items, theme: ZyppiTheme.dark);
      expect(find.text('Out for delivery'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
