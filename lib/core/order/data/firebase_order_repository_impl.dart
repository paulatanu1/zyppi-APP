import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/domain/order_repository.dart';

/// Orders are read-only for the app: the placeOrder Cloud Function creates
/// them (pricing, stock and coupon checked server-side) and only the
/// admin panel changes their status.
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
  Future<List<Order>> getOrders() async {
    final query = _mine;
    if (query == null) return const [];
    final snap = await query.get();
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
  }) async {
    final result = await functions.httpsCallable('placeOrder').call({
      'addressId': order.addressId,
      'deliverySlotId': deliverySlotId,
      'paymentMethod': order.paymentMethod,
      'tipPaise': order.tipPaise,
      'couponCode': couponCode,
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

  /// Fires whenever one of the signed-in user's orders changes (status
  /// updates from the admin panel); callers re-read [getOrders].
  @override
  Stream<void> watch() {
    final query = _mine;
    if (query == null) return const Stream.empty();
    // The first snapshot is the current state, not a change.
    return query.snapshots().skip(1).map((_) {});
  }
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
