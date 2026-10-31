// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeSection _$HomeSectionFromJson(Map<String, dynamic> json) => _HomeSection(
  id: json['id'] as String,
  type: json['type'] as String,
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  config: json['config'] as Map<String, dynamic>? ?? const {},
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => HomeSectionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HomeSectionToJson(_HomeSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'config': instance.config,
      'items': instance.items,
    };
