// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_current_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentLocationResponse _$CurrentLocationResponseFromJson(
  Map<String, dynamic> json,
) => _CurrentLocationResponse(
  plusCode: json['plus_code'] == null
      ? null
      : PlusCode.fromJson(json['plus_code'] as Map<String, dynamic>),
  results: (json['results'] as List<dynamic>)
      .map((e) => Result.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CurrentLocationResponseToJson(
  _CurrentLocationResponse instance,
) => <String, dynamic>{
  'plus_code': instance.plusCode,
  'results': instance.results,
};

_PlusCode _$PlusCodeFromJson(Map<String, dynamic> json) => _PlusCode(
  compoundCode: json['compound_code'] as String?,
  globalCode: json['global_code'] as String?,
);

Map<String, dynamic> _$PlusCodeToJson(_PlusCode instance) => <String, dynamic>{
  'compound_code': instance.compoundCode,
  'global_code': instance.globalCode,
};

_Result _$ResultFromJson(Map<String, dynamic> json) => _Result(
  addressComponents: (json['address_components'] as List<dynamic>?)
      ?.map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
      .toList(),
  formattedAddress: json['formatted_address'] as String?,
  geometry: json['geometry'] == null
      ? null
      : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
  navigationPoints: (json['navigation_points'] as List<dynamic>?)
      ?.map((e) => NavigationPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  placeId: json['place_id'] as String?,
  plusCode: json['plus_code'] == null
      ? null
      : PlusCode.fromJson(json['plus_code'] as Map<String, dynamic>),
  types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ResultToJson(_Result instance) => <String, dynamic>{
  'address_components': instance.addressComponents,
  'formatted_address': instance.formattedAddress,
  'geometry': instance.geometry,
  'navigation_points': instance.navigationPoints,
  'place_id': instance.placeId,
  'plus_code': instance.plusCode,
  'types': instance.types,
};

_AddressComponent _$AddressComponentFromJson(Map<String, dynamic> json) =>
    _AddressComponent(
      longName: json['long_name'] as String?,
      shortName: json['short_name'] as String?,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AddressComponentToJson(_AddressComponent instance) =>
    <String, dynamic>{
      'long_name': instance.longName,
      'short_name': instance.shortName,
      'types': instance.types,
    };

_Geometry _$GeometryFromJson(Map<String, dynamic> json) => _Geometry(
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  locationType: json['location_type'] as String?,
  viewport: json['viewport'] == null
      ? null
      : Viewport.fromJson(json['viewport'] as Map<String, dynamic>),
  bounds: json['bounds'] == null
      ? null
      : Bounds.fromJson(json['bounds'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GeometryToJson(_Geometry instance) => <String, dynamic>{
  'location': instance.location,
  'location_type': instance.locationType,
  'viewport': instance.viewport,
  'bounds': instance.bounds,
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

_Bounds _$BoundsFromJson(Map<String, dynamic> json) => _Bounds(
  northeast: json['northeast'] == null
      ? null
      : Location.fromJson(json['northeast'] as Map<String, dynamic>),
  southwest: json['southwest'] == null
      ? null
      : Location.fromJson(json['southwest'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BoundsToJson(_Bounds instance) => <String, dynamic>{
  'northeast': instance.northeast,
  'southwest': instance.southwest,
};

_NavigationPoint _$NavigationPointFromJson(Map<String, dynamic> json) =>
    _NavigationPoint(
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NavigationPointToJson(_NavigationPoint instance) =>
    <String, dynamic>{'location': instance.location};
