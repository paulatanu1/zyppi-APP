// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placeDetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceDetailsImpl _$$PlaceDetailsImplFromJson(Map<String, dynamic> json) =>
    _$PlaceDetailsImpl(
      htmlAttributions: json['htmlAttributions'] as List<dynamic>?,
      result: json['result'] == null
          ? null
          : PlaceResult.fromJson(json['result'] as Map<String, dynamic>),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$PlaceDetailsImplToJson(_$PlaceDetailsImpl instance) =>
    <String, dynamic>{
      'htmlAttributions': instance.htmlAttributions,
      'result': instance.result,
      'status': instance.status,
    };

_$PlaceResultImpl _$$PlaceResultImplFromJson(Map<String, dynamic> json) =>
    _$PlaceResultImpl(
      addressComponents: (json['addressComponents'] as List<dynamic>?)
          ?.map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      adrAddress: json['adrAddress'] as String?,
      formattedAddress: json['formattedAddress'] as String?,
      geometry: json['geometry'] == null
          ? null
          : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      icon: json['icon'] as String?,
      iconBackgroundColor: json['iconBackgroundColor'] as String?,
      iconMaskBaseUri: json['iconMaskBaseUri'] as String?,
      name: json['name'] as String?,
      placeId: json['placeId'] as String?,
      reference: json['reference'] as String?,
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
      url: json['url'] as String?,
      utcOffset: (json['utcOffset'] as num?)?.toInt(),
      vicinity: json['vicinity'] as String?,
    );

Map<String, dynamic> _$$PlaceResultImplToJson(_$PlaceResultImpl instance) =>
    <String, dynamic>{
      'addressComponents': instance.addressComponents,
      'adrAddress': instance.adrAddress,
      'formattedAddress': instance.formattedAddress,
      'geometry': instance.geometry,
      'icon': instance.icon,
      'iconBackgroundColor': instance.iconBackgroundColor,
      'iconMaskBaseUri': instance.iconMaskBaseUri,
      'name': instance.name,
      'placeId': instance.placeId,
      'reference': instance.reference,
      'types': instance.types,
      'url': instance.url,
      'utcOffset': instance.utcOffset,
      'vicinity': instance.vicinity,
    };

_$AddressComponentImpl _$$AddressComponentImplFromJson(
        Map<String, dynamic> json) =>
    _$AddressComponentImpl(
      longName: json['longName'] as String?,
      shortName: json['shortName'] as String?,
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$AddressComponentImplToJson(
        _$AddressComponentImpl instance) =>
    <String, dynamic>{
      'longName': instance.longName,
      'shortName': instance.shortName,
      'types': instance.types,
    };

_$GeometryImpl _$$GeometryImplFromJson(Map<String, dynamic> json) =>
    _$GeometryImpl(
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      viewport: json['viewport'] == null
          ? null
          : Viewport.fromJson(json['viewport'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GeometryImplToJson(_$GeometryImpl instance) =>
    <String, dynamic>{
      'location': instance.location,
      'viewport': instance.viewport,
    };

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

_$ViewportImpl _$$ViewportImplFromJson(Map<String, dynamic> json) =>
    _$ViewportImpl(
      northeast: json['northeast'] == null
          ? null
          : Location.fromJson(json['northeast'] as Map<String, dynamic>),
      southwest: json['southwest'] == null
          ? null
          : Location.fromJson(json['southwest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ViewportImplToJson(_$ViewportImpl instance) =>
    <String, dynamic>{
      'northeast': instance.northeast,
      'southwest': instance.southwest,
    };
