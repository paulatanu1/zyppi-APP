// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_preference_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SharedPreferenceState {

 String? get authToken;
/// Create a copy of SharedPreferenceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedPreferenceStateCopyWith<SharedPreferenceState> get copyWith => _$SharedPreferenceStateCopyWithImpl<SharedPreferenceState>(this as SharedPreferenceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SharedPreferenceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedPreferenceState&&(identical(other.authToken, _this.authToken) || other.authToken == _this.authToken));
}


@override
int get hashCode {
  final _this = this as SharedPreferenceState;
  return Object.hash(runtimeType,_this.authToken);
}

@override
String toString() {
  final _this = this as SharedPreferenceState;
  return 'SharedPreferenceState(authToken: ${_this.authToken})';
}


}

/// @nodoc
abstract mixin class $SharedPreferenceStateCopyWith<$Res>  {
  factory $SharedPreferenceStateCopyWith(SharedPreferenceState value, $Res Function(SharedPreferenceState) _then) = _$SharedPreferenceStateCopyWithImpl;
@useResult
$Res call({
 String? authToken
});




}
/// @nodoc
class _$SharedPreferenceStateCopyWithImpl<$Res>
    implements $SharedPreferenceStateCopyWith<$Res> {
  _$SharedPreferenceStateCopyWithImpl(this._self, this._then);

  final SharedPreferenceState _self;
  final $Res Function(SharedPreferenceState) _then;

/// Create a copy of SharedPreferenceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authToken = freezed,}) {
  return _then(SharedPreferenceState(
authToken: freezed == authToken ? _self.authToken : authToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedPreferenceState].
extension SharedPreferenceStatePatterns on SharedPreferenceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedPreferenceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedPreferenceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedPreferenceState value)  $default,){
final _that = this;
switch (_that) {
case _SharedPreferenceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedPreferenceState value)?  $default,){
final _that = this;
switch (_that) {
case _SharedPreferenceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? authToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedPreferenceState() when $default != null:
return $default(_that.authToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? authToken)  $default,) {final _that = this;
switch (_that) {
case _SharedPreferenceState():
return $default(_that.authToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? authToken)?  $default,) {final _that = this;
switch (_that) {
case _SharedPreferenceState() when $default != null:
return $default(_that.authToken);case _:
  return null;

}
}

}

/// @nodoc


class _SharedPreferenceState implements SharedPreferenceState {
   _SharedPreferenceState({this.authToken});
  

@override final  String? authToken;

/// Create a copy of SharedPreferenceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedPreferenceStateCopyWith<_SharedPreferenceState> get copyWith => __$SharedPreferenceStateCopyWithImpl<_SharedPreferenceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedPreferenceState&&(identical(other.authToken, authToken) || other.authToken == authToken));
}


@override
int get hashCode {
    return Object.hash(runtimeType,authToken);
}

@override
String toString() {
    return 'SharedPreferenceState(authToken: $authToken)';
}


}

/// @nodoc
abstract mixin class _$SharedPreferenceStateCopyWith<$Res> implements $SharedPreferenceStateCopyWith<$Res> {
  factory _$SharedPreferenceStateCopyWith(_SharedPreferenceState value, $Res Function(_SharedPreferenceState) _then) = __$SharedPreferenceStateCopyWithImpl;
@override @useResult
$Res call({
 String? authToken
});




}
/// @nodoc
class __$SharedPreferenceStateCopyWithImpl<$Res>
    implements _$SharedPreferenceStateCopyWith<$Res> {
  __$SharedPreferenceStateCopyWithImpl(this._self, this._then);

  final _SharedPreferenceState _self;
  final $Res Function(_SharedPreferenceState) _then;

/// Create a copy of SharedPreferenceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authToken = freezed,}) {
  return _then(_SharedPreferenceState(
authToken: freezed == authToken ? _self.authToken : authToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
