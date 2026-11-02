import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/order/domain/order_repository.dart';
import 'package:zippy/features/order_tracking/application/order_tracking_state.dart';

/// Fake order lifecycle timer (PLAN.md): placed → packed → out for
/// delivery → delivered, advancing every few seconds while this
/// provider is alive.
class OrderTrackingProvider extends StateNotifier<OrderTrackingState> {
  static const _sequence = [
    OrderStatus.placed,
    OrderStatus.packed,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];
  static const _stepDuration = Duration(seconds: 5);

  final OrderRepository repository;
  final String orderId;
  Timer? _timer;
  StreamSubscription<void>? _watchSubscription;

  OrderTrackingProvider(this.repository, this.orderId)
    : super(OrderTrackingState()) {
    _load();

    // Under Firebase, status changes come from the admin panel, not this
    // client — a Firestore listener (repository.watch()) is what tells
    // us to re-read the order. The mock flavor drives its own fake
    // lifecycle timer below instead.
    if (!Env.isMockDataSource) {
      _watchSubscription = repository.watch().listen((_) => _load());
    }
  }

  Future<void> _load() async {
    state = state.copyWith(error: null);
    try {
      final order = await repository.getOrderById(orderId);
      if (!mounted) return;

      state = state.copyWith(order: order, loading: false);
    } catch (error) {
      if (!mounted) return;
      // Keep showing the last known order if a live refresh fails.
      state = state.copyWith(loading: false, error: error.toString());
      return;
    }

    _scheduleNextStep();
  }

  Future<void> retry() {
    state = state.copyWith(loading: state.order == null);
    return _load();
  }

  void _scheduleNextStep() {
    // The fake lifecycle timer only applies to the offline mock flavor —
    // under Firebase, status is server-controlled and arrives through
    // repository.watch().
    if (!Env.isMockDataSource) return;

    final order = state.order;
    if (order == null) return;

    final currentIndex = _sequence.indexOf(order.status);
    if (currentIndex == -1 || currentIndex >= _sequence.length - 1) return;

    _timer?.cancel();
    _timer = Timer(_stepDuration, () async {
      final nextStatus = _sequence[currentIndex + 1];

      await repository.updateStatus(orderId, nextStatus);
      if (!mounted) return;

      state = state.copyWith(order: order.copyWith(status: nextStatus));

      _scheduleNextStep();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _watchSubscription?.cancel();
    super.dispose();
  }
}

final orderTrackingProvider = StateNotifierProvider.autoDispose
    .family<OrderTrackingProvider, OrderTrackingState, String>(
      (ref, orderId) =>
          OrderTrackingProvider(ref.read(orderRepositoryProvider), orderId),
    );
