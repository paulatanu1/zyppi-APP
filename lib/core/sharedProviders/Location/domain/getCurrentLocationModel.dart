import 'package:freezed_annotation/freezed_annotation.dart';

part 'getCurrentLocationModel.freezed.dart';
part 'getCurrentLocationModel.g.dart';

@freezed
class CurrentLocationResponse with _$CurrentLocationResponse {
  const factory CurrentLocationResponse({
    @JsonKey(name: 'plus_code') PlusCode? plusCode,
    required List<Result> results,
  }) = _CurrentLocationResponse;

  factory CurrentLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$CurrentLocationResponseFromJson(json);
}

@freezed
class PlusCode with _$PlusCode {
  const factory PlusCode({
    @JsonKey(name: 'compound_code') String? compoundCode,
    @JsonKey(name: 'global_code') String? globalCode,
  }) = _PlusCode;

  factory PlusCode.fromJson(Map<String, dynamic> json) => _$PlusCodeFromJson(json);
}

@freezed
class Result with _$Result {
  const factory Result({
    @JsonKey(name: 'address_components') required List<AddressComponent>? addressComponents,
    @JsonKey(name: 'formatted_address') String? formattedAddress,
    Geometry? geometry,
    @JsonKey(name: 'navigation_points') List<NavigationPoint>? navigationPoints,
    @JsonKey(name: 'place_id') String? placeId,
    @JsonKey(name: 'plus_code') PlusCode? plusCode,
    required List<String> types,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}

@freezed
class AddressComponent with _$AddressComponent {
  const factory AddressComponent({
    @JsonKey(name: 'long_name') String? longName,
    @JsonKey(name: 'short_name') String? shortName,
    required List<String> types,
  }) = _AddressComponent;

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentFromJson(json);
}

@freezed
class Geometry with _$Geometry {
  const factory Geometry({
    Location? location,
    @JsonKey(name: 'location_type') String? locationType,
    Viewport? viewport,
    Bounds? bounds,
  }) = _Geometry;

  factory Geometry.fromJson(Map<String, dynamic> json) => _$GeometryFromJson(json);
}

@freezed
class Location with _$Location {
  const factory Location({
    required double? lat,
    required double? lng,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}

@freezed
class Viewport with _$Viewport {
  const factory Viewport({
    required Location? northeast,
    required Location? southwest,
  }) = _Viewport;

  factory Viewport.fromJson(Map<String, dynamic> json) => _$ViewportFromJson(json);
}

@freezed
class Bounds with _$Bounds {
  const factory Bounds({
    required Location? northeast,
    required Location? southwest,
  }) = _Bounds;

  factory Bounds.fromJson(Map<String, dynamic> json) => _$BoundsFromJson(json);
}

@freezed
class NavigationPoint with _$NavigationPoint {
  const factory NavigationPoint({
    Location? location,
  }) = _NavigationPoint;

  factory NavigationPoint.fromJson(Map<String, dynamic> json) =>
      _$NavigationPointFromJson(json);
}
