// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  id: json['id'] as String,
  label: json['label'] as String,
  line1: json['line1'] as String,
  area: json['area'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  postalCode: json['postalCode'] as String,
  landmark: json['landmark'] as String?,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'line1': instance.line1,
  'area': instance.area,
  'city': instance.city,
  'state': instance.state,
  'postalCode': instance.postalCode,
  'landmark': instance.landmark,
  'lat': instance.lat,
  'lng': instance.lng,
  'isDefault': instance.isDefault,
};
