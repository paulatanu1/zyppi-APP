import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';

/// One order, fetched directly (not by loading every order).
final orderByIdProvider = FutureProvider.autoDispose.family<Order?, String>(
  (ref, orderId) => ref.watch(orderRepositoryProvider).getOrderById(orderId),
);
