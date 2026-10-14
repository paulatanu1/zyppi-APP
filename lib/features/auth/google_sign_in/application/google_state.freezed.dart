// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoogleState {

 bool? get loading; String? get googleAccessToken; String? get googleIdToken;
/// Create a copy of GoogleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleStateCopyWith<GoogleState> get copyWith => _$GoogleStateCopyWithImpl<GoogleState>(this as GoogleState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GoogleState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleState&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.googleAccessToken, _this.googleAccessToken) || other.googleAccessToken == _this.googleAccessToken)&&(identical(other.googleIdToken, _this.googleIdToken) || other.googleIdToken == _this.googleIdToken));
}


@override
int get hashCode {
  final _this = this as GoogleState;
  return Object.hash(runtimeType,_this.loading,_this.googleAccessToken,_this.googleIdToken);
}

@override
String toString() {
  final _this = this as GoogleState;
  return 'GoogleState(loading: ${_this.loading}, googleAccessToken: ${_this.googleAccessToken}, googleIdToken: ${_this.googleIdToken})';
}


}

/// @nodoc
abstract mixin class $GoogleStateCopyWith<$Res>  {
  factory $GoogleStateCopyWith(GoogleState value, $Res Function(GoogleState) _then) = _$GoogleStateCopyWithImpl;
@useResult
$Res call({
 bool? loading, String? googleAccessToken, String? googleIdToken
});




}
/// @nodoc
class _$GoogleStateCopyWithImpl<$Res>
    implements $GoogleStateCopyWith<$Res> {
  _$GoogleStateCopyWithImpl(this._self, this._then);

  final GoogleState _self;
  final $Res Function(GoogleState) _then;

/// Create a copy of GoogleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = freezed,Object? googleAccessToken = freezed,Object? googleIdToken = freezed,}) {
  return _then(GoogleState(
loading: freezed == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool?,googleAccessToken: freezed == googleAccessToken ? _self.googleAccessToken : googleAccessToken // ignore: cast_nullable_to_non_nullable
as String?,googleIdToken: freezed == googleIdToken ? _self.googleIdToken : googleIdToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleState].
extension GoogleStatePatterns on GoogleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleState value)  $default,){
final _that = this;
switch (_that) {
case _GoogleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleState value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? loading,  String? googleAccessToken,  String? googleIdToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleState() when $default != null:
return $default(_that.loading,_that.googleAccessToken,_that.googleIdToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? loading,  String? googleAccessToken,  String? googleIdToken)  $default,) {final _that = this;
switch (_that) {
case _GoogleState():
return $default(_that.loading,_that.googleAccessToken,_that.googleIdToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? loading,  String? googleAccessToken,  String? googleIdToken)?  $default,) {final _that = this;
switch (_that) {
case _GoogleState() when $default != null:
return $default(_that.loading,_that.googleAccessToken,_that.googleIdToken);case _:
  return null;

}
}

}

/// @nodoc


class _GoogleState implements GoogleState {
   _GoogleState({this.loading, this.googleAccessToken, this.googleIdToken});
  

@override final  bool? loading;
@override final  String? googleAccessToken;
@override final  String? googleIdToken;

/// Create a copy of GoogleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleStateCopyWith<_GoogleState> get copyWith => __$GoogleStateCopyWithImpl<_GoogleState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.googleAccessToken, googleAccessToken) || other.googleAccessToken == googleAccessToken)&&(identical(other.googleIdToken, googleIdToken) || other.googleIdToken == googleIdToken));
}


@override
int get hashCode {
    return Object.hash(runtimeType,loading,googleAccessToken,googleIdToken);
}

@override
String toString() {
    return 'GoogleState(loading: $loading, googleAccessToken: $googleAccessToken, googleIdToken: $googleIdToken)';
}


}

/// @nodoc
abstract mixin class _$GoogleStateCopyWith<$Res> implements $GoogleStateCopyWith<$Res> {
  factory _$GoogleStateCopyWith(_GoogleState value, $Res Function(_GoogleState) _then) = __$GoogleStateCopyWithImpl;
@override @useResult
$Res call({
 bool? loading, String? googleAccessToken, String? googleIdToken
});




}
/// @nodoc
class __$GoogleStateCopyWithImpl<$Res>
    implements _$GoogleStateCopyWith<$Res> {
  __$GoogleStateCopyWithImpl(this._self, this._then);

  final _GoogleState _self;
  final $Res Function(_GoogleState) _then;

/// Create a copy of GoogleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = freezed,Object? googleAccessToken = freezed,Object? googleIdToken = freezed,}) {
  return _then(_GoogleState(
loading: freezed == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool?,googleAccessToken: freezed == googleAccessToken ? _self.googleAccessToken : googleAccessToken // ignore: cast_nullable_to_non_nullable
as String?,googleIdToken: freezed == googleIdToken ? _self.googleIdToken : googleIdToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
