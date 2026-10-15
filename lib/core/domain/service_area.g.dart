// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_area.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceArea _$ServiceAreaFromJson(Map<String, dynamic> json) => _ServiceArea(
  id: json['id'] as String,
  name: json['name'] as String,
  isActive: json['isActive'] as bool? ?? true,
  centerLat: (json['centerLat'] as num?)?.toDouble(),
  centerLng: (json['centerLng'] as num?)?.toDouble(),
  radiusMeters: (json['radiusMeters'] as num?)?.toInt(),
);

Map<String, dynamic> _$ServiceAreaToJson(_ServiceArea instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
      'centerLat': instance.centerLat,
      'centerLng': instance.centerLng,
      'radiusMeters': instance.radiusMeters,
    };
