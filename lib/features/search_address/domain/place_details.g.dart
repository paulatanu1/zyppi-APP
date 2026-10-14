// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceDetails _$PlaceDetailsFromJson(Map<String, dynamic> json) =>
    _PlaceDetails(
      htmlAttributions: json['htmlAttributions'] as List<dynamic>?,
      result: json['result'] == null
          ? null
          : PlaceResult.fromJson(json['result'] as Map<String, dynamic>),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$PlaceDetailsToJson(_PlaceDetails instance) =>
    <String, dynamic>{
      'htmlAttributions': instance.htmlAttributions,
      'result': instance.result,
      'status': instance.status,
    };

_PlaceResult _$PlaceResultFromJson(Map<String, dynamic> json) => _PlaceResult(
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
  types: (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
  url: json['url'] as String?,
  utcOffset: (json['utcOffset'] as num?)?.toInt(),
  vicinity: json['vicinity'] as String?,
);

Map<String, dynamic> _$PlaceResultToJson(_PlaceResult instance) =>
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

_AddressComponent _$AddressComponentFromJson(Map<String, dynamic> json) =>
    _AddressComponent(
      longName: json['longName'] as String?,
      shortName: json['shortName'] as String?,
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AddressComponentToJson(_AddressComponent instance) =>
    <String, dynamic>{
      'longName': instance.longName,
      'shortName': instance.shortName,
      'types': instance.types,
    };

_Geometry _$GeometryFromJson(Map<String, dynamic> json) => _Geometry(
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  viewport: json['viewport'] == null
      ? null
      : Viewport.fromJson(json['viewport'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GeometryToJson(_Geometry instance) => <String, dynamic>{
  'location': instance.location,
  'viewport': instance.viewport,
};

_Location _$LocationFromJson(Map<String, dynamic> json) => _Location(
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LocationToJson(_Location instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};

_Viewport _$ViewportFromJson(Map<String, dynamic> json) => _Viewport(
  northeast: json['northeast'] == null
      ? null
      : Location.fromJson(json['northeast'] as Map<String, dynamic>),
  southwest: json['southwest'] == null
      ? null
      : Location.fromJson(json['southwest'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ViewportToJson(_Viewport instance) => <String, dynamic>{
  'northeast': instance.northeast,
  'southwest': instance.southwest,
};
