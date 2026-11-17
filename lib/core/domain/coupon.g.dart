// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coupon _$CouponFromJson(Map<String, dynamic> json) => _Coupon(
  code: json['code'] as String,
  description: json['description'] as String,
  discountPaise: (json['discountPaise'] as num?)?.toInt() ?? 0,
  type:
      $enumDecodeNullable(_$CouponTypeEnumMap, json['type']) ?? CouponType.flat,
  percent: (json['percent'] as num?)?.toInt() ?? 0,
  maxDiscountPaise: (json['maxDiscountPaise'] as num?)?.toInt(),
  minOrderPaise: (json['minOrderPaise'] as num?)?.toInt(),
);

Map<String, dynamic> _$CouponToJson(_Coupon instance) => <String, dynamic>{
  'code': instance.code,
  'description': instance.description,
  'discountPaise': instance.discountPaise,
  'type': _$CouponTypeEnumMap[instance.type]!,
  'percent': instance.percent,
  'maxDiscountPaise': instance.maxDiscountPaise,
  'minOrderPaise': instance.minOrderPaise,
};

const _$CouponTypeEnumMap = {
  CouponType.flat: 'flat',
  CouponType.percent: 'percent',
};
