import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/domain/order_repository.dart';

/// Phase 3: orders are read-only from the client's perspective — every
/// write happens through the place_order() RPC (checkout) or, later,
/// service-role-only status updates (Phase 4 Realtime tracking).
class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient client;

  SupabaseOrderRepository(this.client);

  @override
  Future<List<Order>> getOrders() async {
    final rows = await client
        .from('orders')
        .select('''
          id, status, placedAt:placed_at, itemTotalPaise:item_total_paise,
          deliveryFeePaise:delivery_fee_paise, handlingFeePaise:handling_fee_paise,
          tipPaise:tip_paise, discountPaise:discount_paise, totalPaise:total_paise,
          addressId:address_id, paymentMethod:payment_method,
          items:order_items(
            variantId:product_variant_id, name, unit, quantity, pricePaise:price_paise,
            variant:product_variants(productId:product_id)
          )
        ''')
        .order('placed_at', ascending: false);

    return rows.map(_orderFromRow).toList();
  }

  Order _orderFromRow(Map<String, dynamic> row) {
    final items = (row['items'] as List<dynamic>).map((itemRow) {
      final item = itemRow as Map<String, dynamic>;
      final variant = item['variant'] as Map<String, dynamic>?;

      return OrderItem(
        productId: variant?['productId'] as String? ?? '',
        variantId: item['variantId'] as String,
        name: item['name'] as String,
        unit: item['unit'] as String,
        quantity: item['quantity'] as int,
        pricePaise: item['pricePaise'] as int,
      );
    }).toList();

    return Order(
      id: row['id'] as String,
      items: items,
      status: _parseStatus(row['status'] as String),
      placedAt: DateTime.parse(row['placedAt'] as String),
      itemTotalPaise: row['itemTotalPaise'] as int,
      deliveryFeePaise: row['deliveryFeePaise'] as int,
      handlingFeePaise: row['handlingFeePaise'] as int,
      tipPaise: row['tipPaise'] as int,
      discountPaise: row['discountPaise'] as int,
      totalPaise: row['totalPaise'] as int,
      addressId: row['addressId'] as String,
      paymentMethod: row['paymentMethod'] as String,
    );
  }

  @override
  Future<String> placeOrder(
    Order order, {
    required String deliverySlotId,
    String? razorpayOrderId,
    String? razorpayPaymentId,
  }) async {
    final orderId = await client.rpc(
      'place_order',
      params: {
        'p_address_id': order.addressId,
        'p_delivery_slot_id': deliverySlotId,
        'p_payment_method': order.paymentMethod,
        'p_tip_paise': order.tipPaise,
        'p_razorpay_order_id': razorpayOrderId,
        'p_razorpay_payment_id': razorpayPaymentId,
      },
    );

    return orderId as String;
  }

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) {
    throw UnsupportedError(
      'Order status is server-controlled under Supabase — there is no '
      'client write path yet (Phase 4 adds Realtime-driven tracking).',
    );
  }

  /// Phase 4: fires on every change to the signed-in user's `orders` rows
  /// (status updates from a future rider/admin app land here), via
  /// Postgres Changes on the supabase_realtime publication - see
  /// 20261015120900_orders_realtime.sql. Callers re-read [getOrders].
  @override
  Stream<void> watch() {
    final controller = StreamController<void>.broadcast();
    final channel = client
        .channel('orders-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) => controller.add(null),
        )
        .subscribe();

    controller.onCancel = () => client.removeChannel(channel);

    return controller.stream;
  }
}

OrderStatus _parseStatus(String value) => switch (value) {
  'placed' => OrderStatus.placed,
  'packed' => OrderStatus.packed,
  'out_for_delivery' => OrderStatus.outForDelivery,
  'delivered' => OrderStatus.delivered,
  'cancelled' => OrderStatus.cancelled,
  _ => throw ArgumentError('Unknown order status: $value'),
};
