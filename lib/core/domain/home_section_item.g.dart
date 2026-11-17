// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_section_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeSectionItem _$HomeSectionItemFromJson(Map<String, dynamic> json) =>
    _HomeSectionItem(
      id: json['id'] as String,
      data: json['data'] as Map<String, dynamic>,
      startAt: json['startAt'] == null
          ? null
          : DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] == null
          ? null
          : DateTime.parse(json['endAt'] as String),
      serviceAreaIds:
          (json['serviceAreaIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$HomeSectionItemToJson(_HomeSectionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'startAt': instance.startAt?.toIso8601String(),
      'endAt': instance.endAt?.toIso8601String(),
      'serviceAreaIds': instance.serviceAreaIds,
      'isActive': instance.isActive,
    };
