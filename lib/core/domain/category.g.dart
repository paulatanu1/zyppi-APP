// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: json['name'] as String,
  image: json['image'] as String?,
  colorHex: json['colorHex'] as String,
  borderColorHex: json['borderColorHex'] as String,
  parentId: json['parentId'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
  'colorHex': instance.colorHex,
  'borderColorHex': instance.borderColorHex,
  'parentId': instance.parentId,
  'sortOrder': instance.sortOrder,
};
