import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/order/domain/order_repository.dart';

class OrdersNotifier extends StateNotifier<List<Order>> {
  final OrderRepository repository;

  OrdersNotifier(this.repository) : super(const []) {
    _load();
    repository.watch().listen((_) => _load());
  }

  void _load() {
    state = repository.getOrders();
  }
}

final ordersProvider =
    StateNotifierProvider.autoDispose<OrdersNotifier, List<Order>>(
      (ref) => OrdersNotifier(ref.read(orderRepositoryProvider)),
    );
