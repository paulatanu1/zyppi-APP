// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_location_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckLocationState {

 bool? get isEnabled;
/// Create a copy of CheckLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckLocationStateCopyWith<CheckLocationState> get copyWith => _$CheckLocationStateCopyWithImpl<CheckLocationState>(this as CheckLocationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CheckLocationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckLocationState&&(identical(other.isEnabled, _this.isEnabled) || other.isEnabled == _this.isEnabled));
}


@override
int get hashCode {
  final _this = this as CheckLocationState;
  return Object.hash(runtimeType,_this.isEnabled);
}

@override
String toString() {
  final _this = this as CheckLocationState;
  return 'CheckLocationState(isEnabled: ${_this.isEnabled})';
}


}

/// @nodoc
abstract mixin class $CheckLocationStateCopyWith<$Res>  {
  factory $CheckLocationStateCopyWith(CheckLocationState value, $Res Function(CheckLocationState) _then) = _$CheckLocationStateCopyWithImpl;
@useResult
$Res call({
 bool? isEnabled
});




}
/// @nodoc
class _$CheckLocationStateCopyWithImpl<$Res>
    implements $CheckLocationStateCopyWith<$Res> {
  _$CheckLocationStateCopyWithImpl(this._self, this._then);

  final CheckLocationState _self;
  final $Res Function(CheckLocationState) _then;

/// Create a copy of CheckLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEnabled = freezed,}) {
  return _then(CheckLocationState(
isEnabled: freezed == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckLocationState].
extension CheckLocationStatePatterns on CheckLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckLocationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckLocationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckLocationState value)  $default,){
final _that = this;
switch (_that) {
case _CheckLocationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckLocationState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckLocationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? isEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckLocationState() when $default != null:
return $default(_that.isEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? isEnabled)  $default,) {final _that = this;
switch (_that) {
case _CheckLocationState():
return $default(_that.isEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? isEnabled)?  $default,) {final _that = this;
switch (_that) {
case _CheckLocationState() when $default != null:
return $default(_that.isEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _CheckLocationState extends CheckLocationState {
   _CheckLocationState({this.isEnabled}): super._();
  

@override final  bool? isEnabled;

/// Create a copy of CheckLocationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckLocationStateCopyWith<_CheckLocationState> get copyWith => __$CheckLocationStateCopyWithImpl<_CheckLocationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckLocationState&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isEnabled);
}

@override
String toString() {
    return 'CheckLocationState(isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class _$CheckLocationStateCopyWith<$Res> implements $CheckLocationStateCopyWith<$Res> {
  factory _$CheckLocationStateCopyWith(_CheckLocationState value, $Res Function(_CheckLocationState) _then) = __$CheckLocationStateCopyWithImpl;
@override @useResult
$Res call({
 bool? isEnabled
});




}
/// @nodoc
class __$CheckLocationStateCopyWithImpl<$Res>
    implements _$CheckLocationStateCopyWith<$Res> {
  __$CheckLocationStateCopyWithImpl(this._self, this._then);

  final _CheckLocationState _self;
  final $Res Function(_CheckLocationState) _then;

/// Create a copy of CheckLocationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEnabled = freezed,}) {
  return _then(_CheckLocationState(
isEnabled: freezed == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
