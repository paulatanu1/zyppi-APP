import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();

  /// Mock: persists [order] — already built client-side from the cart —
  /// locally and returns its id unchanged.
  /// Supabase: ignores the client-built totals and calls place_order(),
  /// which re-derives everything from the user's synced cart server-side;
  /// returns the server-generated order id.
  Future<String> placeOrder(Order order, {required String deliverySlotId});

  Future<void> updateStatus(String orderId, OrderStatus status);

  /// Fires on every persisted change, so UIs can re-read [getOrders].
  Stream<void> watch();
}
