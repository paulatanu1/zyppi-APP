import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/order_tracking/data/delivery_info_repository.dart';
import 'package:zippy/features/your_order/widgets/rate_sellers_card.dart';

import '../helpers/localized_app.dart';

class _Repo implements DeliveryInfoRepository {
  final rated = <String>{};
  final calls = <Map<String, int>>[];
  @override
  Stream<String?> watchCode(String orderId) => Stream.value(null);
  @override
  Stream<RiderLive?> watchRider(String orderId) => Stream.value(null);
  @override
  Stream<bool> watchRated(String orderId) => Stream.value(false);
  @override
  Future<void> rateRider(String orderId, int stars, List<String> tags) async {}
  @override
  Stream<Set<String>> watchRatedSellers(String orderId) =>
      Stream.value({...rated});
  @override
  Future<void> rateSellers(String orderId, Map<String, int> stars) async {
    calls.add(stars);
    rated.addAll(stars.keys);
  }
}

OrderItem item(String? sellerId, String? name) => OrderItem(
  productId: 'p',
  variantId: 'v-$sellerId',
  name: 'Milk',
  unit: '1 L',
  quantity: 1,
  pricePaise: 5000,
  sellerId: sellerId,
  sellerName: name,
);

void main() {
  testWidgets(
    'rates each outside seller once; Zyppi and old lines are skipped',
    (tester) async {
      final repo = _Repo();
      final container = ProviderContainer(
        overrides: [deliveryInfoRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await pumpLocalizedApp(
        tester,
        container: container,
        theme: ZyppiTheme.dark,
        home: Scaffold(
          body: RateSellersCard(
            orderId: 'o1',
            items: [
              item('sima', 'Sima Store'),
              item('zyppi', 'Zyppi'),
              item(null, null),
            ],
          ),
        ),
      );
      expect(find.text('Rate the sellers'), findsOneWidget);
      expect(find.text('Sima Store'), findsOneWidget);
      expect(find.text('Zyppi'), findsNothing);

      await tester.tap(find.byTooltip('4 stars'));
      await tester.pumpAndSettle();
      expect(repo.calls, [
        {'sima': 4},
      ]);
      expect(find.text('Rate the sellers'), findsNothing);
    },
  );

  testWidgets('nothing to rate: hidden', (tester) async {
    final container = ProviderContainer(
      overrides: [deliveryInfoRepositoryProvider.overrideWithValue(_Repo())],
    );
    addTearDown(container.dispose);
    await pumpLocalizedApp(
      tester,
      container: container,
      home: Scaffold(
        body: RateSellersCard(orderId: 'o1', items: [item('zyppi', 'Zyppi')]),
      ),
    );
    expect(find.text('Rate the sellers'), findsNothing);
  });
}
