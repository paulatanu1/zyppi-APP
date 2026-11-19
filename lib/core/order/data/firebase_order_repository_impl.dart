import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/domain/order_repository.dart';

/// Orders are read-only for the app: the placeOrder Cloud Function creates
/// them (pricing, stock and coupon checked server-side), the admin panel
/// changes their status, and the customer can only cancel through the
/// cancelMyOrder function.
class FirebaseOrderRepository implements OrderRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  FirebaseOrderRepository(this.auth, this.firestore, this.functions);

  CollectionReference<Map<String, dynamic>> get _orders =>
      firestore.collection('orders');

  Query<Map<String, dynamic>>? get _mine {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    return _orders
        .where('userId', isEqualTo: uid)
        .orderBy('placedAt', descending: true);
  }

  @override
  Future<List<Order>> getOrders({int? limit}) async {
    final query = _mine;
    if (query == null) return const [];
    final snap = await (limit == null ? query : query.limit(limit)).get();
    return snap.docs.map(orderFromDoc).toList();
  }

  @override
  Future<Order?> getOrderById(String id) async {
    final doc = await _orders.doc(id).get();
    return doc.exists ? orderFromDoc(doc) : null;
  }

  @override
  Future<String> placeOrder(
    Order order, {
    required String deliverySlotId,
    String? couponCode,
    bool useWallet = false,
    int? walletBalancePaise,
  }) async {
    final result = await functions.httpsCallable('placeOrder').call({
      'addressId': order.addressId,
      'deliverySlotId': deliverySlotId,
      'paymentMethod': order.paymentMethod,
      'tipPaise': order.tipPaise,
      'couponCode': couponCode,
      'useWallet': useWallet,
      'walletBalancePaise': ?walletBalancePaise,
    });
    return (result.data as Map)['orderId'] as String;
  }

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) {
    throw UnsupportedError(
      'Order status is changed only by the admin panel '
      '(adminUpdateOrderStatus Cloud Function).',
    );
  }

  @override
  Future<void> cancelOrder(String orderId, CancelReason reason) async {
    try {
      await functions.httpsCallable('cancelMyOrder').call({
        'orderId': orderId,
        'reason': reason.code,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'failed-precondition' &&
          (e.message == 'TOO_LATE_TO_CANCEL' ||
              e.message == 'ALREADY_CANCELLED')) {
        throw const OrderCancelTooLate();
      }
      rethrow;
    }
  }

  @override
  Stream<List<Order>> watchOrders({int limit = recentOrdersLimit}) {
    final query = _mine;
    if (query == null) return Stream.value(const []);
    return query
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(orderFromDoc).toList());
  }

  @override
  Stream<Order?> watchOrder(String id) => _orders
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? orderFromDoc(doc) : null);
}

/// A Firestore order document → [Order].
Order orderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data() ?? const {};
  final items = (d['items'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>()
      .map(
        (item) => OrderItem(
          image: item['image'] as String?,
          productId: item['productId'] as String? ?? '',
          variantId: item['variantId'] as String,
          name: item['name'] as String,
          unit: item['unit'] as String,
          quantity: item['quantity'] as int,
          pricePaise: item['pricePaise'] as int,
          sellerId: item['sellerId'] as String?,
          sellerName: item['sellerName'] as String?,
        ),
      )
      .toList();

  // Pending server timestamp (just placed, still in the local cache).
  final placedAt = d['placedAt'] as Timestamp?;

  return Order(
    id: doc.id,
    items: items,
    status: _parseStatus(d['status'] as String? ?? 'placed'),
    placedAt: placedAt?.toDate() ?? DateTime.now(),
    itemTotalPaise: d['itemTotalPaise'] as int,
    deliveryFeePaise: d['deliveryFeePaise'] as int,
    handlingFeePaise: d['handlingFeePaise'] as int,
    tipPaise: d['tipPaise'] as int,
    discountPaise: d['discountPaise'] as int,
    addressLabel: d['addressLabel'] as String?,
    addressText: d['addressText'] as String?,
    riderName: d['riderName'] as String?,
    riderPhone: d['riderPhone'] as String?,
    etaMinutes: d['etaMinutes'] as int?,
    totalPaise: d['totalPaise'] as int,
    addressId: d['addressId'] as String?,
    paymentMethod: d['paymentMethod'] as String,
    walletPaise: (d['walletPaise'] as num?)?.round() ?? 0,
    payablePaise: ((d['payment'] as Map?)?['amountPaise'] as num?)?.round(),
    deliveredAt: (d['deliveredAt'] as Timestamp?)?.toDate(),
    openIssueId: d['openIssueId'] as String?,
    claimedQty: {
      for (final e in ((d['claimedQty'] as Map?) ?? const {}).entries)
        if (e.value is num) '${e.key}': (e.value as num).round(),
    },
    replacementOf: d['replacementOf'] as String?,
  );
}

OrderStatus _parseStatus(String value) => switch (value) {
  'placed' => OrderStatus.placed,
  'packed' => OrderStatus.packed,
  'out_for_delivery' => OrderStatus.outForDelivery,
  'delivered' => OrderStatus.delivered,
  'cancelled' => OrderStatus.cancelled,
  // A status added server-side later mustn't break the whole list.
  _ => OrderStatus.placed,
};
