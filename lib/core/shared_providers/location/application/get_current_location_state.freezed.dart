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

 bool? get isDetecting; double? get latitude; double? get longitude; String? get address;
/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetCurrentLocationStateCopyWith<GetCurrentLocationState> get copyWith => _$GetCurrentLocationStateCopyWithImpl<GetCurrentLocationState>(this as GetCurrentLocationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GetCurrentLocationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetCurrentLocationState&&(identical(other.isDetecting, _this.isDetecting) || other.isDetecting == _this.isDetecting)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.address, _this.address) || other.address == _this.address));
}


@override
int get hashCode {
  final _this = this as GetCurrentLocationState;
  return Object.hash(runtimeType,_this.isDetecting,_this.latitude,_this.longitude,_this.address);
}

@override
String toString() {
  final _this = this as GetCurrentLocationState;
  return 'GetCurrentLocationState(isDetecting: ${_this.isDetecting}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, address: ${_this.address})';
}


}

/// @nodoc
abstract mixin class $GetCurrentLocationStateCopyWith<$Res>  {
  factory $GetCurrentLocationStateCopyWith(GetCurrentLocationState value, $Res Function(GetCurrentLocationState) _then) = _$GetCurrentLocationStateCopyWithImpl;
@useResult
$Res call({
 bool? isDetecting, double? latitude, double? longitude, String? address
});




}
/// @nodoc
class _$GetCurrentLocationStateCopyWithImpl<$Res>
    implements $GetCurrentLocationStateCopyWith<$Res> {
  _$GetCurrentLocationStateCopyWithImpl(this._self, this._then);

  final GetCurrentLocationState _self;
  final $Res Function(GetCurrentLocationState) _then;

/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isDetecting = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? address = freezed,}) {
  return _then(GetCurrentLocationState(
isDetecting: freezed == isDetecting ? _self.isDetecting : isDetecting // ignore: cast_nullable_to_non_nullable
as bool?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? isDetecting,  double? latitude,  double? longitude,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetCurrentLocationState() when $default != null:
return $default(_that.isDetecting,_that.latitude,_that.longitude,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? isDetecting,  double? latitude,  double? longitude,  String? address)  $default,) {final _that = this;
switch (_that) {
case _GetCurrentLocationState():
return $default(_that.isDetecting,_that.latitude,_that.longitude,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? isDetecting,  double? latitude,  double? longitude,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _GetCurrentLocationState() when $default != null:
return $default(_that.isDetecting,_that.latitude,_that.longitude,_that.address);case _:
  return null;

}
}

}

/// @nodoc


class _GetCurrentLocationState implements GetCurrentLocationState {
   _GetCurrentLocationState({required this.isDetecting, required this.latitude, required this.longitude, required this.address});
  

@override final  bool? isDetecting;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? address;

/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetCurrentLocationStateCopyWith<_GetCurrentLocationState> get copyWith => __$GetCurrentLocationStateCopyWithImpl<_GetCurrentLocationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCurrentLocationState&&(identical(other.isDetecting, isDetecting) || other.isDetecting == isDetecting)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isDetecting,latitude,longitude,address);
}

@override
String toString() {
    return 'GetCurrentLocationState(isDetecting: $isDetecting, latitude: $latitude, longitude: $longitude, address: $address)';
}


}

/// @nodoc
abstract mixin class _$GetCurrentLocationStateCopyWith<$Res> implements $GetCurrentLocationStateCopyWith<$Res> {
  factory _$GetCurrentLocationStateCopyWith(_GetCurrentLocationState value, $Res Function(_GetCurrentLocationState) _then) = __$GetCurrentLocationStateCopyWithImpl;
@override @useResult
$Res call({
 bool? isDetecting, double? latitude, double? longitude, String? address
});




}
/// @nodoc
class __$GetCurrentLocationStateCopyWithImpl<$Res>
    implements _$GetCurrentLocationStateCopyWith<$Res> {
  __$GetCurrentLocationStateCopyWithImpl(this._self, this._then);

  final _GetCurrentLocationState _self;
  final $Res Function(_GetCurrentLocationState) _then;

/// Create a copy of GetCurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isDetecting = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? address = freezed,}) {
  return _then(_GetCurrentLocationState(
isDetecting: freezed == isDetecting ? _self.isDetecting : isDetecting // ignore: cast_nullable_to_non_nullable
as bool?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
