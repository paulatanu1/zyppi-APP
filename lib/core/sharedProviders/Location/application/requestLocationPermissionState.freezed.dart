// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requestLocationPermissionState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RequestLocationPermissionState {
  LocationPermission? get locationPermission =>
      throw _privateConstructorUsedError;

  /// Create a copy of RequestLocationPermissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestLocationPermissionStateCopyWith<RequestLocationPermissionState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestLocationPermissionStateCopyWith<$Res> {
  factory $RequestLocationPermissionStateCopyWith(
          RequestLocationPermissionState value,
          $Res Function(RequestLocationPermissionState) then) =
      _$RequestLocationPermissionStateCopyWithImpl<$Res,
          RequestLocationPermissionState>;
  @useResult
  $Res call({LocationPermission? locationPermission});
}

/// @nodoc
class _$RequestLocationPermissionStateCopyWithImpl<$Res,
        $Val extends RequestLocationPermissionState>
    implements $RequestLocationPermissionStateCopyWith<$Res> {
  _$RequestLocationPermissionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestLocationPermissionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationPermission = freezed,
  }) {
    return _then(_value.copyWith(
      locationPermission: freezed == locationPermission
          ? _value.locationPermission
          : locationPermission // ignore: cast_nullable_to_non_nullable
              as LocationPermission?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RequestLocationPermissionStateImplCopyWith<$Res>
    implements $RequestLocationPermissionStateCopyWith<$Res> {
  factory _$$RequestLocationPermissionStateImplCopyWith(
          _$RequestLocationPermissionStateImpl value,
          $Res Function(_$RequestLocationPermissionStateImpl) then) =
      __$$RequestLocationPermissionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LocationPermission? locationPermission});
}

/// @nodoc
class __$$RequestLocationPermissionStateImplCopyWithImpl<$Res>
    extends _$RequestLocationPermissionStateCopyWithImpl<$Res,
        _$RequestLocationPermissionStateImpl>
    implements _$$RequestLocationPermissionStateImplCopyWith<$Res> {
  __$$RequestLocationPermissionStateImplCopyWithImpl(
      _$RequestLocationPermissionStateImpl _value,
      $Res Function(_$RequestLocationPermissionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RequestLocationPermissionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationPermission = freezed,
  }) {
    return _then(_$RequestLocationPermissionStateImpl(
      locationPermission: freezed == locationPermission
          ? _value.locationPermission
          : locationPermission // ignore: cast_nullable_to_non_nullable
              as LocationPermission?,
    ));
  }
}

/// @nodoc

class _$RequestLocationPermissionStateImpl
    implements _RequestLocationPermissionState {
  _$RequestLocationPermissionStateImpl({this.locationPermission});

  @override
  final LocationPermission? locationPermission;

  @override
  String toString() {
    return 'RequestLocationPermissionState(locationPermission: $locationPermission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestLocationPermissionStateImpl &&
            (identical(other.locationPermission, locationPermission) ||
                other.locationPermission == locationPermission));
  }

  @override
  int get hashCode => Object.hash(runtimeType, locationPermission);

  /// Create a copy of RequestLocationPermissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestLocationPermissionStateImplCopyWith<
          _$RequestLocationPermissionStateImpl>
      get copyWith => __$$RequestLocationPermissionStateImplCopyWithImpl<
          _$RequestLocationPermissionStateImpl>(this, _$identity);
}

abstract class _RequestLocationPermissionState
    implements RequestLocationPermissionState {
  factory _RequestLocationPermissionState(
          {final LocationPermission? locationPermission}) =
      _$RequestLocationPermissionStateImpl;

  @override
  LocationPermission? get locationPermission;

  /// Create a copy of RequestLocationPermissionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestLocationPermissionStateImplCopyWith<
          _$RequestLocationPermissionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
