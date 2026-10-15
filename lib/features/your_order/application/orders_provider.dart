import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';

final ordersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);

  final subscription = repository.watch().listen((_) => ref.invalidateSelf());
  ref.onDispose(subscription.cancel);

  return repository.getOrders();
});
