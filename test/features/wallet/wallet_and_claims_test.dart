import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/push/push_destination.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/checkout/widgets/wallet_pay_card.dart';
import 'package:zippy/features/report_problem/data/claim_repository.dart';
import 'package:zippy/features/report_problem/presentation/claim_status_card.dart';
import 'package:zippy/features/wallet/data/wallet_repository.dart';
import 'package:zippy/features/wallet/presentation/wallet_screen.dart';

import '../../helpers/localized_app.dart';

class _Wallet implements WalletRepository {
  _Wallet(this.balance, this.history);
  final Stream<int> balance;
  final Stream<List<WalletEntry>> history;
  @override
  Stream<int> watchBalance() => balance;
  @override
  Stream<List<WalletEntry>> watchHistory({int limit = 50}) => history;
}

class _Claims implements ClaimRepository {
  _Claims(this.issues, {this.returns = const [], this.code});
  final List<OrderIssue> issues;
  final List<CustomerReturn> returns;
  final String? code;
  @override
  Future<ClaimReport> report({
    required String orderId,
    required List<ClaimLineInput> lines,
    required List<Uint8List> photos,
    required String note,
    required ClaimResolution resolution,
    String? chatId,
  }) async => (issueId: 'i1', autoReturn: true);
  @override
  Stream<List<OrderIssue>> watchIssues(String orderId) => Stream.value(issues);
  @override
  Stream<List<CustomerReturn>> watchReturns(String orderId) =>
      Stream.value(returns);
  @override
  Stream<String?> watchPickupCode(String returnId) => Stream.value(code);
}

Order order({
  DateTime? deliveredAt,
  String method = 'Cash on delivery',
  String? openIssueId,
  Map<String, int> claimed = const {},
  String? replacementOf,
}) => Order(
  id: 'o1',
  items: [
    OrderItem(
      productId: 'p1',
      variantId: 'v1',
      name: 'Milk',
      unit: '1 L',
      quantity: 2,
      pricePaise: 5000,
    ),
  ],
  status: OrderStatus.delivered,
  placedAt: DateTime(2026, 11, 19, 9),
  itemTotalPaise: 10000,
  deliveryFeePaise: 0,
  handlingFeePaise: 500,
  tipPaise: 0,
  discountPaise: 0,
  totalPaise: 10500,
  paymentMethod: method,
  deliveredAt: deliveredAt,
  openIssueId: openIssueId,
  claimedQty: claimed,
  replacementOf: replacementOf,
);

void main() {
  group('wallet maths (same rule as the server)', () {
    test('uses as much as the total needs, never more', () {
      expect(walletToApply(10000, 25000, use: true), 10000);
      expect(walletToApply(30000, 25000, use: true), 25000);
      expect(walletToApply(30000, 25000, use: false), 0);
      expect(walletToApply(0, 25000, use: true), 0);
    });
  });

  group('report a problem: who can', () {
    final now = DateTime(2026, 11, 19, 12);
    test('delivered within 2 hours, units left, nothing open', () {
      expect(
        canReportProblem(
          order(deliveredAt: now.subtract(const Duration(minutes: 30))),
          now,
        ),
        isTrue,
      );
      expect(
        canReportProblem(
          order(
            deliveredAt: now.subtract(const Duration(hours: 2, minutes: 1)),
          ),
          now,
        ),
        isFalse,
      );
      expect(canReportProblem(order(), now), isFalse);
      expect(
        canReportProblem(order(deliveredAt: now, openIssueId: 'i1'), now),
        isFalse,
      );
      expect(
        canReportProblem(order(deliveredAt: now, claimed: {'0': 2}), now),
        isFalse,
      );
      expect(
        canReportProblem(order(deliveredAt: now, replacementOf: 'o0'), now),
        isFalse,
      );
    });

    test('units left and refund to original only for online payments', () {
      expect(unitsLeftToClaim(order(claimed: {'0': 1}), 0), 1);
      expect(canRefundToOriginal(order(method: 'UPI')), isTrue);
      expect(
        canRefundToOriginal(order(method: 'Credit or debit card')),
        isTrue,
      );
      expect(canRefundToOriginal(order()), isFalse);
      expect(canRefundToOriginal(order(method: 'Wallet')), isFalse);
    });
  });

  test('claim and wallet pushes open the right screen', () {
    final claim = pushDestination({'orderId': 'o1', 'issueId': 'i1'});
    expect((claim as OpenRoute).location, '/orderDetailsScreen?orderId=o1');
    final wallet = pushDestination({'screen': 'wallet'});
    expect((wallet as OpenRoute).location, '/walletScreen');
    // Plain order updates still open tracking.
    final update = pushDestination({'orderId': 'o1', 'status': 'packed'});
    expect((update as OpenRoute).location, '/orderTrackingScreen?orderId=o1');
  });

  group('WalletScreen', () {
    Future<void> pump(
      WidgetTester tester,
      _Wallet repo, {
      ThemeData? theme,
      bool disableAnimations = false,
    }) async {
      final container = ProviderContainer(
        overrides: [walletRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await pumpLocalizedApp(
        tester,
        container: container,
        theme: theme ?? ZyppiTheme.light,
        disableAnimations: disableAnimations,
        home: const WalletScreen(),
      );
    }

    testWidgets('loading shows skeletons', (tester) async {
      final never = StreamController<int>();
      final neverList = StreamController<List<WalletEntry>>();
      addTearDown(never.close);
      addTearDown(neverList.close);
      // Reduced motion: the shimmer stands still, so the test can settle.
      await pump(
        tester,
        _Wallet(never.stream, neverList.stream),
        disableAnimations: true,
      );
      expect(find.text('History'), findsOneWidget);
      expect(find.byType(ZSkeleton), findsWidgets);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('empty', (tester) async {
      await pump(tester, _Wallet(Stream.value(0), Stream.value(const [])));
      await tester.pumpAndSettle();
      expect(find.text('₹0'), findsOneWidget);
      expect(
        find.text(
          'No wallet activity yet. Refunds and credits will show here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('error offers retry', (tester) async {
      await pump(
        tester,
        _Wallet(Stream.value(0), Stream.error(Exception('offline'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('balance and history in dark theme', (tester) async {
      await pump(
        tester,
        _Wallet(
          Stream.value(12500),
          Stream.value([
            WalletEntry(
              id: 'claim_i1',
              type: 'claim',
              amountPaise: 5000,
              reason: 'x',
              at: DateTime(2026, 11, 19, 10),
            ),
            WalletEntry(
              id: 'order_o2',
              type: 'spend',
              amountPaise: -2500,
              reason: 'Order payment',
              orderId: 'o2',
              at: DateTime(2026, 11, 19, 11),
            ),
          ]),
        ),
        theme: ZyppiTheme.dark,
      );
      await tester.pumpAndSettle();
      expect(find.text('₹125'), findsOneWidget);
      expect(find.text('Refund for a reported problem'), findsOneWidget);
      expect(find.text('+₹50'), findsOneWidget);
      expect(find.text('Paid for an order'), findsOneWidget);
      expect(find.text('−₹25'), findsOneWidget);
    });
  });

  group('ClaimStatusCard', () {
    Future<void> pump(
      WidgetTester tester,
      Order o,
      List<OrderIssue> issues, {
      List<CustomerReturn> returns = const [],
      String? code,
    }) async {
      final container = ProviderContainer(
        overrides: [
          claimRepositoryProvider.overrideWithValue(
            _Claims(issues, returns: returns, code: code),
          ),
        ],
      );
      addTearDown(container.dispose);
      await pumpLocalizedApp(
        tester,
        container: container,
        theme: ZyppiTheme.light,
        home: Scaffold(body: ClaimStatusCard(order: o)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('offers Report a problem inside the window', (tester) async {
      await pump(tester, order(deliveredAt: DateTime.now()), const []);
      expect(find.text('Report a problem'), findsOneWidget);
    });

    testWidgets('nothing after the window with no claim', (tester) async {
      await pump(
        tester,
        order(deliveredAt: DateTime.now().subtract(const Duration(hours: 3))),
        const [],
      );
      expect(find.text('Report a problem'), findsNothing);
    });

    testWidgets('shows an approved wallet claim', (tester) async {
      await pump(
        tester,
        order(deliveredAt: DateTime.now().subtract(const Duration(hours: 3))),
        const [
          OrderIssue(
            id: 'i1',
            status: 'approved',
            amountPaise: 5000,
            resolutionWanted: 'wallet',
            resolutionType: 'wallet',
            walletPaise: 5000,
          ),
        ],
      );
      expect(find.text('Problem sorted'), findsOneWidget);
      expect(find.text('₹50 added to your wallet.'), findsOneWidget);
    });

    testWidgets('automatic return: step, store and door code', (tester) async {
      await pump(
        tester,
        order(deliveredAt: DateTime.now(), openIssueId: 'i1'),
        const [
          OrderIssue(
            id: 'i1',
            status: 'returning',
            amountPaise: 5000,
            resolutionWanted: 'wallet',
          ),
        ],
        returns: const [
          CustomerReturn(
            id: 'i1_s1',
            step: ReturnStep.atDoor,
            storeName: 'Ranchi Dark Store',
            itemCount: 1,
            riderName: 'Ravi',
            riderPhone: '+919800000000',
          ),
        ],
        code: '4821',
      );
      expect(find.text('Return in progress'), findsOneWidget);
      expect(find.text('1 item · Ranchi Dark Store'), findsOneWidget);
      expect(find.text('4 8 2 1'), findsOneWidget);
      expect(find.text('Call Ravi'), findsOneWidget);
      // Open claim: no second report.
      expect(find.text('Report a problem'), findsNothing);
    });

    test('return steps from the server status', () {
      expect(returnStepOf('at_customer'), ReturnStep.atDoor);
      expect(returnStepOf('picked_up'), ReturnStep.collected);
      expect(returnStepOf('requested'), ReturnStep.searching);
      expect(returnStepOf('offered'), ReturnStep.searching);
      expect(returnStepOf('received'), ReturnStep.received);
    });

    testWidgets('shows a rejection reason', (tester) async {
      await pump(
        tester,
        order(deliveredAt: DateTime.now(), claimed: {'0': 2}),
        const [
          OrderIssue(
            id: 'i1',
            status: 'rejected',
            amountPaise: 5000,
            resolutionWanted: 'wallet',
            rejectReason: 'Photo shows a sealed pack',
          ),
        ],
      );
      expect(find.text('Report not approved'), findsOneWidget);
      expect(find.text('Photo shows a sealed pack'), findsOneWidget);
    });
  });

  group('WalletPayCard (checkout)', () {
    for (final (name, theme) in [
      ('light', ZyppiTheme.light),
      ('dark', ZyppiTheme.dark),
    ]) {
      testWidgets('$name: on shows what is used, off what is available', (
        tester,
      ) async {
        var use = true;
        final container = ProviderContainer();
        addTearDown(container.dispose);
        await pumpLocalizedApp(
          tester,
          container: container,
          theme: theme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => WalletPayCard(
                balancePaise: 12500,
                appliedPaise: use ? 10500 : 0,
                use: use,
                onChanged: (v) => setState(() => use = v),
              ),
            ),
          ),
        );
        expect(find.text('Use Zyppi wallet'), findsOneWidget);
        expect(find.text('₹105 will be used · balance ₹125'), findsOneWidget);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(find.text('₹125 available'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
