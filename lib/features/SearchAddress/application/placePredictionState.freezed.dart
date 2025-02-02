// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'placePredictionState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlacePredictionState {
  PlacePrediction? get placePrediction => throw _privateConstructorUsedError;
  PlaceDetails? get placeDetails => throw _privateConstructorUsedError;
  String? get selectedAddress => throw _privateConstructorUsedError;

  /// Create a copy of PlacePredictionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlacePredictionStateCopyWith<PlacePredictionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlacePredictionStateCopyWith<$Res> {
  factory $PlacePredictionStateCopyWith(PlacePredictionState value,
          $Res Function(PlacePredictionState) then) =
      _$PlacePredictionStateCopyWithImpl<$Res, PlacePredictionState>;
  @useResult
  $Res call(
      {PlacePrediction? placePrediction,
      PlaceDetails? placeDetails,
      String? selectedAddress});

  $PlacePredictionCopyWith<$Res>? get placePrediction;
  $PlaceDetailsCopyWith<$Res>? get placeDetails;
}

/// @nodoc
class _$PlacePredictionStateCopyWithImpl<$Res,
        $Val extends PlacePredictionState>
    implements $PlacePredictionStateCopyWith<$Res> {
  _$PlacePredictionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlacePredictionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placePrediction = freezed,
    Object? placeDetails = freezed,
    Object? selectedAddress = freezed,
  }) {
    return _then(_value.copyWith(
      placePrediction: freezed == placePrediction
          ? _value.placePrediction
          : placePrediction // ignore: cast_nullable_to_non_nullable
              as PlacePrediction?,
      placeDetails: freezed == placeDetails
          ? _value.placeDetails
          : placeDetails // ignore: cast_nullable_to_non_nullable
              as PlaceDetails?,
      selectedAddress: freezed == selectedAddress
          ? _value.selectedAddress
          : selectedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of PlacePredictionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlacePredictionCopyWith<$Res>? get placePrediction {
    if (_value.placePrediction == null) {
      return null;
    }

    return $PlacePredictionCopyWith<$Res>(_value.placePrediction!, (value) {
      return _then(_value.copyWith(placePrediction: value) as $Val);
    });
  }

  /// Create a copy of PlacePredictionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceDetailsCopyWith<$Res>? get placeDetails {
    if (_value.placeDetails == null) {
      return null;
    }

    return $PlaceDetailsCopyWith<$Res>(_value.placeDetails!, (value) {
      return _then(_value.copyWith(placeDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlacePredictionStateImplCopyWith<$Res>
    implements $PlacePredictionStateCopyWith<$Res> {
  factory _$$PlacePredictionStateImplCopyWith(_$PlacePredictionStateImpl value,
          $Res Function(_$PlacePredictionStateImpl) then) =
      __$$PlacePredictionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PlacePrediction? placePrediction,
      PlaceDetails? placeDetails,
      String? selectedAddress});

  @override
  $PlacePredictionCopyWith<$Res>? get placePrediction;
  @override
  $PlaceDetailsCopyWith<$Res>? get placeDetails;
}

/// @nodoc
class __$$PlacePredictionStateImplCopyWithImpl<$Res>
    extends _$PlacePredictionStateCopyWithImpl<$Res, _$PlacePredictionStateImpl>
    implements _$$PlacePredictionStateImplCopyWith<$Res> {
  __$$PlacePredictionStateImplCopyWithImpl(_$PlacePredictionStateImpl _value,
      $Res Function(_$PlacePredictionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlacePredictionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placePrediction = freezed,
    Object? placeDetails = freezed,
    Object? selectedAddress = freezed,
  }) {
    return _then(_$PlacePredictionStateImpl(
      placePrediction: freezed == placePrediction
          ? _value.placePrediction
          : placePrediction // ignore: cast_nullable_to_non_nullable
              as PlacePrediction?,
      placeDetails: freezed == placeDetails
          ? _value.placeDetails
          : placeDetails // ignore: cast_nullable_to_non_nullable
              as PlaceDetails?,
      selectedAddress: freezed == selectedAddress
          ? _value.selectedAddress
          : selectedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PlacePredictionStateImpl extends _PlacePredictionState {
  _$PlacePredictionStateImpl(
      {this.placePrediction, this.placeDetails, this.selectedAddress})
      : super._();

  @override
  final PlacePrediction? placePrediction;
  @override
  final PlaceDetails? placeDetails;
  @override
  final String? selectedAddress;

  @override
  String toString() {
    return 'PlacePredictionState(placePrediction: $placePrediction, placeDetails: $placeDetails, selectedAddress: $selectedAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlacePredictionStateImpl &&
            (identical(other.placePrediction, placePrediction) ||
                other.placePrediction == placePrediction) &&
            (identical(other.placeDetails, placeDetails) ||
                other.placeDetails == placeDetails) &&
            (identical(other.selectedAddress, selectedAddress) ||
                other.selectedAddress == selectedAddress));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, placePrediction, placeDetails, selectedAddress);

  /// Create a copy of PlacePredictionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlacePredictionStateImplCopyWith<_$PlacePredictionStateImpl>
      get copyWith =>
          __$$PlacePredictionStateImplCopyWithImpl<_$PlacePredictionStateImpl>(
              this, _$identity);
}

abstract class _PlacePredictionState extends PlacePredictionState {
  factory _PlacePredictionState(
      {final PlacePrediction? placePrediction,
      final PlaceDetails? placeDetails,
      final String? selectedAddress}) = _$PlacePredictionStateImpl;
  _PlacePredictionState._() : super._();

  @override
  PlacePrediction? get placePrediction;
  @override
  PlaceDetails? get placeDetails;
  @override
  String? get selectedAddress;

  /// Create a copy of PlacePredictionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlacePredictionStateImplCopyWith<_$PlacePredictionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
