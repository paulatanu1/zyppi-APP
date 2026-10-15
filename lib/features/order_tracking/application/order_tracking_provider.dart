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

    // Under Supabase, status changes come from a future rider/admin app,
    // not this client — Realtime (via repository.watch()) is what tells
    // us to re-read the order. The mock flavor drives its own fake
    // lifecycle timer below instead.
    if (!Env.isMockDataSource) {
      _watchSubscription = repository.watch().listen((_) => _load());
    }
  }

  Future<void> _load() async {
    final orders = await repository.getOrders();
    final match = orders.where((o) => o.id == orderId);

    state = state.copyWith(
      order: match.isEmpty ? null : match.first,
      loading: false,
    );

    _scheduleNextStep();
  }

  void _scheduleNextStep() {
    // The fake lifecycle timer only applies to the offline mock flavor —
    // under Supabase, status is server-controlled (Phase 4 wires it up
    // via Realtime).
    if (!Env.isMockDataSource) return;

    final order = state.order;
    if (order == null) return;

    final currentIndex = _sequence.indexOf(order.status);
    if (currentIndex == -1 || currentIndex >= _sequence.length - 1) return;

    _timer = Timer(_stepDuration, () async {
      final nextStatus = _sequence[currentIndex + 1];

      await repository.updateStatus(orderId, nextStatus);

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
