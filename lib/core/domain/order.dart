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
    required String addressId,
    required String paymentMethod,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
