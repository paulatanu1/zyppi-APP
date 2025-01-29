// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sharedPreferenceState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SharedPreferenceState {
  String? get authToken => throw _privateConstructorUsedError;
  SharedPreferences? get sharedPreference => throw _privateConstructorUsedError;

  /// Create a copy of SharedPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedPreferenceStateCopyWith<SharedPreferenceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedPreferenceStateCopyWith<$Res> {
  factory $SharedPreferenceStateCopyWith(SharedPreferenceState value,
          $Res Function(SharedPreferenceState) then) =
      _$SharedPreferenceStateCopyWithImpl<$Res, SharedPreferenceState>;
  @useResult
  $Res call({String? authToken, SharedPreferences? sharedPreference});
}

/// @nodoc
class _$SharedPreferenceStateCopyWithImpl<$Res,
        $Val extends SharedPreferenceState>
    implements $SharedPreferenceStateCopyWith<$Res> {
  _$SharedPreferenceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authToken = freezed,
    Object? sharedPreference = freezed,
  }) {
    return _then(_value.copyWith(
      authToken: freezed == authToken
          ? _value.authToken
          : authToken // ignore: cast_nullable_to_non_nullable
              as String?,
      sharedPreference: freezed == sharedPreference
          ? _value.sharedPreference
          : sharedPreference // ignore: cast_nullable_to_non_nullable
              as SharedPreferences?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SharedPreferenceStateImplCopyWith<$Res>
    implements $SharedPreferenceStateCopyWith<$Res> {
  factory _$$SharedPreferenceStateImplCopyWith(
          _$SharedPreferenceStateImpl value,
          $Res Function(_$SharedPreferenceStateImpl) then) =
      __$$SharedPreferenceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? authToken, SharedPreferences? sharedPreference});
}

/// @nodoc
class __$$SharedPreferenceStateImplCopyWithImpl<$Res>
    extends _$SharedPreferenceStateCopyWithImpl<$Res,
        _$SharedPreferenceStateImpl>
    implements _$$SharedPreferenceStateImplCopyWith<$Res> {
  __$$SharedPreferenceStateImplCopyWithImpl(_$SharedPreferenceStateImpl _value,
      $Res Function(_$SharedPreferenceStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SharedPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authToken = freezed,
    Object? sharedPreference = freezed,
  }) {
    return _then(_$SharedPreferenceStateImpl(
      authToken: freezed == authToken
          ? _value.authToken
          : authToken // ignore: cast_nullable_to_non_nullable
              as String?,
      sharedPreference: freezed == sharedPreference
          ? _value.sharedPreference
          : sharedPreference // ignore: cast_nullable_to_non_nullable
              as SharedPreferences?,
    ));
  }
}

/// @nodoc

class _$SharedPreferenceStateImpl implements _SharedPreferenceState {
  _$SharedPreferenceStateImpl({this.authToken, this.sharedPreference});

  @override
  final String? authToken;
  @override
  final SharedPreferences? sharedPreference;

  @override
  String toString() {
    return 'SharedPreferenceState(authToken: $authToken, sharedPreference: $sharedPreference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedPreferenceStateImpl &&
            (identical(other.authToken, authToken) ||
                other.authToken == authToken) &&
            (identical(other.sharedPreference, sharedPreference) ||
                other.sharedPreference == sharedPreference));
  }

  @override
  int get hashCode => Object.hash(runtimeType, authToken, sharedPreference);

  /// Create a copy of SharedPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedPreferenceStateImplCopyWith<_$SharedPreferenceStateImpl>
      get copyWith => __$$SharedPreferenceStateImplCopyWithImpl<
          _$SharedPreferenceStateImpl>(this, _$identity);
}

abstract class _SharedPreferenceState implements SharedPreferenceState {
  factory _SharedPreferenceState(
      {final String? authToken,
      final SharedPreferences? sharedPreference}) = _$SharedPreferenceStateImpl;

  @override
  String? get authToken;
  @override
  SharedPreferences? get sharedPreference;

  /// Create a copy of SharedPreferenceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedPreferenceStateImplCopyWith<_$SharedPreferenceStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
