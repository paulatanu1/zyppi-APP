import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';

final orderByIdProvider = FutureProvider.autoDispose.family<Order?, String>((
  ref,
  orderId,
) async {
  final orders = await ref.watch(orderRepositoryProvider).getOrders();

  for (final order in orders) {
    if (order.id == orderId) return order;
  }

  return null;
});
