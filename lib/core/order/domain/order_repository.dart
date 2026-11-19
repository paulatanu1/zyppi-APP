import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';

abstract class OrderRepository {
  /// The user's orders, newest first; at most [limit] when given.
  Future<List<Order>> getOrders({int? limit});

  /// One order (the order-placed / details / tracking screens), or null.
  Future<Order?> getOrderById(String id);

  /// Mock: persists [order] — already built client-side from the cart —
  /// locally and returns its id unchanged.
  /// Firebase: cash on delivery only. Ignores the client-built totals and
  /// calls the placeOrder function, which re-derives everything from the user's
  /// synced cart server-side; returns the server-generated order id.
  /// Prepaid (PayU) orders are created by the server itself once the
  /// payment is verified — see PaymentRepository.verifyPayment.
  ///
  /// Wallet: [useWallet] spends the balance (cash covers the rest);
  /// [Order.paymentMethod] 'Wallet' = the wallet pays it all.
  /// [walletBalancePaise] is the balance the customer was shown: the
  /// server refuses (WALLET_BALANCE_CHANGED) if the live one differs.
  Future<String> placeOrder(
    Order order, {
    required String deliverySlotId,
    String? couponCode,
    bool useWallet = false,
    int? walletBalancePaise,
  });

  Future<void> updateStatus(String orderId, OrderStatus status);

  /// The customer cancels their own order (cancelMyOrder Cloud Function:
  /// only while it's placed and nothing was picked up; stock, coupon,
  /// wallet and online refund are handled server-side). Throws
  /// [OrderCancelTooLate] when the order has moved on.
  Future<void> cancelOrder(String orderId, CancelReason reason);

  /// The newest [limit] orders, re-emitted on every change. One live
  /// query: a change costs one read, not a re-read of the whole list.
  Stream<List<Order>> watchOrders({int limit});

  /// One order, re-emitted on every change (null if it doesn't exist).
  Stream<Order?> watchOrder(String id);
}

/// Why the customer cancelled (functions/src/orders/cancel_order.ts).
enum CancelReason {
  changedMind('changed_mind', 'cancelReasonChangedMind'),
  orderedByMistake('ordered_by_mistake', 'cancelReasonMistake'),
  deliveryTooSlow('delivery_too_slow', 'cancelReasonTooSlow'),
  wrongAddress('wrong_address', 'cancelReasonWrongAddress'),
  other('other', 'cancelReasonOther');

  const CancelReason(this.code, this.labelKey);

  /// Sent to the server.
  final String code;

  /// Translation key.
  final String labelKey;
}

/// The order was packed or picked up before the cancel reached the server.
class OrderCancelTooLate implements Exception {
  const OrderCancelTooLate();
}

/// How many orders "Your orders" shows.
const recentOrdersLimit = 50;
