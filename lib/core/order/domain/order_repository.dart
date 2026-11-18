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

  /// The newest [limit] orders, re-emitted on every change. One live
  /// query: a change costs one read, not a re-read of the whole list.
  Stream<List<Order>> watchOrders({int limit});

  /// One order, re-emitted on every change (null if it doesn't exist).
  Stream<Order?> watchOrder(String id);
}

/// How many orders "Your orders" shows.
const recentOrdersLimit = 50;
