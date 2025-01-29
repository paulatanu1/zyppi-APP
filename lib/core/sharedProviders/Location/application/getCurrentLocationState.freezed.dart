// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'getCurrentLocationState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GetCurrentLocationState {
  bool? get isDetecting => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;

  /// Create a copy of GetCurrentLocationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GetCurrentLocationStateCopyWith<GetCurrentLocationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetCurrentLocationStateCopyWith<$Res> {
  factory $GetCurrentLocationStateCopyWith(GetCurrentLocationState value,
          $Res Function(GetCurrentLocationState) then) =
      _$GetCurrentLocationStateCopyWithImpl<$Res, GetCurrentLocationState>;
  @useResult
  $Res call(
      {bool? isDetecting,
      double? latitude,
      double? longitude,
      String? address});
}

/// @nodoc
class _$GetCurrentLocationStateCopyWithImpl<$Res,
        $Val extends GetCurrentLocationState>
    implements $GetCurrentLocationStateCopyWith<$Res> {
  _$GetCurrentLocationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GetCurrentLocationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDetecting = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? address = freezed,
  }) {
    return _then(_value.copyWith(
      isDetecting: freezed == isDetecting
          ? _value.isDetecting
          : isDetecting // ignore: cast_nullable_to_non_nullable
              as bool?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetCurrentLocationStateImplCopyWith<$Res>
    implements $GetCurrentLocationStateCopyWith<$Res> {
  factory _$$GetCurrentLocationStateImplCopyWith(
          _$GetCurrentLocationStateImpl value,
          $Res Function(_$GetCurrentLocationStateImpl) then) =
      __$$GetCurrentLocationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? isDetecting,
      double? latitude,
      double? longitude,
      String? address});
}

/// @nodoc
class __$$GetCurrentLocationStateImplCopyWithImpl<$Res>
    extends _$GetCurrentLocationStateCopyWithImpl<$Res,
        _$GetCurrentLocationStateImpl>
    implements _$$GetCurrentLocationStateImplCopyWith<$Res> {
  __$$GetCurrentLocationStateImplCopyWithImpl(
      _$GetCurrentLocationStateImpl _value,
      $Res Function(_$GetCurrentLocationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GetCurrentLocationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDetecting = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? address = freezed,
  }) {
    return _then(_$GetCurrentLocationStateImpl(
      isDetecting: freezed == isDetecting
          ? _value.isDetecting
          : isDetecting // ignore: cast_nullable_to_non_nullable
              as bool?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GetCurrentLocationStateImpl implements _GetCurrentLocationState {
  _$GetCurrentLocationStateImpl(
      {required this.isDetecting,
      required this.latitude,
      required this.longitude,
      required this.address});

  @override
  final bool? isDetecting;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? address;

  @override
  String toString() {
    return 'GetCurrentLocationState(isDetecting: $isDetecting, latitude: $latitude, longitude: $longitude, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetCurrentLocationStateImpl &&
            (identical(other.isDetecting, isDetecting) ||
                other.isDetecting == isDetecting) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isDetecting, latitude, longitude, address);

  /// Create a copy of GetCurrentLocationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetCurrentLocationStateImplCopyWith<_$GetCurrentLocationStateImpl>
      get copyWith => __$$GetCurrentLocationStateImplCopyWithImpl<
          _$GetCurrentLocationStateImpl>(this, _$identity);
}

abstract class _GetCurrentLocationState implements GetCurrentLocationState {
  factory _GetCurrentLocationState(
      {required final bool? isDetecting,
      required final double? latitude,
      required final double? longitude,
      required final String? address}) = _$GetCurrentLocationStateImpl;

  @override
  bool? get isDetecting;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get address;

  /// Create a copy of GetCurrentLocationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetCurrentLocationStateImplCopyWith<_$GetCurrentLocationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
