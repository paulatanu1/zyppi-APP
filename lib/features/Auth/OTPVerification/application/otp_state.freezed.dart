// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OtpState {

 bool get loading; bool get otpLoading; String? get otp; String? get verificationId; LoginResponse? get loginResponse;
/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpStateCopyWith<OtpState> get copyWith => _$OtpStateCopyWithImpl<OtpState>(this as OtpState, _$identity);

  /// Serializes this OtpState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OtpState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpState&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.otpLoading, _this.otpLoading) || other.otpLoading == _this.otpLoading)&&(identical(other.otp, _this.otp) || other.otp == _this.otp)&&(identical(other.verificationId, _this.verificationId) || other.verificationId == _this.verificationId)&&(identical(other.loginResponse, _this.loginResponse) || other.loginResponse == _this.loginResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OtpState;
  return Object.hash(runtimeType,_this.loading,_this.otpLoading,_this.otp,_this.verificationId,_this.loginResponse);
}

@override
String toString() {
  final _this = this as OtpState;
  return 'OtpState(loading: ${_this.loading}, otpLoading: ${_this.otpLoading}, otp: ${_this.otp}, verificationId: ${_this.verificationId}, loginResponse: ${_this.loginResponse})';
}


}

/// @nodoc
abstract mixin class $OtpStateCopyWith<$Res>  {
  factory $OtpStateCopyWith(OtpState value, $Res Function(OtpState) _then) = _$OtpStateCopyWithImpl;
@useResult
$Res call({
 bool loading, bool otpLoading, String? otp, String? verificationId, LoginResponse? loginResponse
});


$LoginResponseCopyWith<$Res>? get loginResponse;

}
/// @nodoc
class _$OtpStateCopyWithImpl<$Res>
    implements $OtpStateCopyWith<$Res> {
  _$OtpStateCopyWithImpl(this._self, this._then);

  final OtpState _self;
  final $Res Function(OtpState) _then;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? otpLoading = null,Object? otp = freezed,Object? verificationId = freezed,Object? loginResponse = freezed,}) {
  return _then(OtpState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,otpLoading: null == otpLoading ? _self.otpLoading : otpLoading // ignore: cast_nullable_to_non_nullable
as bool,otp: freezed == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String?,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,loginResponse: freezed == loginResponse ? _self.loginResponse : loginResponse // ignore: cast_nullable_to_non_nullable
as LoginResponse?,
  ));
}
/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoginResponseCopyWith<$Res>? get loginResponse {
    if (_self.loginResponse == null) {
    return null;
  }

  return $LoginResponseCopyWith<$Res>(_self.loginResponse!, (value) {
    return _then(_self.copyWith(loginResponse: value));
  });
}
}


/// Adds pattern-matching-related methods to [OtpState].
extension OtpStatePatterns on OtpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpState value)  $default,){
final _that = this;
switch (_that) {
case _OtpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpState value)?  $default,){
final _that = this;
switch (_that) {
case _OtpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  bool otpLoading,  String? otp,  String? verificationId,  LoginResponse? loginResponse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpState() when $default != null:
return $default(_that.loading,_that.otpLoading,_that.otp,_that.verificationId,_that.loginResponse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  bool otpLoading,  String? otp,  String? verificationId,  LoginResponse? loginResponse)  $default,) {final _that = this;
switch (_that) {
case _OtpState():
return $default(_that.loading,_that.otpLoading,_that.otp,_that.verificationId,_that.loginResponse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  bool otpLoading,  String? otp,  String? verificationId,  LoginResponse? loginResponse)?  $default,) {final _that = this;
switch (_that) {
case _OtpState() when $default != null:
return $default(_that.loading,_that.otpLoading,_that.otp,_that.verificationId,_that.loginResponse);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpState implements OtpState {
   _OtpState({this.loading = false, this.otpLoading = false, this.otp, this.verificationId, this.loginResponse});
  factory _OtpState.fromJson(Map<String, dynamic> json) => _$OtpStateFromJson(json);

@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool otpLoading;
@override final  String? otp;
@override final  String? verificationId;
@override final  LoginResponse? loginResponse;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpStateCopyWith<_OtpState> get copyWith => __$OtpStateCopyWithImpl<_OtpState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.otpLoading, otpLoading) || other.otpLoading == otpLoading)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.loginResponse, loginResponse) || other.loginResponse == loginResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,loading,otpLoading,otp,verificationId,loginResponse);
}

@override
String toString() {
    return 'OtpState(loading: $loading, otpLoading: $otpLoading, otp: $otp, verificationId: $verificationId, loginResponse: $loginResponse)';
}


}

/// @nodoc
abstract mixin class _$OtpStateCopyWith<$Res> implements $OtpStateCopyWith<$Res> {
  factory _$OtpStateCopyWith(_OtpState value, $Res Function(_OtpState) _then) = __$OtpStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, bool otpLoading, String? otp, String? verificationId, LoginResponse? loginResponse
});


@override $LoginResponseCopyWith<$Res>? get loginResponse;

}
/// @nodoc
class __$OtpStateCopyWithImpl<$Res>
    implements _$OtpStateCopyWith<$Res> {
  __$OtpStateCopyWithImpl(this._self, this._then);

  final _OtpState _self;
  final $Res Function(_OtpState) _then;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? otpLoading = null,Object? otp = freezed,Object? verificationId = freezed,Object? loginResponse = freezed,}) {
  return _then(_OtpState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,otpLoading: null == otpLoading ? _self.otpLoading : otpLoading // ignore: cast_nullable_to_non_nullable
as bool,otp: freezed == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String?,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,loginResponse: freezed == loginResponse ? _self.loginResponse : loginResponse // ignore: cast_nullable_to_non_nullable
as LoginResponse?,
  ));
}

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoginResponseCopyWith<$Res>? get loginResponse {
    if (_self.loginResponse == null) {
    return null;
  }

  return $LoginResponseCopyWith<$Res>(_self.loginResponse!, (value) {
    return _then(_self.copyWith(loginResponse: value));
  });
}
}

// dart format on
