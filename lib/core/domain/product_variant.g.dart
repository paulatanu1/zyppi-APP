// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) =>
    _ProductVariant(
      id: json['id'] as String,
      label: json['label'] as String,
      pricePaise: (json['pricePaise'] as num).toInt(),
      mrpPaise: (json['mrpPaise'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductVariantToJson(_ProductVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'pricePaise': instance.pricePaise,
      'mrpPaise': instance.mrpPaise,
    };
