// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_current_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentLocationResponse {

@JsonKey(name: 'plus_code') PlusCode? get plusCode; List<Result> get results;
/// Create a copy of CurrentLocationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentLocationResponseCopyWith<CurrentLocationResponse> get copyWith => _$CurrentLocationResponseCopyWithImpl<CurrentLocationResponse>(this as CurrentLocationResponse, _$identity);

  /// Serializes this CurrentLocationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrentLocationResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentLocationResponse&&(identical(other.plusCode, _this.plusCode) || other.plusCode == _this.plusCode)&&const DeepCollectionEquality().equals(other.results, _this.results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrentLocationResponse;
  return Object.hash(runtimeType,_this.plusCode,const DeepCollectionEquality().hash(_this.results));
}

@override
String toString() {
  final _this = this as CurrentLocationResponse;
  return 'CurrentLocationResponse(plusCode: ${_this.plusCode}, results: ${_this.results})';
}


}

/// @nodoc
abstract mixin class $CurrentLocationResponseCopyWith<$Res>  {
  factory $CurrentLocationResponseCopyWith(CurrentLocationResponse value, $Res Function(CurrentLocationResponse) _then) = _$CurrentLocationResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'plus_code') PlusCode? plusCode, List<Result> results
});


$PlusCodeCopyWith<$Res>? get plusCode;

}
/// @nodoc
class _$CurrentLocationResponseCopyWithImpl<$Res>
    implements $CurrentLocationResponseCopyWith<$Res> {
  _$CurrentLocationResponseCopyWithImpl(this._self, this._then);

  final CurrentLocationResponse _self;
  final $Res Function(CurrentLocationResponse) _then;

/// Create a copy of CurrentLocationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plusCode = freezed,Object? results = null,}) {
  return _then(CurrentLocationResponse(
plusCode: freezed == plusCode ? _self.plusCode : plusCode // ignore: cast_nullable_to_non_nullable
as PlusCode?,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<Result>,
  ));
}
/// Create a copy of CurrentLocationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlusCodeCopyWith<$Res>? get plusCode {
    if (_self.plusCode == null) {
    return null;
  }

  return $PlusCodeCopyWith<$Res>(_self.plusCode!, (value) {
    return _then(_self.copyWith(plusCode: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurrentLocationResponse].
extension CurrentLocationResponsePatterns on CurrentLocationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentLocationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentLocationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentLocationResponse value)  $default,){
final _that = this;
switch (_that) {
case _CurrentLocationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentLocationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentLocationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'plus_code')  PlusCode? plusCode,  List<Result> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentLocationResponse() when $default != null:
return $default(_that.plusCode,_that.results);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'plus_code')  PlusCode? plusCode,  List<Result> results)  $default,) {final _that = this;
switch (_that) {
case _CurrentLocationResponse():
return $default(_that.plusCode,_that.results);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'plus_code')  PlusCode? plusCode,  List<Result> results)?  $default,) {final _that = this;
switch (_that) {
case _CurrentLocationResponse() when $default != null:
return $default(_that.plusCode,_that.results);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrentLocationResponse implements CurrentLocationResponse {
  const _CurrentLocationResponse({@JsonKey(name: 'plus_code') this.plusCode, required  List<Result> results}): _results = results;
  factory _CurrentLocationResponse.fromJson(Map<String, dynamic> json) => _$CurrentLocationResponseFromJson(json);

@override@JsonKey(name: 'plus_code') final  PlusCode? plusCode;
 final  List<Result> _results;
@override List<Result> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of CurrentLocationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentLocationResponseCopyWith<_CurrentLocationResponse> get copyWith => __$CurrentLocationResponseCopyWithImpl<_CurrentLocationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentLocationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentLocationResponse&&(identical(other.plusCode, plusCode) || other.plusCode == plusCode)&&const DeepCollectionEquality().equals(other.results, _results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,plusCode,const DeepCollectionEquality().hash(_results));
}

@override
String toString() {
    return 'CurrentLocationResponse(plusCode: $plusCode, results: $results)';
}


}

/// @nodoc
abstract mixin class _$CurrentLocationResponseCopyWith<$Res> implements $CurrentLocationResponseCopyWith<$Res> {
  factory _$CurrentLocationResponseCopyWith(_CurrentLocationResponse value, $Res Function(_CurrentLocationResponse) _then) = __$CurrentLocationResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'plus_code') PlusCode? plusCode, List<Result> results
});


@override $PlusCodeCopyWith<$Res>? get plusCode;

}
/// @nodoc
class __$CurrentLocationResponseCopyWithImpl<$Res>
    implements _$CurrentLocationResponseCopyWith<$Res> {
  __$CurrentLocationResponseCopyWithImpl(this._self, this._then);

  final _CurrentLocationResponse _self;
  final $Res Function(_CurrentLocationResponse) _then;

/// Create a copy of CurrentLocationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plusCode = freezed,Object? results = null,}) {
  return _then(_CurrentLocationResponse(
plusCode: freezed == plusCode ? _self.plusCode : plusCode // ignore: cast_nullable_to_non_nullable
as PlusCode?,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<Result>,
  ));
}

/// Create a copy of CurrentLocationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlusCodeCopyWith<$Res>? get plusCode {
    if (_self.plusCode == null) {
    return null;
  }

  return $PlusCodeCopyWith<$Res>(_self.plusCode!, (value) {
    return _then(_self.copyWith(plusCode: value));
  });
}
}


/// @nodoc
mixin _$PlusCode {

@JsonKey(name: 'compound_code') String? get compoundCode;@JsonKey(name: 'global_code') String? get globalCode;
/// Create a copy of PlusCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlusCodeCopyWith<PlusCode> get copyWith => _$PlusCodeCopyWithImpl<PlusCode>(this as PlusCode, _$identity);

  /// Serializes this PlusCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlusCode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlusCode&&(identical(other.compoundCode, _this.compoundCode) || other.compoundCode == _this.compoundCode)&&(identical(other.globalCode, _this.globalCode) || other.globalCode == _this.globalCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlusCode;
  return Object.hash(runtimeType,_this.compoundCode,_this.globalCode);
}

@override
String toString() {
  final _this = this as PlusCode;
  return 'PlusCode(compoundCode: ${_this.compoundCode}, globalCode: ${_this.globalCode})';
}


}

/// @nodoc
abstract mixin class $PlusCodeCopyWith<$Res>  {
  factory $PlusCodeCopyWith(PlusCode value, $Res Function(PlusCode) _then) = _$PlusCodeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'compound_code') String? compoundCode,@JsonKey(name: 'global_code') String? globalCode
});




}
/// @nodoc
class _$PlusCodeCopyWithImpl<$Res>
    implements $PlusCodeCopyWith<$Res> {
  _$PlusCodeCopyWithImpl(this._self, this._then);

  final PlusCode _self;
  final $Res Function(PlusCode) _then;

/// Create a copy of PlusCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? compoundCode = freezed,Object? globalCode = freezed,}) {
  return _then(PlusCode(
compoundCode: freezed == compoundCode ? _self.compoundCode : compoundCode // ignore: cast_nullable_to_non_nullable
as String?,globalCode: freezed == globalCode ? _self.globalCode : globalCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlusCode].
extension PlusCodePatterns on PlusCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlusCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlusCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlusCode value)  $default,){
final _that = this;
switch (_that) {
case _PlusCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlusCode value)?  $default,){
final _that = this;
switch (_that) {
case _PlusCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'compound_code')  String? compoundCode, @JsonKey(name: 'global_code')  String? globalCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlusCode() when $default != null:
return $default(_that.compoundCode,_that.globalCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'compound_code')  String? compoundCode, @JsonKey(name: 'global_code')  String? globalCode)  $default,) {final _that = this;
switch (_that) {
case _PlusCode():
return $default(_that.compoundCode,_that.globalCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'compound_code')  String? compoundCode, @JsonKey(name: 'global_code')  String? globalCode)?  $default,) {final _that = this;
switch (_that) {
case _PlusCode() when $default != null:
return $default(_that.compoundCode,_that.globalCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlusCode implements PlusCode {
  const _PlusCode({@JsonKey(name: 'compound_code') this.compoundCode, @JsonKey(name: 'global_code') this.globalCode});
  factory _PlusCode.fromJson(Map<String, dynamic> json) => _$PlusCodeFromJson(json);

@override@JsonKey(name: 'compound_code') final  String? compoundCode;
@override@JsonKey(name: 'global_code') final  String? globalCode;

/// Create a copy of PlusCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlusCodeCopyWith<_PlusCode> get copyWith => __$PlusCodeCopyWithImpl<_PlusCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlusCodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlusCode&&(identical(other.compoundCode, compoundCode) || other.compoundCode == compoundCode)&&(identical(other.globalCode, globalCode) || other.globalCode == globalCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,compoundCode,globalCode);
}

@override
String toString() {
    return 'PlusCode(compoundCode: $compoundCode, globalCode: $globalCode)';
}


}

/// @nodoc
abstract mixin class _$PlusCodeCopyWith<$Res> implements $PlusCodeCopyWith<$Res> {
  factory _$PlusCodeCopyWith(_PlusCode value, $Res Function(_PlusCode) _then) = __$PlusCodeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'compound_code') String? compoundCode,@JsonKey(name: 'global_code') String? globalCode
});




}
/// @nodoc
class __$PlusCodeCopyWithImpl<$Res>
    implements _$PlusCodeCopyWith<$Res> {
  __$PlusCodeCopyWithImpl(this._self, this._then);

  final _PlusCode _self;
  final $Res Function(_PlusCode) _then;

/// Create a copy of PlusCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? compoundCode = freezed,Object? globalCode = freezed,}) {
  return _then(_PlusCode(
compoundCode: freezed == compoundCode ? _self.compoundCode : compoundCode // ignore: cast_nullable_to_non_nullable
as String?,globalCode: freezed == globalCode ? _self.globalCode : globalCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Result {

@JsonKey(name: 'address_components') List<AddressComponent>? get addressComponents;@JsonKey(name: 'formatted_address') String? get formattedAddress; Geometry? get geometry;@JsonKey(name: 'navigation_points') List<NavigationPoint>? get navigationPoints;@JsonKey(name: 'place_id') String? get placeId;@JsonKey(name: 'plus_code') PlusCode? get plusCode; List<String> get types;
/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultCopyWith<Result> get copyWith => _$ResultCopyWithImpl<Result>(this as Result, _$identity);

  /// Serializes this Result to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Result;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result&&const DeepCollectionEquality().equals(other.addressComponents, _this.addressComponents)&&(identical(other.formattedAddress, _this.formattedAddress) || other.formattedAddress == _this.formattedAddress)&&(identical(other.geometry, _this.geometry) || other.geometry == _this.geometry)&&const DeepCollectionEquality().equals(other.navigationPoints, _this.navigationPoints)&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.plusCode, _this.plusCode) || other.plusCode == _this.plusCode)&&const DeepCollectionEquality().equals(other.types, _this.types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Result;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.addressComponents),_this.formattedAddress,_this.geometry,const DeepCollectionEquality().hash(_this.navigationPoints),_this.placeId,_this.plusCode,const DeepCollectionEquality().hash(_this.types));
}

@override
String toString() {
  final _this = this as Result;
  return 'Result(addressComponents: ${_this.addressComponents}, formattedAddress: ${_this.formattedAddress}, geometry: ${_this.geometry}, navigationPoints: ${_this.navigationPoints}, placeId: ${_this.placeId}, plusCode: ${_this.plusCode}, types: ${_this.types})';
}


}

/// @nodoc
abstract mixin class $ResultCopyWith<$Res>  {
  factory $ResultCopyWith(Result value, $Res Function(Result) _then) = _$ResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'address_components') List<AddressComponent>? addressComponents,@JsonKey(name: 'formatted_address') String? formattedAddress, Geometry? geometry,@JsonKey(name: 'navigation_points') List<NavigationPoint>? navigationPoints,@JsonKey(name: 'place_id') String? placeId,@JsonKey(name: 'plus_code') PlusCode? plusCode, List<String> types
});


$GeometryCopyWith<$Res>? get geometry;$PlusCodeCopyWith<$Res>? get plusCode;

}
/// @nodoc
class _$ResultCopyWithImpl<$Res>
    implements $ResultCopyWith<$Res> {
  _$ResultCopyWithImpl(this._self, this._then);

  final Result _self;
  final $Res Function(Result) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addressComponents = freezed,Object? formattedAddress = freezed,Object? geometry = freezed,Object? navigationPoints = freezed,Object? placeId = freezed,Object? plusCode = freezed,Object? types = null,}) {
  return _then(Result(
addressComponents: freezed == addressComponents ? _self.addressComponents : addressComponents // ignore: cast_nullable_to_non_nullable
as List<AddressComponent>?,formattedAddress: freezed == formattedAddress ? _self.formattedAddress : formattedAddress // ignore: cast_nullable_to_non_nullable
as String?,geometry: freezed == geometry ? _self.geometry : geometry // ignore: cast_nullable_to_non_nullable
as Geometry?,navigationPoints: freezed == navigationPoints ? _self.navigationPoints : navigationPoints // ignore: cast_nullable_to_non_nullable
as List<NavigationPoint>?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,plusCode: freezed == plusCode ? _self.plusCode : plusCode // ignore: cast_nullable_to_non_nullable
as PlusCode?,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Result
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
}/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlusCodeCopyWith<$Res>? get plusCode {
    if (_self.plusCode == null) {
    return null;
  }

  return $PlusCodeCopyWith<$Res>(_self.plusCode!, (value) {
    return _then(_self.copyWith(plusCode: value));
  });
}
}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns on Result {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Result value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Result value)  $default,){
final _that = this;
switch (_that) {
case _Result():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Result value)?  $default,){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'address_components')  List<AddressComponent>? addressComponents, @JsonKey(name: 'formatted_address')  String? formattedAddress,  Geometry? geometry, @JsonKey(name: 'navigation_points')  List<NavigationPoint>? navigationPoints, @JsonKey(name: 'place_id')  String? placeId, @JsonKey(name: 'plus_code')  PlusCode? plusCode,  List<String> types)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.addressComponents,_that.formattedAddress,_that.geometry,_that.navigationPoints,_that.placeId,_that.plusCode,_that.types);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'address_components')  List<AddressComponent>? addressComponents, @JsonKey(name: 'formatted_address')  String? formattedAddress,  Geometry? geometry, @JsonKey(name: 'navigation_points')  List<NavigationPoint>? navigationPoints, @JsonKey(name: 'place_id')  String? placeId, @JsonKey(name: 'plus_code')  PlusCode? plusCode,  List<String> types)  $default,) {final _that = this;
switch (_that) {
case _Result():
return $default(_that.addressComponents,_that.formattedAddress,_that.geometry,_that.navigationPoints,_that.placeId,_that.plusCode,_that.types);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'address_components')  List<AddressComponent>? addressComponents, @JsonKey(name: 'formatted_address')  String? formattedAddress,  Geometry? geometry, @JsonKey(name: 'navigation_points')  List<NavigationPoint>? navigationPoints, @JsonKey(name: 'place_id')  String? placeId, @JsonKey(name: 'plus_code')  PlusCode? plusCode,  List<String> types)?  $default,) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.addressComponents,_that.formattedAddress,_that.geometry,_that.navigationPoints,_that.placeId,_that.plusCode,_that.types);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Result implements Result {
  const _Result({@JsonKey(name: 'address_components') required  List<AddressComponent>? addressComponents, @JsonKey(name: 'formatted_address') this.formattedAddress, this.geometry, @JsonKey(name: 'navigation_points')  List<NavigationPoint>? navigationPoints, @JsonKey(name: 'place_id') this.placeId, @JsonKey(name: 'plus_code') this.plusCode, required  List<String> types}): _addressComponents = addressComponents,_navigationPoints = navigationPoints,_types = types;
  factory _Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);

 final  List<AddressComponent>? _addressComponents;
@override@JsonKey(name: 'address_components') List<AddressComponent>? get addressComponents {
  final value = _addressComponents;
  if (value == null) return null;
  if (_addressComponents is EqualUnmodifiableListView) return _addressComponents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'formatted_address') final  String? formattedAddress;
@override final  Geometry? geometry;
 final  List<NavigationPoint>? _navigationPoints;
@override@JsonKey(name: 'navigation_points') List<NavigationPoint>? get navigationPoints {
  final value = _navigationPoints;
  if (value == null) return null;
  if (_navigationPoints is EqualUnmodifiableListView) return _navigationPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'place_id') final  String? placeId;
@override@JsonKey(name: 'plus_code') final  PlusCode? plusCode;
 final  List<String> _types;
@override List<String> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}


/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultCopyWith<_Result> get copyWith => __$ResultCopyWithImpl<_Result>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Result&&const DeepCollectionEquality().equals(other.addressComponents, _addressComponents)&&(identical(other.formattedAddress, formattedAddress) || other.formattedAddress == formattedAddress)&&(identical(other.geometry, geometry) || other.geometry == geometry)&&const DeepCollectionEquality().equals(other.navigationPoints, _navigationPoints)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.plusCode, plusCode) || other.plusCode == plusCode)&&const DeepCollectionEquality().equals(other.types, _types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_addressComponents),formattedAddress,geometry,const DeepCollectionEquality().hash(_navigationPoints),placeId,plusCode,const DeepCollectionEquality().hash(_types));
}

@override
String toString() {
    return 'Result(addressComponents: $addressComponents, formattedAddress: $formattedAddress, geometry: $geometry, navigationPoints: $navigationPoints, placeId: $placeId, plusCode: $plusCode, types: $types)';
}


}

/// @nodoc
abstract mixin class _$ResultCopyWith<$Res> implements $ResultCopyWith<$Res> {
  factory _$ResultCopyWith(_Result value, $Res Function(_Result) _then) = __$ResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'address_components') List<AddressComponent>? addressComponents,@JsonKey(name: 'formatted_address') String? formattedAddress, Geometry? geometry,@JsonKey(name: 'navigation_points') List<NavigationPoint>? navigationPoints,@JsonKey(name: 'place_id') String? placeId,@JsonKey(name: 'plus_code') PlusCode? plusCode, List<String> types
});


@override $GeometryCopyWith<$Res>? get geometry;@override $PlusCodeCopyWith<$Res>? get plusCode;

}
/// @nodoc
class __$ResultCopyWithImpl<$Res>
    implements _$ResultCopyWith<$Res> {
  __$ResultCopyWithImpl(this._self, this._then);

  final _Result _self;
  final $Res Function(_Result) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addressComponents = freezed,Object? formattedAddress = freezed,Object? geometry = freezed,Object? navigationPoints = freezed,Object? placeId = freezed,Object? plusCode = freezed,Object? types = null,}) {
  return _then(_Result(
addressComponents: freezed == addressComponents ? _self._addressComponents : addressComponents // ignore: cast_nullable_to_non_nullable
as List<AddressComponent>?,formattedAddress: freezed == formattedAddress ? _self.formattedAddress : formattedAddress // ignore: cast_nullable_to_non_nullable
as String?,geometry: freezed == geometry ? _self.geometry : geometry // ignore: cast_nullable_to_non_nullable
as Geometry?,navigationPoints: freezed == navigationPoints ? _self._navigationPoints : navigationPoints // ignore: cast_nullable_to_non_nullable
as List<NavigationPoint>?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,plusCode: freezed == plusCode ? _self.plusCode : plusCode // ignore: cast_nullable_to_non_nullable
as PlusCode?,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Result
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
}/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlusCodeCopyWith<$Res>? get plusCode {
    if (_self.plusCode == null) {
    return null;
  }

  return $PlusCodeCopyWith<$Res>(_self.plusCode!, (value) {
    return _then(_self.copyWith(plusCode: value));
  });
}
}


/// @nodoc
mixin _$AddressComponent {

@JsonKey(name: 'long_name') String? get longName;@JsonKey(name: 'short_name') String? get shortName; List<String> get types;
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
@JsonKey(name: 'long_name') String? longName,@JsonKey(name: 'short_name') String? shortName, List<String> types
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
@pragma('vm:prefer-inline') @override $Res call({Object? longName = freezed,Object? shortName = freezed,Object? types = null,}) {
  return _then(AddressComponent(
longName: freezed == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'long_name')  String? longName, @JsonKey(name: 'short_name')  String? shortName,  List<String> types)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'long_name')  String? longName, @JsonKey(name: 'short_name')  String? shortName,  List<String> types)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'long_name')  String? longName, @JsonKey(name: 'short_name')  String? shortName,  List<String> types)?  $default,) {final _that = this;
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
  const _AddressComponent({@JsonKey(name: 'long_name') this.longName, @JsonKey(name: 'short_name') this.shortName, required  List<String> types}): _types = types;
  factory _AddressComponent.fromJson(Map<String, dynamic> json) => _$AddressComponentFromJson(json);

@override@JsonKey(name: 'long_name') final  String? longName;
@override@JsonKey(name: 'short_name') final  String? shortName;
 final  List<String> _types;
@override List<String> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
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
@JsonKey(name: 'long_name') String? longName,@JsonKey(name: 'short_name') String? shortName, List<String> types
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
@override @pragma('vm:prefer-inline') $Res call({Object? longName = freezed,Object? shortName = freezed,Object? types = null,}) {
  return _then(_AddressComponent(
longName: freezed == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Geometry {

 Location? get location;@JsonKey(name: 'location_type') String? get locationType; Viewport? get viewport; Bounds? get bounds;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Geometry&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.locationType, _this.locationType) || other.locationType == _this.locationType)&&(identical(other.viewport, _this.viewport) || other.viewport == _this.viewport)&&(identical(other.bounds, _this.bounds) || other.bounds == _this.bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Geometry;
  return Object.hash(runtimeType,_this.location,_this.locationType,_this.viewport,_this.bounds);
}

@override
String toString() {
  final _this = this as Geometry;
  return 'Geometry(location: ${_this.location}, locationType: ${_this.locationType}, viewport: ${_this.viewport}, bounds: ${_this.bounds})';
}


}

/// @nodoc
abstract mixin class $GeometryCopyWith<$Res>  {
  factory $GeometryCopyWith(Geometry value, $Res Function(Geometry) _then) = _$GeometryCopyWithImpl;
@useResult
$Res call({
 Location? location,@JsonKey(name: 'location_type') String? locationType, Viewport? viewport, Bounds? bounds
});


$LocationCopyWith<$Res>? get location;$ViewportCopyWith<$Res>? get viewport;$BoundsCopyWith<$Res>? get bounds;

}
/// @nodoc
class _$GeometryCopyWithImpl<$Res>
    implements $GeometryCopyWith<$Res> {
  _$GeometryCopyWithImpl(this._self, this._then);

  final Geometry _self;
  final $Res Function(Geometry) _then;

/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? locationType = freezed,Object? viewport = freezed,Object? bounds = freezed,}) {
  return _then(Geometry(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,locationType: freezed == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as String?,viewport: freezed == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as Viewport?,bounds: freezed == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as Bounds?,
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
}/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoundsCopyWith<$Res>? get bounds {
    if (_self.bounds == null) {
    return null;
  }

  return $BoundsCopyWith<$Res>(_self.bounds!, (value) {
    return _then(_self.copyWith(bounds: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Location? location, @JsonKey(name: 'location_type')  String? locationType,  Viewport? viewport,  Bounds? bounds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Geometry() when $default != null:
return $default(_that.location,_that.locationType,_that.viewport,_that.bounds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Location? location, @JsonKey(name: 'location_type')  String? locationType,  Viewport? viewport,  Bounds? bounds)  $default,) {final _that = this;
switch (_that) {
case _Geometry():
return $default(_that.location,_that.locationType,_that.viewport,_that.bounds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Location? location, @JsonKey(name: 'location_type')  String? locationType,  Viewport? viewport,  Bounds? bounds)?  $default,) {final _that = this;
switch (_that) {
case _Geometry() when $default != null:
return $default(_that.location,_that.locationType,_that.viewport,_that.bounds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Geometry implements Geometry {
  const _Geometry({this.location, @JsonKey(name: 'location_type') this.locationType, this.viewport, this.bounds});
  factory _Geometry.fromJson(Map<String, dynamic> json) => _$GeometryFromJson(json);

@override final  Location? location;
@override@JsonKey(name: 'location_type') final  String? locationType;
@override final  Viewport? viewport;
@override final  Bounds? bounds;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Geometry&&(identical(other.location, location) || other.location == location)&&(identical(other.locationType, locationType) || other.locationType == locationType)&&(identical(other.viewport, viewport) || other.viewport == viewport)&&(identical(other.bounds, bounds) || other.bounds == bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,location,locationType,viewport,bounds);
}

@override
String toString() {
    return 'Geometry(location: $location, locationType: $locationType, viewport: $viewport, bounds: $bounds)';
}


}

/// @nodoc
abstract mixin class _$GeometryCopyWith<$Res> implements $GeometryCopyWith<$Res> {
  factory _$GeometryCopyWith(_Geometry value, $Res Function(_Geometry) _then) = __$GeometryCopyWithImpl;
@override @useResult
$Res call({
 Location? location,@JsonKey(name: 'location_type') String? locationType, Viewport? viewport, Bounds? bounds
});


@override $LocationCopyWith<$Res>? get location;@override $ViewportCopyWith<$Res>? get viewport;@override $BoundsCopyWith<$Res>? get bounds;

}
/// @nodoc
class __$GeometryCopyWithImpl<$Res>
    implements _$GeometryCopyWith<$Res> {
  __$GeometryCopyWithImpl(this._self, this._then);

  final _Geometry _self;
  final $Res Function(_Geometry) _then;

/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? locationType = freezed,Object? viewport = freezed,Object? bounds = freezed,}) {
  return _then(_Geometry(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,locationType: freezed == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as String?,viewport: freezed == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as Viewport?,bounds: freezed == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as Bounds?,
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
}/// Create a copy of Geometry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoundsCopyWith<$Res>? get bounds {
    if (_self.bounds == null) {
    return null;
  }

  return $BoundsCopyWith<$Res>(_self.bounds!, (value) {
    return _then(_self.copyWith(bounds: value));
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
  const _Location({required this.lat, required this.lng});
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
  const _Viewport({required this.northeast, required this.southwest});
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


/// @nodoc
mixin _$Bounds {

 Location? get northeast; Location? get southwest;
/// Create a copy of Bounds
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoundsCopyWith<Bounds> get copyWith => _$BoundsCopyWithImpl<Bounds>(this as Bounds, _$identity);

  /// Serializes this Bounds to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Bounds;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bounds&&(identical(other.northeast, _this.northeast) || other.northeast == _this.northeast)&&(identical(other.southwest, _this.southwest) || other.southwest == _this.southwest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Bounds;
  return Object.hash(runtimeType,_this.northeast,_this.southwest);
}

@override
String toString() {
  final _this = this as Bounds;
  return 'Bounds(northeast: ${_this.northeast}, southwest: ${_this.southwest})';
}


}

/// @nodoc
abstract mixin class $BoundsCopyWith<$Res>  {
  factory $BoundsCopyWith(Bounds value, $Res Function(Bounds) _then) = _$BoundsCopyWithImpl;
@useResult
$Res call({
 Location? northeast, Location? southwest
});


$LocationCopyWith<$Res>? get northeast;$LocationCopyWith<$Res>? get southwest;

}
/// @nodoc
class _$BoundsCopyWithImpl<$Res>
    implements $BoundsCopyWith<$Res> {
  _$BoundsCopyWithImpl(this._self, this._then);

  final Bounds _self;
  final $Res Function(Bounds) _then;

/// Create a copy of Bounds
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? northeast = freezed,Object? southwest = freezed,}) {
  return _then(Bounds(
northeast: freezed == northeast ? _self.northeast : northeast // ignore: cast_nullable_to_non_nullable
as Location?,southwest: freezed == southwest ? _self.southwest : southwest // ignore: cast_nullable_to_non_nullable
as Location?,
  ));
}
/// Create a copy of Bounds
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
}/// Create a copy of Bounds
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


/// Adds pattern-matching-related methods to [Bounds].
extension BoundsPatterns on Bounds {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bounds value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bounds() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bounds value)  $default,){
final _that = this;
switch (_that) {
case _Bounds():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bounds value)?  $default,){
final _that = this;
switch (_that) {
case _Bounds() when $default != null:
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
case _Bounds() when $default != null:
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
case _Bounds():
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
case _Bounds() when $default != null:
return $default(_that.northeast,_that.southwest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bounds implements Bounds {
  const _Bounds({required this.northeast, required this.southwest});
  factory _Bounds.fromJson(Map<String, dynamic> json) => _$BoundsFromJson(json);

@override final  Location? northeast;
@override final  Location? southwest;

/// Create a copy of Bounds
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoundsCopyWith<_Bounds> get copyWith => __$BoundsCopyWithImpl<_Bounds>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoundsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bounds&&(identical(other.northeast, northeast) || other.northeast == northeast)&&(identical(other.southwest, southwest) || other.southwest == southwest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,northeast,southwest);
}

@override
String toString() {
    return 'Bounds(northeast: $northeast, southwest: $southwest)';
}


}

/// @nodoc
abstract mixin class _$BoundsCopyWith<$Res> implements $BoundsCopyWith<$Res> {
  factory _$BoundsCopyWith(_Bounds value, $Res Function(_Bounds) _then) = __$BoundsCopyWithImpl;
@override @useResult
$Res call({
 Location? northeast, Location? southwest
});


@override $LocationCopyWith<$Res>? get northeast;@override $LocationCopyWith<$Res>? get southwest;

}
/// @nodoc
class __$BoundsCopyWithImpl<$Res>
    implements _$BoundsCopyWith<$Res> {
  __$BoundsCopyWithImpl(this._self, this._then);

  final _Bounds _self;
  final $Res Function(_Bounds) _then;

/// Create a copy of Bounds
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? northeast = freezed,Object? southwest = freezed,}) {
  return _then(_Bounds(
northeast: freezed == northeast ? _self.northeast : northeast // ignore: cast_nullable_to_non_nullable
as Location?,southwest: freezed == southwest ? _self.southwest : southwest // ignore: cast_nullable_to_non_nullable
as Location?,
  ));
}

/// Create a copy of Bounds
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
}/// Create a copy of Bounds
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


/// @nodoc
mixin _$NavigationPoint {

 Location? get location;
/// Create a copy of NavigationPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationPointCopyWith<NavigationPoint> get copyWith => _$NavigationPointCopyWithImpl<NavigationPoint>(this as NavigationPoint, _$identity);

  /// Serializes this NavigationPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NavigationPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationPoint&&(identical(other.location, _this.location) || other.location == _this.location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NavigationPoint;
  return Object.hash(runtimeType,_this.location);
}

@override
String toString() {
  final _this = this as NavigationPoint;
  return 'NavigationPoint(location: ${_this.location})';
}


}

/// @nodoc
abstract mixin class $NavigationPointCopyWith<$Res>  {
  factory $NavigationPointCopyWith(NavigationPoint value, $Res Function(NavigationPoint) _then) = _$NavigationPointCopyWithImpl;
@useResult
$Res call({
 Location? location
});


$LocationCopyWith<$Res>? get location;

}
/// @nodoc
class _$NavigationPointCopyWithImpl<$Res>
    implements $NavigationPointCopyWith<$Res> {
  _$NavigationPointCopyWithImpl(this._self, this._then);

  final NavigationPoint _self;
  final $Res Function(NavigationPoint) _then;

/// Create a copy of NavigationPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,}) {
  return _then(NavigationPoint(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,
  ));
}
/// Create a copy of NavigationPoint
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
}
}


/// Adds pattern-matching-related methods to [NavigationPoint].
extension NavigationPointPatterns on NavigationPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationPoint value)  $default,){
final _that = this;
switch (_that) {
case _NavigationPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationPoint value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Location? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationPoint() when $default != null:
return $default(_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Location? location)  $default,) {final _that = this;
switch (_that) {
case _NavigationPoint():
return $default(_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Location? location)?  $default,) {final _that = this;
switch (_that) {
case _NavigationPoint() when $default != null:
return $default(_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NavigationPoint implements NavigationPoint {
  const _NavigationPoint({this.location});
  factory _NavigationPoint.fromJson(Map<String, dynamic> json) => _$NavigationPointFromJson(json);

@override final  Location? location;

/// Create a copy of NavigationPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationPointCopyWith<_NavigationPoint> get copyWith => __$NavigationPointCopyWithImpl<_NavigationPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NavigationPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationPoint&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,location);
}

@override
String toString() {
    return 'NavigationPoint(location: $location)';
}


}

/// @nodoc
abstract mixin class _$NavigationPointCopyWith<$Res> implements $NavigationPointCopyWith<$Res> {
  factory _$NavigationPointCopyWith(_NavigationPoint value, $Res Function(_NavigationPoint) _then) = __$NavigationPointCopyWithImpl;
@override @useResult
$Res call({
 Location? location
});


@override $LocationCopyWith<$Res>? get location;

}
/// @nodoc
class __$NavigationPointCopyWithImpl<$Res>
    implements _$NavigationPointCopyWith<$Res> {
  __$NavigationPointCopyWithImpl(this._self, this._then);

  final _NavigationPoint _self;
  final $Res Function(_NavigationPoint) _then;

/// Create a copy of NavigationPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,}) {
  return _then(_NavigationPoint(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,
  ));
}

/// Create a copy of NavigationPoint
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
}
}

// dart format on
