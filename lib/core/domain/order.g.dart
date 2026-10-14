// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  placedAt: DateTime.parse(json['placedAt'] as String),
  itemTotalPaise: (json['itemTotalPaise'] as num).toInt(),
  deliveryFeePaise: (json['deliveryFeePaise'] as num).toInt(),
  handlingFeePaise: (json['handlingFeePaise'] as num).toInt(),
  tipPaise: (json['tipPaise'] as num).toInt(),
  discountPaise: (json['discountPaise'] as num).toInt(),
  totalPaise: (json['totalPaise'] as num).toInt(),
  addressId: json['addressId'] as String,
  paymentMethod: json['paymentMethod'] as String,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'items': instance.items,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'placedAt': instance.placedAt.toIso8601String(),
  'itemTotalPaise': instance.itemTotalPaise,
  'deliveryFeePaise': instance.deliveryFeePaise,
  'handlingFeePaise': instance.handlingFeePaise,
  'tipPaise': instance.tipPaise,
  'discountPaise': instance.discountPaise,
  'totalPaise': instance.totalPaise,
  'addressId': instance.addressId,
  'paymentMethod': instance.paymentMethod,
};

const _$OrderStatusEnumMap = {
  OrderStatus.placed: 'placed',
  OrderStatus.packed: 'packed',
  OrderStatus.outForDelivery: 'outForDelivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
