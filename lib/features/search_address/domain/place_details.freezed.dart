// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaceDetails {

 List<dynamic>? get htmlAttributions; PlaceResult? get result; String? get status;
/// Create a copy of PlaceDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceDetailsCopyWith<PlaceDetails> get copyWith => _$PlaceDetailsCopyWithImpl<PlaceDetails>(this as PlaceDetails, _$identity);

  /// Serializes this PlaceDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceDetails&&const DeepCollectionEquality().equals(other.htmlAttributions, _this.htmlAttributions)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceDetails;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.htmlAttributions),_this.result,_this.status);
}

@override
String toString() {
  final _this = this as PlaceDetails;
  return 'PlaceDetails(htmlAttributions: ${_this.htmlAttributions}, result: ${_this.result}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $PlaceDetailsCopyWith<$Res>  {
  factory $PlaceDetailsCopyWith(PlaceDetails value, $Res Function(PlaceDetails) _then) = _$PlaceDetailsCopyWithImpl;
@useResult
$Res call({
 List<dynamic>? htmlAttributions, PlaceResult? result, String? status
});


$PlaceResultCopyWith<$Res>? get result;

}
/// @nodoc
class _$PlaceDetailsCopyWithImpl<$Res>
    implements $PlaceDetailsCopyWith<$Res> {
  _$PlaceDetailsCopyWithImpl(this._self, this._then);

  final PlaceDetails _self;
  final $Res Function(PlaceDetails) _then;

/// Create a copy of PlaceDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? htmlAttributions = freezed,Object? result = freezed,Object? status = freezed,}) {
  return _then(PlaceDetails(
htmlAttributions: freezed == htmlAttributions ? _self.htmlAttributions : htmlAttributions // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PlaceResult?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PlaceDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $PlaceResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaceDetails].
extension PlaceDetailsPatterns on PlaceDetails {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceDetails() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceDetails value)  $default,){
final _that = this;
switch (_that) {
case _PlaceDetails():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceDetails value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceDetails() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<dynamic>? htmlAttributions,  PlaceResult? result,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceDetails() when $default != null:
return $default(_that.htmlAttributions,_that.result,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<dynamic>? htmlAttributions,  PlaceResult? result,  String? status)  $default,) {final _that = this;
switch (_that) {
case _PlaceDetails():
return $default(_that.htmlAttributions,_that.result,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<dynamic>? htmlAttributions,  PlaceResult? result,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _PlaceDetails() when $default != null:
return $default(_that.htmlAttributions,_that.result,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceDetails implements PlaceDetails {
   _PlaceDetails({ List<dynamic>? htmlAttributions, this.result, this.status}): _htmlAttributions = htmlAttributions;
  factory _PlaceDetails.fromJson(Map<String, dynamic> json) => _$PlaceDetailsFromJson(json);

 final  List<dynamic>? _htmlAttributions;
@override List<dynamic>? get htmlAttributions {
  final value = _htmlAttributions;
  if (value == null) return null;
  if (_htmlAttributions is EqualUnmodifiableListView) return _htmlAttributions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  PlaceResult? result;
@override final  String? status;

/// Create a copy of PlaceDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceDetailsCopyWith<_PlaceDetails> get copyWith => __$PlaceDetailsCopyWithImpl<_PlaceDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceDetails&&const DeepCollectionEquality().equals(other.htmlAttributions, _htmlAttributions)&&(identical(other.result, result) || other.result == result)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_htmlAttributions),result,status);
}

@override
String toString() {
    return 'PlaceDetails(htmlAttributions: $htmlAttributions, result: $result, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PlaceDetailsCopyWith<$Res> implements $PlaceDetailsCopyWith<$Res> {
  factory _$PlaceDetailsCopyWith(_PlaceDetails value, $Res Function(_PlaceDetails) _then) = __$PlaceDetailsCopyWithImpl;
@override @useResult
$Res call({
 List<dynamic>? htmlAttributions, PlaceResult? result, String? status
});


@override $PlaceResultCopyWith<$Res>? get result;

}
/// @nodoc
class __$PlaceDetailsCopyWithImpl<$Res>
    implements _$PlaceDetailsCopyWith<$Res> {
  __$PlaceDetailsCopyWithImpl(this._self, this._then);

  final _PlaceDetails _self;
  final $Res Function(_PlaceDetails) _then;

/// Create a copy of PlaceDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? htmlAttributions = freezed,Object? result = freezed,Object? status = freezed,}) {
  return _then(_PlaceDetails(
htmlAttributions: freezed == htmlAttributions ? _self._htmlAttributions : htmlAttributions // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PlaceResult?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PlaceDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $PlaceResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// @nodoc
mixin _$PlaceResult {

 List<AddressComponent>? get addressComponents; String? get adrAddress; String? get formattedAddress; Geometry? get geometry; String? get icon; String? get iconBackgroundColor; String? get iconMaskBaseUri; String? get name; String? get placeId; String? get reference; List<String>? get types; String? get url; int? get utcOffset; String? get vicinity;
/// Create a copy of PlaceResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceResultCopyWith<PlaceResult> get copyWith => _$PlaceResultCopyWithImpl<PlaceResult>(this as PlaceResult, _$identity);

  /// Serializes this PlaceResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceResult&&const DeepCollectionEquality().equals(other.addressComponents, _this.addressComponents)&&(identical(other.adrAddress, _this.adrAddress) || other.adrAddress == _this.adrAddress)&&(identical(other.formattedAddress, _this.formattedAddress) || other.formattedAddress == _this.formattedAddress)&&(identical(other.geometry, _this.geometry) || other.geometry == _this.geometry)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.iconBackgroundColor, _this.iconBackgroundColor) || other.iconBackgroundColor == _this.iconBackgroundColor)&&(identical(other.iconMaskBaseUri, _this.iconMaskBaseUri) || other.iconMaskBaseUri == _this.iconMaskBaseUri)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&const DeepCollectionEquality().equals(other.types, _this.types)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.utcOffset, _this.utcOffset) || other.utcOffset == _this.utcOffset)&&(identical(other.vicinity, _this.vicinity) || other.vicinity == _this.vicinity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceResult;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.addressComponents),_this.adrAddress,_this.formattedAddress,_this.geometry,_this.icon,_this.iconBackgroundColor,_this.iconMaskBaseUri,_this.name,_this.placeId,_this.reference,const DeepCollectionEquality().hash(_this.types),_this.url,_this.utcOffset,_this.vicinity);
}

@override
String toString() {
  final _this = this as PlaceResult;
  return 'PlaceResult(addressComponents: ${_this.addressComponents}, adrAddress: ${_this.adrAddress}, formattedAddress: ${_this.formattedAddress}, geometry: ${_this.geometry}, icon: ${_this.icon}, iconBackgroundColor: ${_this.iconBackgroundColor}, iconMaskBaseUri: ${_this.iconMaskBaseUri}, name: ${_this.name}, placeId: ${_this.placeId}, reference: ${_this.reference}, types: ${_this.types}, url: ${_this.url}, utcOffset: ${_this.utcOffset}, vicinity: ${_this.vicinity})';
}


}

/// @nodoc
abstract mixin class $PlaceResultCopyWith<$Res>  {
  factory $PlaceResultCopyWith(PlaceResult value, $Res Function(PlaceResult) _then) = _$PlaceResultCopyWithImpl;
@useResult
$Res call({
 List<AddressComponent>? addressComponents, String? adrAddress, String? formattedAddress, Geometry? geometry, String? icon, String? iconBackgroundColor, String? iconMaskBaseUri, String? name, String? placeId, String? reference, List<String>? types, String? url, int? utcOffset, String? vicinity
});


$GeometryCopyWith<$Res>? get geometry;

}
/// @nodoc
class _$PlaceResultCopyWithImpl<$Res>
    implements $PlaceResultCopyWith<$Res> {
  _$PlaceResultCopyWithImpl(this._self, this._then);

  final PlaceResult _self;
  final $Res Function(PlaceResult) _then;

/// Create a copy of PlaceResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addressComponents = freezed,Object? adrAddress = freezed,Object? formattedAddress = freezed,Object? geometry = freezed,Object? icon = freezed,Object? iconBackgroundColor = freezed,Object? iconMaskBaseUri = freezed,Object? name = freezed,Object? placeId = freezed,Object? reference = freezed,Object? types = freezed,Object? url = freezed,Object? utcOffset = freezed,Object? vicinity = freezed,}) {
  return _then(PlaceResult(
addressComponents: freezed == addressComponents ? _self.addressComponents : addressComponents // ignore: cast_nullable_to_non_nullable
as List<AddressComponent>?,adrAddress: freezed == adrAddress ? _self.adrAddress : adrAddress // ignore: cast_nullable_to_non_nullable
as String?,formattedAddress: freezed == formattedAddress ? _self.formattedAddress : formattedAddress // ignore: cast_nullable_to_non_nullable
as String?,geometry: freezed == geometry ? _self.geometry : geometry // ignore: cast_nullable_to_non_nullable
as Geometry?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconBackgroundColor: freezed == iconBackgroundColor ? _self.iconBackgroundColor : iconBackgroundColor // ignore: cast_nullable_to_non_nullable
as String?,iconMaskBaseUri: freezed == iconMaskBaseUri ? _self.iconMaskBaseUri : iconMaskBaseUri // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,types: freezed == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,utcOffset: freezed == utcOffset ? _self.utcOffset : utcOffset // ignore: cast_nullable_to_non_nullable
as int?,vicinity: freezed == vicinity ? _self.vicinity : vicinity // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PlaceResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeometryCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
    return null;
  }

  return $GeometryCopyWith<$Res>(_self.geometry!, (value) {
    return _then(_self.copyWith(geometry: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaceResult].
extension PlaceResultPatterns on PlaceResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceResult value)  $default,){
final _that = this;
switch (_that) {
case _PlaceResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceResult value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AddressComponent>? addressComponents,  String? adrAddress,  String? formattedAddress,  Geometry? geometry,  String? icon,  String? iconBackgroundColor,  String? iconMaskBaseUri,  String? name,  String? placeId,  String? reference,  List<String>? types,  String? url,  int? utcOffset,  String? vicinity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceResult() when $default != null:
return $default(_that.addressComponents,_that.adrAddress,_that.formattedAddress,_that.geometry,_that.icon,_that.iconBackgroundColor,_that.iconMaskBaseUri,_that.name,_that.placeId,_that.reference,_that.types,_that.url,_that.utcOffset,_that.vicinity);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AddressComponent>? addressComponents,  String? adrAddress,  String? formattedAddress,  Geometry? geometry,  String? icon,  String? iconBackgroundColor,  String? iconMaskBaseUri,  String? name,  String? placeId,  String? reference,  List<String>? types,  String? url,  int? utcOffset,  String? vicinity)  $default,) {final _that = this;
switch (_that) {
case _PlaceResult():
return $default(_that.addressComponents,_that.adrAddress,_that.formattedAddress,_that.geometry,_that.icon,_that.iconBackgroundColor,_that.iconMaskBaseUri,_that.name,_that.placeId,_that.reference,_that.types,_that.url,_that.utcOffset,_that.vicinity);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AddressComponent>? addressComponents,  String? adrAddress,  String? formattedAddress,  Geometry? geometry,  String? icon,  String? iconBackgroundColor,  String? iconMaskBaseUri,  String? name,  String? placeId,  String? reference,  List<String>? types,  String? url,  int? utcOffset,  String? vicinity)?  $default,) {final _that = this;
switch (_that) {
case _PlaceResult() when $default != null:
return $default(_that.addressComponents,_that.adrAddress,_that.formattedAddress,_that.geometry,_that.icon,_that.iconBackgroundColor,_that.iconMaskBaseUri,_that.name,_that.placeId,_that.reference,_that.types,_that.url,_that.utcOffset,_that.vicinity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceResult implements PlaceResult {
   _PlaceResult({ List<AddressComponent>? addressComponents, this.adrAddress, this.formattedAddress, this.geometry, this.icon, this.iconBackgroundColor, this.iconMaskBaseUri, this.name, this.placeId, this.reference,  List<String>? types, this.url, this.utcOffset, this.vicinity}): _addressComponents = addressComponents,_types = types;
  factory _PlaceResult.fromJson(Map<String, dynamic> json) => _$PlaceResultFromJson(json);

 final  List<AddressComponent>? _addressComponents;
@override List<AddressComponent>? get addressComponents {
  final value = _addressComponents;
  if (value == null) return null;
  if (_addressComponents is EqualUnmodifiableListView) return _addressComponents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? adrAddress;
@override final  String? formattedAddress;
@override final  Geometry? geometry;
@override final  String? icon;
@override final  String? iconBackgroundColor;
@override final  String? iconMaskBaseUri;
@override final  String? name;
@override final  String? placeId;
@override final  String? reference;
 final  List<String>? _types;
@override List<String>? get types {
  final value = _types;
  if (value == null) return null;
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? url;
@override final  int? utcOffset;
@override final  String? vicinity;

/// Create a copy of PlaceResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceResultCopyWith<_PlaceResult> get copyWith => __$PlaceResultCopyWithImpl<_PlaceResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceResult&&const DeepCollectionEquality().equals(other.addressComponents, _addressComponents)&&(identical(other.adrAddress, adrAddress) || other.adrAddress == adrAddress)&&(identical(other.formattedAddress, formattedAddress) || other.formattedAddress == formattedAddress)&&(identical(other.geometry, geometry) || other.geometry == geometry)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconBackgroundColor, iconBackgroundColor) || other.iconBackgroundColor == iconBackgroundColor)&&(identical(other.iconMaskBaseUri, iconMaskBaseUri) || other.iconMaskBaseUri == iconMaskBaseUri)&&(identical(other.name, name) || other.name == name)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.reference, reference) || other.reference == reference)&&const DeepCollectionEquality().equals(other.types, _types)&&(identical(other.url, url) || other.url == url)&&(identical(other.utcOffset, utcOffset) || other.utcOffset == utcOffset)&&(identical(other.vicinity, vicinity) || other.vicinity == vicinity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_addressComponents),adrAddress,formattedAddress,geometry,icon,iconBackgroundColor,iconMaskBaseUri,name,placeId,reference,const DeepCollectionEquality().hash(_types),url,utcOffset,vicinity);
}

@override
String toString() {
    return 'PlaceResult(addressComponents: $addressComponents, adrAddress: $adrAddress, formattedAddress: $formattedAddress, geometry: $geometry, icon: $icon, iconBackgroundColor: $iconBackgroundColor, iconMaskBaseUri: $iconMaskBaseUri, name: $name, placeId: $placeId, reference: $reference, types: $types, url: $url, utcOffset: $utcOffset, vicinity: $vicinity)';
}


}

/// @nodoc
abstract mixin class _$PlaceResultCopyWith<$Res> implements $PlaceResultCopyWith<$Res> {
  factory _$PlaceResultCopyWith(_PlaceResult value, $Res Function(_PlaceResult) _then) = __$PlaceResultCopyWithImpl;
@override @useResult
$Res call({
 List<AddressComponent>? addressComponents, String? adrAddress, String? formattedAddress, Geometry? geometry, String? icon, String? iconBackgroundColor, String? iconMaskBaseUri, String? name, String? placeId, String? reference, List<String>? types, String? url, int? utcOffset, String? vicinity
});


@override $GeometryCopyWith<$Res>? get geometry;

}
/// @nodoc
class __$PlaceResultCopyWithImpl<$Res>
    implements _$PlaceResultCopyWith<$Res> {
  __$PlaceResultCopyWithImpl(this._self, this._then);

  final _PlaceResult _self;
  final $Res Function(_PlaceResult) _then;

/// Create a copy of PlaceResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addressComponents = freezed,Object? adrAddress = freezed,Object? formattedAddress = freezed,Object? geometry = freezed,Object? icon = freezed,Object? iconBackgroundColor = freezed,Object? iconMaskBaseUri = freezed,Object? name = freezed,Object? placeId = freezed,Object? reference = freezed,Object? types = freezed,Object? url = freezed,Object? utcOffset = freezed,Object? vicinity = freezed,}) {
  return _then(_PlaceResult(
addressComponents: freezed == addressComponents ? _self._addressComponents : addressComponents // ignore: cast_nullable_to_non_nullable
as List<AddressComponent>?,adrAddress: freezed == adrAddress ? _self.adrAddress : adrAddress // ignore: cast_nullable_to_non_nullable
as String?,formattedAddress: freezed == formattedAddress ? _self.formattedAddress : formattedAddress // ignore: cast_nullable_to_non_nullable
as String?,geometry: freezed == geometry ? _self.geometry : geometry // ignore: cast_nullable_to_non_nullable
as Geometry?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconBackgroundColor: freezed == iconBackgroundColor ? _self.iconBackgroundColor : iconBackgroundColor // ignore: cast_nullable_to_non_nullable
as String?,iconMaskBaseUri: freezed == iconMaskBaseUri ? _self.iconMaskBaseUri : iconMaskBaseUri // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,types: freezed == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,utcOffset: freezed == utcOffset ? _self.utcOffset : utcOffset // ignore: cast_nullable_to_non_nullable
as int?,vicinity: freezed == vicinity ? _self.vicinity : vicinity // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PlaceResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeometryCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
    return null;
  }

  return $GeometryCopyWith<$Res>(_self.geometry!, (value) {
    return _then(_self.copyWith(geometry: value));
  });
}
}


/// @nodoc
mixin _$AddressComponent {

 String? get longName; String? get shortName; List<String>? get types;
/// Create a copy of AddressComponent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressComponentCopyWith<AddressComponent> get copyWith => _$AddressComponentCopyWithImpl<AddressComponent>(this as AddressComponent, _$identity);

  /// Serializes this AddressComponent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddressComponent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressComponent&&(identical(other.longName, _this.longName) || other.longName == _this.longName)&&(identical(other.shortName, _this.shortName) || other.shortName == _this.shortName)&&const DeepCollectionEquality().equals(other.types, _this.types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddressComponent;
  return Object.hash(runtimeType,_this.longName,_this.shortName,const DeepCollectionEquality().hash(_this.types));
}

@override
String toString() {
  final _this = this as AddressComponent;
  return 'AddressComponent(longName: ${_this.longName}, shortName: ${_this.shortName}, types: ${_this.types})';
}


}

/// @nodoc
abstract mixin class $AddressComponentCopyWith<$Res>  {
  factory $AddressComponentCopyWith(AddressComponent value, $Res Function(AddressComponent) _then) = _$AddressComponentCopyWithImpl;
@useResult
$Res call({
 String? longName, String? shortName, List<String>? types
});




}
/// @nodoc
class _$AddressComponentCopyWithImpl<$Res>
    implements $AddressComponentCopyWith<$Res> {
  _$AddressComponentCopyWithImpl(this._self, this._then);

  final AddressComponent _self;
  final $Res Function(AddressComponent) _then;

/// Create a copy of AddressComponent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? longName = freezed,Object? shortName = freezed,Object? types = freezed,}) {
  return _then(AddressComponent(
longName: freezed == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,types: freezed == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressComponent].
extension AddressComponentPatterns on AddressComponent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressComponent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressComponent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressComponent value)  $default,){
final _that = this;
switch (_that) {
case _AddressComponent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressComponent value)?  $default,){
final _that = this;
switch (_that) {
case _AddressComponent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? longName,  String? shortName,  List<String>? types)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressComponent() when $default != null:
return $default(_that.longName,_that.shortName,_that.types);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? longName,  String? shortName,  List<String>? types)  $default,) {final _that = this;
switch (_that) {
case _AddressComponent():
return $default(_that.longName,_that.shortName,_that.types);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? longName,  String? shortName,  List<String>? types)?  $default,) {final _that = this;
switch (_that) {
case _AddressComponent() when $default != null:
return $default(_that.longName,_that.shortName,_that.types);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressComponent implements AddressComponent {
   _AddressComponent({this.longName, this.shortName,  List<String>? types}): _types = types;
  factory _AddressComponent.fromJson(Map<String, dynamic> json) => _$AddressComponentFromJson(json);

@override final  String? longName;
@override final  String? shortName;
 final  List<String>? _types;
@override List<String>? get types {
  final value = _types;
  if (value == null) return null;
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of AddressComponent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressComponentCopyWith<_AddressComponent> get copyWith => __$AddressComponentCopyWithImpl<_AddressComponent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressComponentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressComponent&&(identical(other.longName, longName) || other.longName == longName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&const DeepCollectionEquality().equals(other.types, _types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,longName,shortName,const DeepCollectionEquality().hash(_types));
}

@override
String toString() {
    return 'AddressComponent(longName: $longName, shortName: $shortName, types: $types)';
}


}

/// @nodoc
abstract mixin class _$AddressComponentCopyWith<$Res> implements $AddressComponentCopyWith<$Res> {
  factory _$AddressComponentCopyWith(_AddressComponent value, $Res Function(_AddressComponent) _then) = __$AddressComponentCopyWithImpl;
@override @useResult
$Res call({
 String? longName, String? shortName, List<String>? types
});




}
/// @nodoc
class __$AddressComponentCopyWithImpl<$Res>
    implements _$AddressComponentCopyWith<$Res> {
  __$AddressComponentCopyWithImpl(this._self, this._then);

  final _AddressComponent _self;
  final $Res Function(_AddressComponent) _then;

/// Create a copy of AddressComponent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? longName = freezed,Object? shortName = freezed,Object? types = freezed,}) {
  return _then(_AddressComponent(
longName: freezed == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,types: freezed == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$Geometry {

 Location? get location; Viewport? get viewport;
/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeometryCopyWith<Geometry> get copyWith => _$GeometryCopyWithImpl<Geometry>(this as Geometry, _$identity);

  /// Serializes this Geometry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Geometry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Geometry&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.viewport, _this.viewport) || other.viewport == _this.viewport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Geometry;
  return Object.hash(runtimeType,_this.location,_this.viewport);
}

@override
String toString() {
  final _this = this as Geometry;
  return 'Geometry(location: ${_this.location}, viewport: ${_this.viewport})';
}


}

/// @nodoc
abstract mixin class $GeometryCopyWith<$Res>  {
  factory $GeometryCopyWith(Geometry value, $Res Function(Geometry) _then) = _$GeometryCopyWithImpl;
@useResult
$Res call({
 Location? location, Viewport? viewport
});


$LocationCopyWith<$Res>? get location;$ViewportCopyWith<$Res>? get viewport;

}
/// @nodoc
class _$GeometryCopyWithImpl<$Res>
    implements $GeometryCopyWith<$Res> {
  _$GeometryCopyWithImpl(this._self, this._then);

  final Geometry _self;
  final $Res Function(Geometry) _then;

/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? viewport = freezed,}) {
  return _then(Geometry(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,viewport: freezed == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as Viewport?,
  ));
}
/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewportCopyWith<$Res>? get viewport {
    if (_self.viewport == null) {
    return null;
  }

  return $ViewportCopyWith<$Res>(_self.viewport!, (value) {
    return _then(_self.copyWith(viewport: value));
  });
}
}


/// Adds pattern-matching-related methods to [Geometry].
extension GeometryPatterns on Geometry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Geometry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Geometry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Geometry value)  $default,){
final _that = this;
switch (_that) {
case _Geometry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Geometry value)?  $default,){
final _that = this;
switch (_that) {
case _Geometry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Location? location,  Viewport? viewport)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Geometry() when $default != null:
return $default(_that.location,_that.viewport);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Location? location,  Viewport? viewport)  $default,) {final _that = this;
switch (_that) {
case _Geometry():
return $default(_that.location,_that.viewport);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Location? location,  Viewport? viewport)?  $default,) {final _that = this;
switch (_that) {
case _Geometry() when $default != null:
return $default(_that.location,_that.viewport);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Geometry implements Geometry {
   _Geometry({this.location, this.viewport});
  factory _Geometry.fromJson(Map<String, dynamic> json) => _$GeometryFromJson(json);

@override final  Location? location;
@override final  Viewport? viewport;

/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeometryCopyWith<_Geometry> get copyWith => __$GeometryCopyWithImpl<_Geometry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeometryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Geometry&&(identical(other.location, location) || other.location == location)&&(identical(other.viewport, viewport) || other.viewport == viewport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,location,viewport);
}

@override
String toString() {
    return 'Geometry(location: $location, viewport: $viewport)';
}


}

/// @nodoc
abstract mixin class _$GeometryCopyWith<$Res> implements $GeometryCopyWith<$Res> {
  factory _$GeometryCopyWith(_Geometry value, $Res Function(_Geometry) _then) = __$GeometryCopyWithImpl;
@override @useResult
$Res call({
 Location? location, Viewport? viewport
});


@override $LocationCopyWith<$Res>? get location;@override $ViewportCopyWith<$Res>? get viewport;

}
/// @nodoc
class __$GeometryCopyWithImpl<$Res>
    implements _$GeometryCopyWith<$Res> {
  __$GeometryCopyWithImpl(this._self, this._then);

  final _Geometry _self;
  final $Res Function(_Geometry) _then;

/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? viewport = freezed,}) {
  return _then(_Geometry(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,viewport: freezed == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as Viewport?,
  ));
}

/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewportCopyWith<$Res>? get viewport {
    if (_self.viewport == null) {
    return null;
  }

  return $ViewportCopyWith<$Res>(_self.viewport!, (value) {
    return _then(_self.copyWith(viewport: value));
  });
}
}


/// @nodoc
mixin _$Location {

 double? get lat; double? get lng;
/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCopyWith<Location> get copyWith => _$LocationCopyWithImpl<Location>(this as Location, _$identity);

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Location;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Location&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Location;
  return Object.hash(runtimeType,_this.lat,_this.lng);
}

@override
String toString() {
  final _this = this as Location;
  return 'Location(lat: ${_this.lat}, lng: ${_this.lng})';
}


}

/// @nodoc
abstract mixin class $LocationCopyWith<$Res>  {
  factory $LocationCopyWith(Location value, $Res Function(Location) _then) = _$LocationCopyWithImpl;
@useResult
$Res call({
 double? lat, double? lng
});




}
/// @nodoc
class _$LocationCopyWithImpl<$Res>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._self, this._then);

  final Location _self;
  final $Res Function(Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = freezed,Object? lng = freezed,}) {
  return _then(Location(
lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Location].
extension LocationPatterns on Location {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Location value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Location value)  $default,){
final _that = this;
switch (_that) {
case _Location():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Location value)?  $default,){
final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? lat,  double? lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.lat,_that.lng);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? lat,  double? lng)  $default,) {final _that = this;
switch (_that) {
case _Location():
return $default(_that.lat,_that.lng);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? lat,  double? lng)?  $default,) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Location implements Location {
   _Location({this.lat, this.lng});
  factory _Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

@override final  double? lat;
@override final  double? lng;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationCopyWith<_Location> get copyWith => __$LocationCopyWithImpl<_Location>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Location&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lat,lng);
}

@override
String toString() {
    return 'Location(lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$LocationCopyWith<$Res> implements $LocationCopyWith<$Res> {
  factory _$LocationCopyWith(_Location value, $Res Function(_Location) _then) = __$LocationCopyWithImpl;
@override @useResult
$Res call({
 double? lat, double? lng
});




}
/// @nodoc
class __$LocationCopyWithImpl<$Res>
    implements _$LocationCopyWith<$Res> {
  __$LocationCopyWithImpl(this._self, this._then);

  final _Location _self;
  final $Res Function(_Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_Location(
lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$Viewport {

 Location? get northeast; Location? get southwest;
/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewportCopyWith<Viewport> get copyWith => _$ViewportCopyWithImpl<Viewport>(this as Viewport, _$identity);

  /// Serializes this Viewport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Viewport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Viewport&&(identical(other.northeast, _this.northeast) || other.northeast == _this.northeast)&&(identical(other.southwest, _this.southwest) || other.southwest == _this.southwest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Viewport;
  return Object.hash(runtimeType,_this.northeast,_this.southwest);
}

@override
String toString() {
  final _this = this as Viewport;
  return 'Viewport(northeast: ${_this.northeast}, southwest: ${_this.southwest})';
}


}

/// @nodoc
abstract mixin class $ViewportCopyWith<$Res>  {
  factory $ViewportCopyWith(Viewport value, $Res Function(Viewport) _then) = _$ViewportCopyWithImpl;
@useResult
$Res call({
 Location? northeast, Location? southwest
});


$LocationCopyWith<$Res>? get northeast;$LocationCopyWith<$Res>? get southwest;

}
/// @nodoc
class _$ViewportCopyWithImpl<$Res>
    implements $ViewportCopyWith<$Res> {
  _$ViewportCopyWithImpl(this._self, this._then);

  final Viewport _self;
  final $Res Function(Viewport) _then;

/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? northeast = freezed,Object? southwest = freezed,}) {
  return _then(Viewport(
northeast: freezed == northeast ? _self.northeast : northeast // ignore: cast_nullable_to_non_nullable
as Location?,southwest: freezed == southwest ? _self.southwest : southwest // ignore: cast_nullable_to_non_nullable
as Location?,
  ));
}
/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get northeast {
    if (_self.northeast == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.northeast!, (value) {
    return _then(_self.copyWith(northeast: value));
  });
}/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get southwest {
    if (_self.southwest == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.southwest!, (value) {
    return _then(_self.copyWith(southwest: value));
  });
}
}


/// Adds pattern-matching-related methods to [Viewport].
extension ViewportPatterns on Viewport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Viewport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Viewport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Viewport value)  $default,){
final _that = this;
switch (_that) {
case _Viewport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Viewport value)?  $default,){
final _that = this;
switch (_that) {
case _Viewport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Location? northeast,  Location? southwest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Viewport() when $default != null:
return $default(_that.northeast,_that.southwest);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Location? northeast,  Location? southwest)  $default,) {final _that = this;
switch (_that) {
case _Viewport():
return $default(_that.northeast,_that.southwest);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Location? northeast,  Location? southwest)?  $default,) {final _that = this;
switch (_that) {
case _Viewport() when $default != null:
return $default(_that.northeast,_that.southwest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Viewport implements Viewport {
   _Viewport({this.northeast, this.southwest});
  factory _Viewport.fromJson(Map<String, dynamic> json) => _$ViewportFromJson(json);

@override final  Location? northeast;
@override final  Location? southwest;

/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewportCopyWith<_Viewport> get copyWith => __$ViewportCopyWithImpl<_Viewport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ViewportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Viewport&&(identical(other.northeast, northeast) || other.northeast == northeast)&&(identical(other.southwest, southwest) || other.southwest == southwest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,northeast,southwest);
}

@override
String toString() {
    return 'Viewport(northeast: $northeast, southwest: $southwest)';
}


}

/// @nodoc
abstract mixin class _$ViewportCopyWith<$Res> implements $ViewportCopyWith<$Res> {
  factory _$ViewportCopyWith(_Viewport value, $Res Function(_Viewport) _then) = __$ViewportCopyWithImpl;
@override @useResult
$Res call({
 Location? northeast, Location? southwest
});


@override $LocationCopyWith<$Res>? get northeast;@override $LocationCopyWith<$Res>? get southwest;

}
/// @nodoc
class __$ViewportCopyWithImpl<$Res>
    implements _$ViewportCopyWith<$Res> {
  __$ViewportCopyWithImpl(this._self, this._then);

  final _Viewport _self;
  final $Res Function(_Viewport) _then;

/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? northeast = freezed,Object? southwest = freezed,}) {
  return _then(_Viewport(
northeast: freezed == northeast ? _self.northeast : northeast // ignore: cast_nullable_to_non_nullable
as Location?,southwest: freezed == southwest ? _self.southwest : southwest // ignore: cast_nullable_to_non_nullable
as Location?,
  ));
}

/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get northeast {
    if (_self.northeast == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.northeast!, (value) {
    return _then(_self.copyWith(northeast: value));
  });
}/// Create a copy of Viewport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get southwest {
    if (_self.southwest == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.southwest!, (value) {
    return _then(_self.copyWith(southwest: value));
  });
}
}

// dart format on
