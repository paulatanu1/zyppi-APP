import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();

  /// One order (the order-placed / details / tracking screens), or null.
  Future<Order?> getOrderById(String id);

  /// Mock: persists [order] — already built client-side from the cart —
  /// locally and returns its id unchanged.
  /// Supabase: cash on delivery only. Ignores the client-built totals and
  /// calls place_order(), which re-derives everything from the user's
  /// synced cart server-side; returns the server-generated order id.
  /// Prepaid (PhonePe) orders are created by the server itself once the
  /// payment is verified — see PaymentRepository.verifyPayment.
  Future<String> placeOrder(
    Order order, {
    required String deliverySlotId,
    String? couponCode,
  });

  Future<void> updateStatus(String orderId, OrderStatus status);

  /// Fires on every persisted change, so UIs can re-read [getOrders].
  Stream<void> watch();
}
