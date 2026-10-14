// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  productId: json['productId'] as String,
  variantId: json['variantId'] as String,
  name: json['name'] as String,
  unit: json['unit'] as String,
  quantity: (json['quantity'] as num).toInt(),
  pricePaise: (json['pricePaise'] as num).toInt(),
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'variantId': instance.variantId,
      'name': instance.name,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'pricePaise': instance.pricePaise,
    };
