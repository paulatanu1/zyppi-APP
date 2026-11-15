import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';

/// Home's "Buy again" row: products from the user's delivered orders, most
/// recently ordered first, at today's catalog price (inactive products drop
/// out). Empty for guests, new users, or if orders can't be read — the row
/// is a convenience, so it hides rather than showing an error.
final buyAgainProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  try {
    final orders = await ref.watch(orderRepositoryProvider).getOrders();
    final delivered =
        orders.where((o) => o.status == OrderStatus.delivered).toList()
          ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    final ids = <String>[];
    for (final order in delivered) {
      for (final item in order.items) {
        if (!ids.contains(item.productId)) ids.add(item.productId);
      }
    }
    if (ids.isEmpty) return const [];

    final wanted = ids.take(buyAgainMax).toList();
    final products = await ref
        .read(catalogRepositoryProvider)
        .fetchProductsByIds(wanted);
    final byId = {for (final p in products) p.id: p};
    return [
      for (final id in wanted)
        if (byId[id] case final p? when p.variants.isNotEmpty) p,
    ];
  } catch (_) {
    return const [];
  }
});

const buyAgainMax = 10;
