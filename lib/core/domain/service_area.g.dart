// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_area.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceArea _$ServiceAreaFromJson(Map<String, dynamic> json) => _ServiceArea(
  id: json['id'] as String,
  name: json['name'] as String,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ServiceAreaToJson(_ServiceArea instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
    };
