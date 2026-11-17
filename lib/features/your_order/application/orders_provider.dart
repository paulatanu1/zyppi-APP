import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';

/// "Your orders": the newest orders, kept live by one listener.
final ordersProvider = StreamProvider.autoDispose<List<Order>>(
  (ref) => ref.watch(orderRepositoryProvider).watchOrders(),
);
