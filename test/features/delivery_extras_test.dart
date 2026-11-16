import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/order_tracking/data/delivery_info_repository.dart';
import 'package:zippy/features/order_tracking/widgets/delivery_extras.dart';

import '../helpers/localized_app.dart';

class _Repo implements DeliveryInfoRepository {
  _Repo({this.live, this.rated = false});
  final RiderLive? live;
  bool rated;
  final ratings = <(int, List<String>)>[];

  @override
  Stream<String?> watchCode(String orderId) => Stream.value('4821');
  @override
  Stream<RiderLive?> watchRider(String orderId) => Stream.value(live);
  @override
  Stream<bool> watchRated(String orderId) => Stream.value(rated);
  @override
  Future<void> rateRider(String orderId, int stars, List<String> tags) async =>
      ratings.add((stars, tags));
  final sellerStars = <String, int>{};
  @override
  Stream<Set<String>> watchRatedSellers(String orderId) =>
      Stream.value(sellerStars.keys.toSet());
  @override
  Future<void> rateSellers(String orderId, Map<String, int> stars) async =>
      sellerStars.addAll(stars);
}

Future<_Repo> _pump(
  WidgetTester tester,
  OrderStatus status, {
  RiderLive? live,
  bool rated = false,
  ThemeData? theme,
}) async {
  final repo = _Repo(live: live, rated: rated);
  final container = ProviderContainer(
    overrides: [deliveryInfoRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  await pumpLocalizedApp(
    tester,
    container: container,
    theme: theme,
    home: Scaffold(
      body: DeliveryExtras(orderId: 'o1', status: status, hasRider: true),
    ),
  );
  return repo;
}

void main() {
  test('RiderLive reads the rider app ping', () {
    final now = DateTime.now();
    final live = RiderLive.tryFrom({
      'lat': 23.3,
      'lng': 86.3,
      'distanceM': 1240,
      'etaMinutes': 6,
      'at': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
    })!;
    expect(live.distanceM, 1240);
    expect(live.staleAt(now), isTrue);
    expect(RiderLive.tryFrom({'lat': 'x'}), isNull);
    expect(RiderLive.tryFrom(null), isNull);
  });

  testWidgets('out for delivery: code and live distance', (tester) async {
    await _pump(
      tester,
      OrderStatus.outForDelivery,
      live: RiderLive(
        lat: 23.3,
        lng: 86.3,
        distanceM: 1240,
        etaMinutes: 6,
        at: DateTime.now(),
      ),
    );
    expect(find.text('4821'), findsOneWidget);
    expect(find.text('Rider is 1.2 km away · ~6 min'), findsOneWidget);
    expect(find.text('See on map'), findsOneWidget);
  });

  testWidgets('placed: code only, in dark theme', (tester) async {
    await _pump(tester, OrderStatus.placed, theme: ZyppiTheme.dark);
    expect(find.text('Delivery code'), findsOneWidget);
    expect(find.text('See on map'), findsNothing);
  });

  testWidgets('delivered: no code; rate the rider once', (tester) async {
    final repo = await _pump(tester, OrderStatus.delivered);
    expect(find.text('4821'), findsNothing);
    await tester.tap(find.text('Rate your delivery partner'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('4 stars'));
    await tester.tap(find.text('Polite'));
    await tester.pump();
    await tester.tap(find.text('Send rating'));
    await tester.pumpAndSettle();
    expect(repo.ratings.single.$1, 4);
    expect(repo.ratings.single.$2, ['polite']);
  });

  testWidgets('already rated: no button', (tester) async {
    await _pump(tester, OrderStatus.delivered, rated: true);
    expect(find.text('Rate your delivery partner'), findsNothing);
  });
}
