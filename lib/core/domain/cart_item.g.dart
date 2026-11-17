// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  productId: json['productId'] as String,
  variantId: json['variantId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  offerId: json['offerId'] as String?,
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'productId': instance.productId,
  'variantId': instance.variantId,
  'quantity': instance.quantity,
  'offerId': instance.offerId,
};
