import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';

abstract class OrderRepository {
  List<Order> getOrders();

  Future<void> saveOrder(Order order);

  Future<void> updateStatus(String orderId, OrderStatus status);

  /// Fires on every persisted change, so UIs can re-read [getOrders].
  Stream<void> watch();
}
