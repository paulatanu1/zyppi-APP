import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/order/domain/order_repository.dart';
import 'package:zippy/features/your_order/application/orders_provider.dart';
import 'package:zippy/features/your_order/presentation/order_details_screen.dart';
import 'package:zippy/features/your_order/presentation/your_order_screen.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_app.dart';

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('review_test');
    Hive.init(dir.path);
  });
  tearDownAll(() => dir.delete(recursive: true));

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    List<PaymentUnderReview> review = const [],
  }) async {
    final container = ProviderContainer(
      overrides: [
        ...await cartAndFavouritesOverrides(tester),
        paymentsUnderReviewProvider.overrideWith((ref) => Stream.value(review)),
      ],
    );
    addTearDown(container.dispose);
    await pumpLocalizedApp(tester, container: container, home: home);
  }

  testWidgets('a paid checkout under review stays on "Your orders"', (
    tester,
  ) async {
    await pump(
      tester,
      const Scaffold(body: PaymentsUnderReviewBanner()),
      review: const [PaymentUnderReview(txnid: 'zabc', amountPaise: 45000)],
    );
    expect(find.text('Payment received, order not confirmed'), findsOneWidget);
    expect(find.textContaining('450'), findsOneWidget);
    expect(
      find.textContaining("don't need to pay again"),
      findsNothing,
    ); // curly apostrophe
    expect(find.textContaining('need to pay again'), findsOneWidget);
  });

  testWidgets('no banner when nothing is under review', (tester) async {
    await pump(tester, const Scaffold(body: PaymentsUnderReviewBanner()));
    expect(find.text('Payment received, order not confirmed'), findsNothing);
  });

  testWidgets('refund progress reads as on its way, refunded or failed', (
    tester,
  ) async {
    await pump(
      tester,
      const Scaffold(
        body: Column(
          children: [
            RefundStatusLine(status: 'requested', amountPaise: 12000),
            RefundStatusLine(status: 'succeeded', amountPaise: 12000),
            RefundStatusLine(status: 'failed', amountPaise: 12000),
          ],
        ),
      ),
    );
    expect(find.textContaining('on its way'), findsOneWidget);
    expect(find.textContaining('Refunded'), findsOneWidget);
    expect(find.textContaining("couldn"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
