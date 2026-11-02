import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/data/supabase_order_repository_impl.dart';
import 'package:zippy/core/order/domain/order_repository.dart';

/// Opened once in bootstrap() and provided via [orderBoxProvider]'s
/// override, same pattern as core/cart's cartBoxProvider.
final orderBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError(
    'orderBoxProvider must be overridden with an opened Hive box in bootstrap()',
  ),
);

class HiveOrderRepository implements OrderRepository {
  static const _ordersKey = 'orders';

  final Box box;

  HiveOrderRepository(this.box);

  @override
  Future<List<Order>> getOrders() async {
    final raw = box.get(_ordersKey) as List<dynamic>? ?? const [];

    final orders = raw
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));

    return orders;
  }

  @override
  Future<Order?> getOrderById(String id) async {
    for (final order in await getOrders()) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<String> placeOrder(
    Order order, {
    required String deliverySlotId,
    String? couponCode,
  }) async {
    final orders = await getOrders();
    orders.insert(0, order);

    await box.put(_ordersKey, orders.map((o) => o.toJson()).toList());

    return order.id;
  }

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    orders[index] = orders[index].copyWith(status: status);

    await box.put(_ordersKey, orders.map((o) => o.toJson()).toList());
  }

  @override
  Stream<void> watch() => box.watch(key: _ordersKey).map((_) {});
}

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => Env.isMockDataSource
      ? HiveOrderRepository(ref.read(orderBoxProvider))
      : SupabaseOrderRepository(Supabase.instance.client),
);
