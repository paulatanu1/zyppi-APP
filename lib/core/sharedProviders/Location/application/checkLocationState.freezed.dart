// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkLocationState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CheckLocationState {
  bool? get isEnabled => throw _privateConstructorUsedError;

  /// Create a copy of CheckLocationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckLocationStateCopyWith<CheckLocationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckLocationStateCopyWith<$Res> {
  factory $CheckLocationStateCopyWith(
          CheckLocationState value, $Res Function(CheckLocationState) then) =
      _$CheckLocationStateCopyWithImpl<$Res, CheckLocationState>;
  @useResult
  $Res call({bool? isEnabled});
}

/// @nodoc
class _$CheckLocationStateCopyWithImpl<$Res, $Val extends CheckLocationState>
    implements $CheckLocationStateCopyWith<$Res> {
  _$CheckLocationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckLocationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = freezed,
  }) {
    return _then(_value.copyWith(
      isEnabled: freezed == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckLocationStateImplCopyWith<$Res>
    implements $CheckLocationStateCopyWith<$Res> {
  factory _$$CheckLocationStateImplCopyWith(_$CheckLocationStateImpl value,
          $Res Function(_$CheckLocationStateImpl) then) =
      __$$CheckLocationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? isEnabled});
}

/// @nodoc
class __$$CheckLocationStateImplCopyWithImpl<$Res>
    extends _$CheckLocationStateCopyWithImpl<$Res, _$CheckLocationStateImpl>
    implements _$$CheckLocationStateImplCopyWith<$Res> {
  __$$CheckLocationStateImplCopyWithImpl(_$CheckLocationStateImpl _value,
      $Res Function(_$CheckLocationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckLocationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = freezed,
  }) {
    return _then(_$CheckLocationStateImpl(
      isEnabled: freezed == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$CheckLocationStateImpl extends _CheckLocationState {
  _$CheckLocationStateImpl({this.isEnabled}) : super._();

  @override
  final bool? isEnabled;

  @override
  String toString() {
    return 'CheckLocationState(isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckLocationStateImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isEnabled);

  /// Create a copy of CheckLocationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckLocationStateImplCopyWith<_$CheckLocationStateImpl> get copyWith =>
      __$$CheckLocationStateImplCopyWithImpl<_$CheckLocationStateImpl>(
          this, _$identity);
}

abstract class _CheckLocationState extends CheckLocationState {
  factory _CheckLocationState({final bool? isEnabled}) =
      _$CheckLocationStateImpl;
  _CheckLocationState._() : super._();

  @override
  bool? get isEnabled;

  /// Create a copy of CheckLocationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckLocationStateImplCopyWith<_$CheckLocationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
