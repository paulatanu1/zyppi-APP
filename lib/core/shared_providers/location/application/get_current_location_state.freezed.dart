// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_current_location_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetCurrentLocationState {

 bool get isDetecting; double get latitude; double get longitude; String get address; String get line1; String get area; String get city; String get state; String get postalCode; bool get checkingServiceability; ServiceArea? get serviceArea; String? get error;
/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetCurrentLocationStateCopyWith<GetCurrentLocationState> get copyWith => _$GetCurrentLocationStateCopyWithImpl<GetCurrentLocationState>(this as GetCurrentLocationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GetCurrentLocationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetCurrentLocationState&&(identical(other.isDetecting, _this.isDetecting) || other.isDetecting == _this.isDetecting)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.line1, _this.line1) || other.line1 == _this.line1)&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.postalCode, _this.postalCode) || other.postalCode == _this.postalCode)&&(identical(other.checkingServiceability, _this.checkingServiceability) || other.checkingServiceability == _this.checkingServiceability)&&(identical(other.serviceArea, _this.serviceArea) || other.serviceArea == _this.serviceArea)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as GetCurrentLocationState;
  return Object.hash(runtimeType,_this.isDetecting,_this.latitude,_this.longitude,_this.address,_this.line1,_this.area,_this.city,_this.state,_this.postalCode,_this.checkingServiceability,_this.serviceArea,_this.error);
}

@override
String toString() {
  final _this = this as GetCurrentLocationState;
  return 'GetCurrentLocationState(isDetecting: ${_this.isDetecting}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, address: ${_this.address}, line1: ${_this.line1}, area: ${_this.area}, city: ${_this.city}, state: ${_this.state}, postalCode: ${_this.postalCode}, checkingServiceability: ${_this.checkingServiceability}, serviceArea: ${_this.serviceArea}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $GetCurrentLocationStateCopyWith<$Res>  {
  factory $GetCurrentLocationStateCopyWith(GetCurrentLocationState value, $Res Function(GetCurrentLocationState) _then) = _$GetCurrentLocationStateCopyWithImpl;
@useResult
$Res call({
 bool isDetecting, double latitude, double longitude, String address, String line1, String area, String city, String state, String postalCode, bool checkingServiceability, ServiceArea? serviceArea, String? error
});


$ServiceAreaCopyWith<$Res>? get serviceArea;

}
/// @nodoc
class _$GetCurrentLocationStateCopyWithImpl<$Res>
    implements $GetCurrentLocationStateCopyWith<$Res> {
  _$GetCurrentLocationStateCopyWithImpl(this._self, this._then);

  final GetCurrentLocationState _self;
  final $Res Function(GetCurrentLocationState) _then;

/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isDetecting = null,Object? latitude = null,Object? longitude = null,Object? address = null,Object? line1 = null,Object? area = null,Object? city = null,Object? state = null,Object? postalCode = null,Object? checkingServiceability = null,Object? serviceArea = freezed,Object? error = freezed,}) {
  return _then(GetCurrentLocationState(
isDetecting: null == isDetecting ? _self.isDetecting : isDetecting // ignore: cast_nullable_to_non_nullable
as bool,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,line1: null == line1 ? _self.line1 : line1 // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,checkingServiceability: null == checkingServiceability ? _self.checkingServiceability : checkingServiceability // ignore: cast_nullable_to_non_nullable
as bool,serviceArea: freezed == serviceArea ? _self.serviceArea : serviceArea // ignore: cast_nullable_to_non_nullable
as ServiceArea?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceAreaCopyWith<$Res>? get serviceArea {
    if (_self.serviceArea == null) {
    return null;
  }

  return $ServiceAreaCopyWith<$Res>(_self.serviceArea!, (value) {
    return _then(_self.copyWith(serviceArea: value));
  });
}
}


/// Adds pattern-matching-related methods to [GetCurrentLocationState].
extension GetCurrentLocationStatePatterns on GetCurrentLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetCurrentLocationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetCurrentLocationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetCurrentLocationState value)  $default,){
final _that = this;
switch (_that) {
case _GetCurrentLocationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetCurrentLocationState value)?  $default,){
final _that = this;
switch (_that) {
case _GetCurrentLocationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isDetecting,  double latitude,  double longitude,  String address,  String line1,  String area,  String city,  String state,  String postalCode,  bool checkingServiceability,  ServiceArea? serviceArea,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetCurrentLocationState() when $default != null:
return $default(_that.isDetecting,_that.latitude,_that.longitude,_that.address,_that.line1,_that.area,_that.city,_that.state,_that.postalCode,_that.checkingServiceability,_that.serviceArea,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isDetecting,  double latitude,  double longitude,  String address,  String line1,  String area,  String city,  String state,  String postalCode,  bool checkingServiceability,  ServiceArea? serviceArea,  String? error)  $default,) {final _that = this;
switch (_that) {
case _GetCurrentLocationState():
return $default(_that.isDetecting,_that.latitude,_that.longitude,_that.address,_that.line1,_that.area,_that.city,_that.state,_that.postalCode,_that.checkingServiceability,_that.serviceArea,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isDetecting,  double latitude,  double longitude,  String address,  String line1,  String area,  String city,  String state,  String postalCode,  bool checkingServiceability,  ServiceArea? serviceArea,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _GetCurrentLocationState() when $default != null:
return $default(_that.isDetecting,_that.latitude,_that.longitude,_that.address,_that.line1,_that.area,_that.city,_that.state,_that.postalCode,_that.checkingServiceability,_that.serviceArea,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetCurrentLocationState implements GetCurrentLocationState {
   _GetCurrentLocationState({required this.isDetecting, required this.latitude, required this.longitude, required this.address, this.line1 = '', this.area = '', this.city = '', this.state = '', this.postalCode = '', this.checkingServiceability = false, this.serviceArea, this.error});
  

@override final  bool isDetecting;
@override final  double latitude;
@override final  double longitude;
@override final  String address;
@override@JsonKey() final  String line1;
@override@JsonKey() final  String area;
@override@JsonKey() final  String city;
@override@JsonKey() final  String state;
@override@JsonKey() final  String postalCode;
@override@JsonKey() final  bool checkingServiceability;
@override final  ServiceArea? serviceArea;
@override final  String? error;

/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetCurrentLocationStateCopyWith<_GetCurrentLocationState> get copyWith => __$GetCurrentLocationStateCopyWithImpl<_GetCurrentLocationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCurrentLocationState&&(identical(other.isDetecting, isDetecting) || other.isDetecting == isDetecting)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.line1, line1) || other.line1 == line1)&&(identical(other.area, area) || other.area == area)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.checkingServiceability, checkingServiceability) || other.checkingServiceability == checkingServiceability)&&(identical(other.serviceArea, serviceArea) || other.serviceArea == serviceArea)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isDetecting,latitude,longitude,address,line1,area,city,state,postalCode,checkingServiceability,serviceArea,error);
}

@override
String toString() {
    return 'GetCurrentLocationState(isDetecting: $isDetecting, latitude: $latitude, longitude: $longitude, address: $address, line1: $line1, area: $area, city: $city, state: $state, postalCode: $postalCode, checkingServiceability: $checkingServiceability, serviceArea: $serviceArea, error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetCurrentLocationStateCopyWith<$Res> implements $GetCurrentLocationStateCopyWith<$Res> {
  factory _$GetCurrentLocationStateCopyWith(_GetCurrentLocationState value, $Res Function(_GetCurrentLocationState) _then) = __$GetCurrentLocationStateCopyWithImpl;
@override @useResult
$Res call({
 bool isDetecting, double latitude, double longitude, String address, String line1, String area, String city, String state, String postalCode, bool checkingServiceability, ServiceArea? serviceArea, String? error
});


@override $ServiceAreaCopyWith<$Res>? get serviceArea;

}
/// @nodoc
class __$GetCurrentLocationStateCopyWithImpl<$Res>
    implements _$GetCurrentLocationStateCopyWith<$Res> {
  __$GetCurrentLocationStateCopyWithImpl(this._self, this._then);

  final _GetCurrentLocationState _self;
  final $Res Function(_GetCurrentLocationState) _then;

/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isDetecting = null,Object? latitude = null,Object? longitude = null,Object? address = null,Object? line1 = null,Object? area = null,Object? city = null,Object? state = null,Object? postalCode = null,Object? checkingServiceability = null,Object? serviceArea = freezed,Object? error = freezed,}) {
  return _then(_GetCurrentLocationState(
isDetecting: null == isDetecting ? _self.isDetecting : isDetecting // ignore: cast_nullable_to_non_nullable
as bool,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,line1: null == line1 ? _self.line1 : line1 // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,checkingServiceability: null == checkingServiceability ? _self.checkingServiceability : checkingServiceability // ignore: cast_nullable_to_non_nullable
as bool,serviceArea: freezed == serviceArea ? _self.serviceArea : serviceArea // ignore: cast_nullable_to_non_nullable
as ServiceArea?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceAreaCopyWith<$Res>? get serviceArea {
    if (_self.serviceArea == null) {
    return null;
  }

  return $ServiceAreaCopyWith<$Res>(_self.serviceArea!, (value) {
    return _then(_self.copyWith(serviceArea: value));
  });
}
}

// dart format on
