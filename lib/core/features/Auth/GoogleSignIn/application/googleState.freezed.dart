// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'googleState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GoogleState {
  bool? get loading => throw _privateConstructorUsedError;
  String? get googleAccessToken => throw _privateConstructorUsedError;
  String? get googleIdToken => throw _privateConstructorUsedError;

  /// Create a copy of GoogleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoogleStateCopyWith<GoogleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoogleStateCopyWith<$Res> {
  factory $GoogleStateCopyWith(
          GoogleState value, $Res Function(GoogleState) then) =
      _$GoogleStateCopyWithImpl<$Res, GoogleState>;
  @useResult
  $Res call({bool? loading, String? googleAccessToken, String? googleIdToken});
}

/// @nodoc
class _$GoogleStateCopyWithImpl<$Res, $Val extends GoogleState>
    implements $GoogleStateCopyWith<$Res> {
  _$GoogleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoogleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = freezed,
    Object? googleAccessToken = freezed,
    Object? googleIdToken = freezed,
  }) {
    return _then(_value.copyWith(
      loading: freezed == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool?,
      googleAccessToken: freezed == googleAccessToken
          ? _value.googleAccessToken
          : googleAccessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      googleIdToken: freezed == googleIdToken
          ? _value.googleIdToken
          : googleIdToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoogleStateImplCopyWith<$Res>
    implements $GoogleStateCopyWith<$Res> {
  factory _$$GoogleStateImplCopyWith(
          _$GoogleStateImpl value, $Res Function(_$GoogleStateImpl) then) =
      __$$GoogleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? loading, String? googleAccessToken, String? googleIdToken});
}

/// @nodoc
class __$$GoogleStateImplCopyWithImpl<$Res>
    extends _$GoogleStateCopyWithImpl<$Res, _$GoogleStateImpl>
    implements _$$GoogleStateImplCopyWith<$Res> {
  __$$GoogleStateImplCopyWithImpl(
      _$GoogleStateImpl _value, $Res Function(_$GoogleStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoogleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = freezed,
    Object? googleAccessToken = freezed,
    Object? googleIdToken = freezed,
  }) {
    return _then(_$GoogleStateImpl(
      loading: freezed == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool?,
      googleAccessToken: freezed == googleAccessToken
          ? _value.googleAccessToken
          : googleAccessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      googleIdToken: freezed == googleIdToken
          ? _value.googleIdToken
          : googleIdToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GoogleStateImpl implements _GoogleState {
  _$GoogleStateImpl({this.loading, this.googleAccessToken, this.googleIdToken});

  @override
  final bool? loading;
  @override
  final String? googleAccessToken;
  @override
  final String? googleIdToken;

  @override
  String toString() {
    return 'GoogleState(loading: $loading, googleAccessToken: $googleAccessToken, googleIdToken: $googleIdToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoogleStateImpl &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.googleAccessToken, googleAccessToken) ||
                other.googleAccessToken == googleAccessToken) &&
            (identical(other.googleIdToken, googleIdToken) ||
                other.googleIdToken == googleIdToken));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, loading, googleAccessToken, googleIdToken);

  /// Create a copy of GoogleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoogleStateImplCopyWith<_$GoogleStateImpl> get copyWith =>
      __$$GoogleStateImplCopyWithImpl<_$GoogleStateImpl>(this, _$identity);
}

abstract class _GoogleState implements GoogleState {
  factory _GoogleState(
      {final bool? loading,
      final String? googleAccessToken,
      final String? googleIdToken}) = _$GoogleStateImpl;

  @override
  bool? get loading;
  @override
  String? get googleAccessToken;
  @override
  String? get googleIdToken;

  /// Create a copy of GoogleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoogleStateImplCopyWith<_$GoogleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
