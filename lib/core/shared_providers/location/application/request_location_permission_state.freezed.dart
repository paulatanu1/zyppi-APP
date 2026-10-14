// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_location_permission_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestLocationPermissionState {

 LocationPermission? get locationPermission;
/// Create a copy of RequestLocationPermissionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestLocationPermissionStateCopyWith<RequestLocationPermissionState> get copyWith => _$RequestLocationPermissionStateCopyWithImpl<RequestLocationPermissionState>(this as RequestLocationPermissionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RequestLocationPermissionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestLocationPermissionState&&(identical(other.locationPermission, _this.locationPermission) || other.locationPermission == _this.locationPermission));
}


@override
int get hashCode {
  final _this = this as RequestLocationPermissionState;
  return Object.hash(runtimeType,_this.locationPermission);
}

@override
String toString() {
  final _this = this as RequestLocationPermissionState;
  return 'RequestLocationPermissionState(locationPermission: ${_this.locationPermission})';
}


}

/// @nodoc
abstract mixin class $RequestLocationPermissionStateCopyWith<$Res>  {
  factory $RequestLocationPermissionStateCopyWith(RequestLocationPermissionState value, $Res Function(RequestLocationPermissionState) _then) = _$RequestLocationPermissionStateCopyWithImpl;
@useResult
$Res call({
 LocationPermission? locationPermission
});




}
/// @nodoc
class _$RequestLocationPermissionStateCopyWithImpl<$Res>
    implements $RequestLocationPermissionStateCopyWith<$Res> {
  _$RequestLocationPermissionStateCopyWithImpl(this._self, this._then);

  final RequestLocationPermissionState _self;
  final $Res Function(RequestLocationPermissionState) _then;

/// Create a copy of RequestLocationPermissionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationPermission = freezed,}) {
  return _then(RequestLocationPermissionState(
locationPermission: freezed == locationPermission ? _self.locationPermission : locationPermission // ignore: cast_nullable_to_non_nullable
as LocationPermission?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestLocationPermissionState].
extension RequestLocationPermissionStatePatterns on RequestLocationPermissionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestLocationPermissionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestLocationPermissionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestLocationPermissionState value)  $default,){
final _that = this;
switch (_that) {
case _RequestLocationPermissionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestLocationPermissionState value)?  $default,){
final _that = this;
switch (_that) {
case _RequestLocationPermissionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationPermission? locationPermission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestLocationPermissionState() when $default != null:
return $default(_that.locationPermission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationPermission? locationPermission)  $default,) {final _that = this;
switch (_that) {
case _RequestLocationPermissionState():
return $default(_that.locationPermission);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationPermission? locationPermission)?  $default,) {final _that = this;
switch (_that) {
case _RequestLocationPermissionState() when $default != null:
return $default(_that.locationPermission);case _:
  return null;

}
}

}

/// @nodoc


class _RequestLocationPermissionState implements RequestLocationPermissionState {
   _RequestLocationPermissionState({this.locationPermission});
  

@override final  LocationPermission? locationPermission;

/// Create a copy of RequestLocationPermissionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestLocationPermissionStateCopyWith<_RequestLocationPermissionState> get copyWith => __$RequestLocationPermissionStateCopyWithImpl<_RequestLocationPermissionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestLocationPermissionState&&(identical(other.locationPermission, locationPermission) || other.locationPermission == locationPermission));
}


@override
int get hashCode {
    return Object.hash(runtimeType,locationPermission);
}

@override
String toString() {
    return 'RequestLocationPermissionState(locationPermission: $locationPermission)';
}


}

/// @nodoc
abstract mixin class _$RequestLocationPermissionStateCopyWith<$Res> implements $RequestLocationPermissionStateCopyWith<$Res> {
  factory _$RequestLocationPermissionStateCopyWith(_RequestLocationPermissionState value, $Res Function(_RequestLocationPermissionState) _then) = __$RequestLocationPermissionStateCopyWithImpl;
@override @useResult
$Res call({
 LocationPermission? locationPermission
});




}
/// @nodoc
class __$RequestLocationPermissionStateCopyWithImpl<$Res>
    implements _$RequestLocationPermissionStateCopyWith<$Res> {
  __$RequestLocationPermissionStateCopyWithImpl(this._self, this._then);

  final _RequestLocationPermissionState _self;
  final $Res Function(_RequestLocationPermissionState) _then;

/// Create a copy of RequestLocationPermissionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationPermission = freezed,}) {
  return _then(_RequestLocationPermissionState(
locationPermission: freezed == locationPermission ? _self.locationPermission : locationPermission // ignore: cast_nullable_to_non_nullable
as LocationPermission?,
  ));
}


}

// dart format on
