import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';

/// What went wrong with a delivered item (functions/src/wallet/model.ts).
enum ClaimKind { missing, wrong, damaged, expired }

/// What the customer wants back.
enum ClaimResolution { wallet, original, replacement }

/// "Report a problem" is open this long after delivery.
const claimWindow = Duration(hours: 2);

/// At most this many photos per claim.
const maxClaimPhotos = 3;

/// Whether [order] can still be reported, at [now].
bool canReportProblem(Order order, DateTime now) {
  final delivered = order.deliveredAt;
  return delivered != null &&
      order.replacementOf == null &&
      order.openIssueId == null &&
      now.difference(delivered) <= claimWindow &&
      order.items.indexed.any((e) => unitsLeftToClaim(order, e.$1) > 0);
}

/// Units of line [index] that can still be claimed.
int unitsLeftToClaim(Order order, int index) =>
    order.items[index].quantity - (order.claimedQty['$index'] ?? 0);

/// "Back to original payment" only for orders paid online (UPI / card).
bool canRefundToOriginal(Order order) =>
    order.paymentMethod == upiPaymentMethod ||
    order.paymentMethod == cardPaymentMethod;

/// One claim line the customer chose.
class ClaimLineInput {
  const ClaimLineInput({
    required this.index,
    required this.quantity,
    required this.kind,
  });

  final int index;
  final int quantity;
  final ClaimKind kind;

  Map<String, Object> toJson() => {
    'index': index,
    'quantity': quantity,
    'kind': kind.name,
  };
}

/// A claim as the customer sees it (orderIssues/{id}).
class OrderIssue {
  const OrderIssue({
    required this.id,
    required this.status,
    required this.amountPaise,
    required this.resolutionWanted,
    this.resolutionType,
    this.walletPaise = 0,
    this.refundPaise = 0,
    this.replacementOrderId,
    this.rejectReason,
    this.createdAt,
  });

  final String id;

  /// open · resolving · approved · rejected
  final String status;
  final int amountPaise;
  final String resolutionWanted;
  final String? resolutionType;
  final int walletPaise;
  final int refundPaise;
  final String? replacementOrderId;
  final String? rejectReason;
  final DateTime? createdAt;

  bool get isOpen => status == 'open' || status == 'resolving';

  /// Automatic return in progress: a rider collects, the store receives,
  /// then the refund goes out (functions/src/returns).
  bool get isReturning => status == 'returning';

  factory OrderIssue.fromMap(String id, Map<String, dynamic> d) {
    final r = (d['resolution'] as Map?) ?? const {};
    int n(Object? v) => v is num ? v.round() : 0;
    return OrderIssue(
      id: id,
      status: d['status'] as String? ?? 'open',
      amountPaise: n(d['amountPaise']),
      resolutionWanted: d['resolutionWanted'] as String? ?? 'wallet',
      resolutionType: r['type'] as String?,
      walletPaise: n(r['walletPaise']),
      refundPaise: n(r['refundPaise']),
      replacementOrderId: r['replacementOrderId'] as String?,
      rejectReason: d['rejectReason'] as String?,
      createdAt: d['createdAt'] is Timestamp
          ? (d['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}

/// Where a return pickup is (returns/{id}; functions/src/returns/model.ts).
enum ReturnStep {
  searching,
  assigned,
  atDoor,
  collected,
  atStore,
  received,
  review,
  failed,
  cancelled,
}

ReturnStep returnStepOf(String? status) => switch (status) {
  'assigned' => ReturnStep.assigned,
  'at_customer' => ReturnStep.atDoor,
  'picked_up' => ReturnStep.collected,
  'at_store' => ReturnStep.atStore,
  'received' => ReturnStep.received,
  'review' => ReturnStep.review,
  'failed' => ReturnStep.failed,
  'cancelled' => ReturnStep.cancelled,
  _ => ReturnStep.searching,
};

/// One return pickup as the customer sees it.
class CustomerReturn {
  const CustomerReturn({
    required this.id,
    required this.step,
    required this.storeName,
    required this.itemCount,
    this.riderName,
    this.riderPhone,
  });

  final String id;
  final ReturnStep step;
  final String storeName;
  final int itemCount;
  final String? riderName;
  final String? riderPhone;

  /// The customer still has to hand the item over (show the code).
  bool get awaitingPickup =>
      step == ReturnStep.searching ||
      step == ReturnStep.assigned ||
      step == ReturnStep.atDoor;

  factory CustomerReturn.fromMap(String id, Map<String, dynamic> d) =>
      CustomerReturn(
        id: id,
        step: returnStepOf(d['status'] as String?),
        storeName: d['storeName'] as String? ?? '',
        itemCount: ((d['lines'] as List?) ?? const []).fold<int>(
          0,
          (n, l) => n + (((l as Map)['quantity'] as num?)?.round() ?? 0),
        ),
        riderName: d['riderName'] as String?,
        riderPhone: d['riderPhone'] as String?,
      );
}

/// What [ClaimRepository.report] did: straight to a return pickup, or ops.
typedef ClaimReport = ({String issueId, bool autoReturn});

/// "Report a problem" on a delivered order (functions/src/wallet/claims.ts).
abstract class ClaimRepository {
  /// Sends the claim; [photos] are compressed JPEGs. [chatId]: the support
  /// chat it started in (updates are posted there too). Throws
  /// [FirebaseFunctionsException] with a code such as CLAIM_WINDOW_OVER or
  /// PHOTO_REQUIRED as its message.
  Future<ClaimReport> report({
    required String orderId,
    required List<ClaimLineInput> lines,
    required List<Uint8List> photos,
    required String note,
    required ClaimResolution resolution,
    String? chatId,
  });

  /// The customer's claims on [orderId], newest first, live.
  Stream<List<OrderIssue>> watchIssues(String orderId);

  /// The customer's return pickups for [orderId], live.
  Stream<List<CustomerReturn>> watchReturns(String orderId);

  /// The 4-digit code the customer tells the rider at the door.
  Stream<String?> watchPickupCode(String returnId);
}

class FirebaseClaimRepository implements ClaimRepository {
  FirebaseClaimRepository(this.auth, this.db, this.functions);

  final FirebaseAuth auth;
  final FirebaseFirestore db;
  final FirebaseFunctions functions;

  @override
  Future<ClaimReport> report({
    required String orderId,
    required List<ClaimLineInput> lines,
    required List<Uint8List> photos,
    required String note,
    required ClaimResolution resolution,
    String? chatId,
  }) async {
    final result = await functions
        .httpsCallable(
          'reportOrderIssue',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 90)),
        )
        .call({
          'orderId': orderId,
          'lines': [for (final l in lines) l.toJson()],
          'photos': [for (final p in photos) base64Encode(p)],
          'note': note,
          'resolution': resolution.name,
          'chatId': ?chatId,
        });
    final data = result.data as Map;
    return (
      issueId: data['issueId'] as String,
      autoReturn: data['autoReturn'] == true,
    );
  }

  @override
  Stream<List<CustomerReturn>> watchReturns(String orderId) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return db
        .collection('returns')
        .where('userId', isEqualTo: uid)
        .where('orderId', isEqualTo: orderId)
        .snapshots()
        .map(
          (snap) => [
            for (final d in snap.docs) CustomerReturn.fromMap(d.id, d.data()),
          ],
        );
  }

  @override
  Stream<String?> watchPickupCode(String returnId) => db
      .collection('returns')
      .doc(returnId)
      .collection('private')
      .doc('pickup')
      .snapshots()
      .map((s) => s.data()?['code'] as String?);

  @override
  Stream<List<OrderIssue>> watchIssues(String orderId) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    // Equality filters only (no composite index); sorted here.
    return db
        .collection('orderIssues')
        .where('userId', isEqualTo: uid)
        .where('orderId', isEqualTo: orderId)
        .snapshots()
        .map((snap) {
          final list = [
            for (final d in snap.docs) OrderIssue.fromMap(d.id, d.data()),
          ];
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(9999)).compareTo(
              a.createdAt ?? DateTime(9999),
            ),
          );
          return list;
        });
  }
}

/// No backend in the mock flavor.
class MockClaimRepository implements ClaimRepository {
  @override
  Future<ClaimReport> report({
    required String orderId,
    required List<ClaimLineInput> lines,
    required List<Uint8List> photos,
    required String note,
    required ClaimResolution resolution,
    String? chatId,
  }) async => (issueId: 'mock-issue', autoReturn: false);

  @override
  Stream<List<OrderIssue>> watchIssues(String orderId) =>
      Stream.value(const []);

  @override
  Stream<List<CustomerReturn>> watchReturns(String orderId) =>
      Stream.value(const []);

  @override
  Stream<String?> watchPickupCode(String returnId) => Stream.value(null);
}

final claimRepositoryProvider = Provider<ClaimRepository>(
  (ref) => Env.isMockDataSource
      ? MockClaimRepository()
      : FirebaseClaimRepository(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
          zyppiFunctions(),
        ),
);

/// The customer's claims on one order, newest first.
final orderIssuesProvider = StreamProvider.autoDispose
    .family<List<OrderIssue>, String>(
      (ref, orderId) => ref.watch(claimRepositoryProvider).watchIssues(orderId),
    );

/// The customer's return pickups on one order.
final orderReturnsProvider = StreamProvider.autoDispose
    .family<List<CustomerReturn>, String>(
      (ref, orderId) =>
          ref.watch(claimRepositoryProvider).watchReturns(orderId),
    );

/// The door code for one return.
final returnPickupCodeProvider = StreamProvider.autoDispose
    .family<String?, String>(
      (ref, returnId) =>
          ref.watch(claimRepositoryProvider).watchPickupCode(returnId),
    );
