import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/order/domain/order_repository.dart';

/// "Your orders": the newest orders, kept live by one listener.
final ordersProvider = StreamProvider.autoDispose<List<Order>>(
  (ref) => ref.watch(orderRepositoryProvider).watchOrders(),
);

/// Paid checkouts waiting for support (audit S2): shown above the orders.
final paymentsUnderReviewProvider =
    StreamProvider.autoDispose<List<PaymentUnderReview>>(
      (ref) => ref.watch(orderRepositoryProvider).watchPaymentsUnderReview(),
    );
