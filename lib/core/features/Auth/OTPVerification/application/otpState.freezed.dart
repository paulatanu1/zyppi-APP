// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otpState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OtpState _$OtpStateFromJson(Map<String, dynamic> json) {
  return _OtpState.fromJson(json);
}

/// @nodoc
mixin _$OtpState {
  bool get loading => throw _privateConstructorUsedError;
  bool get otpLoading => throw _privateConstructorUsedError;
  String? get otp => throw _privateConstructorUsedError;
  String? get verificationId => throw _privateConstructorUsedError;
  LoginResponse? get loginResponse => throw _privateConstructorUsedError;

  /// Serializes this OtpState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtpStateCopyWith<OtpState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpStateCopyWith<$Res> {
  factory $OtpStateCopyWith(OtpState value, $Res Function(OtpState) then) =
      _$OtpStateCopyWithImpl<$Res, OtpState>;
  @useResult
  $Res call(
      {bool loading,
      bool otpLoading,
      String? otp,
      String? verificationId,
      LoginResponse? loginResponse});

  $LoginResponseCopyWith<$Res>? get loginResponse;
}

/// @nodoc
class _$OtpStateCopyWithImpl<$Res, $Val extends OtpState>
    implements $OtpStateCopyWith<$Res> {
  _$OtpStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? otpLoading = null,
    Object? otp = freezed,
    Object? verificationId = freezed,
    Object? loginResponse = freezed,
  }) {
    return _then(_value.copyWith(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      otpLoading: null == otpLoading
          ? _value.otpLoading
          : otpLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      otp: freezed == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String?,
      verificationId: freezed == verificationId
          ? _value.verificationId
          : verificationId // ignore: cast_nullable_to_non_nullable
              as String?,
      loginResponse: freezed == loginResponse
          ? _value.loginResponse
          : loginResponse // ignore: cast_nullable_to_non_nullable
              as LoginResponse?,
    ) as $Val);
  }

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LoginResponseCopyWith<$Res>? get loginResponse {
    if (_value.loginResponse == null) {
      return null;
    }

    return $LoginResponseCopyWith<$Res>(_value.loginResponse!, (value) {
      return _then(_value.copyWith(loginResponse: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OtpStateImplCopyWith<$Res>
    implements $OtpStateCopyWith<$Res> {
  factory _$$OtpStateImplCopyWith(
          _$OtpStateImpl value, $Res Function(_$OtpStateImpl) then) =
      __$$OtpStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool loading,
      bool otpLoading,
      String? otp,
      String? verificationId,
      LoginResponse? loginResponse});

  @override
  $LoginResponseCopyWith<$Res>? get loginResponse;
}

/// @nodoc
class __$$OtpStateImplCopyWithImpl<$Res>
    extends _$OtpStateCopyWithImpl<$Res, _$OtpStateImpl>
    implements _$$OtpStateImplCopyWith<$Res> {
  __$$OtpStateImplCopyWithImpl(
      _$OtpStateImpl _value, $Res Function(_$OtpStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? otpLoading = null,
    Object? otp = freezed,
    Object? verificationId = freezed,
    Object? loginResponse = freezed,
  }) {
    return _then(_$OtpStateImpl(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      otpLoading: null == otpLoading
          ? _value.otpLoading
          : otpLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      otp: freezed == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String?,
      verificationId: freezed == verificationId
          ? _value.verificationId
          : verificationId // ignore: cast_nullable_to_non_nullable
              as String?,
      loginResponse: freezed == loginResponse
          ? _value.loginResponse
          : loginResponse // ignore: cast_nullable_to_non_nullable
              as LoginResponse?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OtpStateImpl implements _OtpState {
  _$OtpStateImpl(
      {this.loading = false,
      this.otpLoading = false,
      this.otp,
      this.verificationId,
      this.loginResponse});

  factory _$OtpStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtpStateImplFromJson(json);

  @override
  @JsonKey()
  final bool loading;
  @override
  @JsonKey()
  final bool otpLoading;
  @override
  final String? otp;
  @override
  final String? verificationId;
  @override
  final LoginResponse? loginResponse;

  @override
  String toString() {
    return 'OtpState(loading: $loading, otpLoading: $otpLoading, otp: $otp, verificationId: $verificationId, loginResponse: $loginResponse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpStateImpl &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.otpLoading, otpLoading) ||
                other.otpLoading == otpLoading) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.verificationId, verificationId) ||
                other.verificationId == verificationId) &&
            (identical(other.loginResponse, loginResponse) ||
                other.loginResponse == loginResponse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, loading, otpLoading, otp, verificationId, loginResponse);

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpStateImplCopyWith<_$OtpStateImpl> get copyWith =>
      __$$OtpStateImplCopyWithImpl<_$OtpStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtpStateImplToJson(
      this,
    );
  }
}

abstract class _OtpState implements OtpState {
  factory _OtpState(
      {final bool loading,
      final bool otpLoading,
      final String? otp,
      final String? verificationId,
      final LoginResponse? loginResponse}) = _$OtpStateImpl;

  factory _OtpState.fromJson(Map<String, dynamic> json) =
      _$OtpStateImpl.fromJson;

  @override
  bool get loading;
  @override
  bool get otpLoading;
  @override
  String? get otp;
  @override
  String? get verificationId;
  @override
  LoginResponse? get loginResponse;

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpStateImplCopyWith<_$OtpStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
