// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliverySlot _$DeliverySlotFromJson(Map<String, dynamic> json) =>
    _DeliverySlot(
      id: json['id'] as String,
      label: json['label'] as String,
      etaMinutes: (json['etaMinutes'] as num).toInt(),
      isExpress: json['isExpress'] as bool? ?? false,
    );

Map<String, dynamic> _$DeliverySlotToJson(_DeliverySlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'etaMinutes': instance.etaMinutes,
      'isExpress': instance.isExpress,
    };
