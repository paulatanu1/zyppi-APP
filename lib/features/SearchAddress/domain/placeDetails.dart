import 'package:freezed_annotation/freezed_annotation.dart';

part 'placeDetails.freezed.dart';
part 'placeDetails.g.dart';

@freezed
class PlaceDetails with _$PlaceDetails {
  factory PlaceDetails({
    List<dynamic>? htmlAttributions,
    PlaceResult? result,
    String? status,
  }) = _PlaceDetails;

  factory PlaceDetails.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailsFromJson(json);
}

@freezed
class PlaceResult with _$PlaceResult {
  factory PlaceResult({
    List<AddressComponent>? addressComponents,
    String? adrAddress,
    String? formattedAddress,
    Geometry? geometry,
    String? icon,
    String? iconBackgroundColor,
    String? iconMaskBaseUri,
    String? name,
    String? placeId,
    String? reference,
    List<String>? types,
    String? url,
    int? utcOffset,
    String? vicinity,
  }) = _PlaceResult;

  factory PlaceResult.fromJson(Map<String, dynamic> json) =>
      _$PlaceResultFromJson(json);
}

@freezed
class AddressComponent with _$AddressComponent {
  factory AddressComponent({
    String? longName,
    String? shortName,
    List<String>? types,
  }) = _AddressComponent;

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentFromJson(json);
}

@freezed
class Geometry with _$Geometry {
  factory Geometry({
    Location? location,
    Viewport? viewport,
  }) = _Geometry;

  factory Geometry.fromJson(Map<String, dynamic> json) => _$GeometryFromJson(json);
}

@freezed
class Location with _$Location {
  factory Location({
    double? lat,
    double? lng,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}

@freezed
class Viewport with _$Viewport {
  factory Viewport({
    Location? northeast,
    Location? southwest,
  }) = _Viewport;

  factory Viewport.fromJson(Map<String, dynamic> json) => _$ViewportFromJson(json);
}