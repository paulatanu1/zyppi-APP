import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  factory Order({
    required String id,
    required List<OrderItem> items,
    required OrderStatus status,
    required DateTime placedAt,
    required int itemTotalPaise,
    required int deliveryFeePaise,
    required int handlingFeePaise,
    required int tipPaise,
    required int discountPaise,
    required int totalPaise,
    // Null once the address (or account) is deleted; the snapshot below
    // keeps what was delivered to.
    String? addressId,
    required String paymentMethod,

    /// Address snapshot taken when the order was placed.
    String? addressLabel,
    String? addressText,

    /// Set by the store once a rider is assigned (tracking screen).
    String? riderName,
    String? riderPhone,

    /// The chosen delivery slot's promise, for the tracking ETA.
    int? etaMinutes,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
