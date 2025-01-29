// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carouselState.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CarouselState {
  int? get index => throw _privateConstructorUsedError;
  List<Carousel> get carouselList => throw _privateConstructorUsedError;

  /// Create a copy of CarouselState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarouselStateCopyWith<CarouselState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarouselStateCopyWith<$Res> {
  factory $CarouselStateCopyWith(
          CarouselState value, $Res Function(CarouselState) then) =
      _$CarouselStateCopyWithImpl<$Res, CarouselState>;
  @useResult
  $Res call({int? index, List<Carousel> carouselList});
}

/// @nodoc
class _$CarouselStateCopyWithImpl<$Res, $Val extends CarouselState>
    implements $CarouselStateCopyWith<$Res> {
  _$CarouselStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarouselState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = freezed,
    Object? carouselList = null,
  }) {
    return _then(_value.copyWith(
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      carouselList: null == carouselList
          ? _value.carouselList
          : carouselList // ignore: cast_nullable_to_non_nullable
              as List<Carousel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarouselStateImplCopyWith<$Res>
    implements $CarouselStateCopyWith<$Res> {
  factory _$$CarouselStateImplCopyWith(
          _$CarouselStateImpl value, $Res Function(_$CarouselStateImpl) then) =
      __$$CarouselStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? index, List<Carousel> carouselList});
}

/// @nodoc
class __$$CarouselStateImplCopyWithImpl<$Res>
    extends _$CarouselStateCopyWithImpl<$Res, _$CarouselStateImpl>
    implements _$$CarouselStateImplCopyWith<$Res> {
  __$$CarouselStateImplCopyWithImpl(
      _$CarouselStateImpl _value, $Res Function(_$CarouselStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarouselState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = freezed,
    Object? carouselList = null,
  }) {
    return _then(_$CarouselStateImpl(
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      carouselList: null == carouselList
          ? _value._carouselList
          : carouselList // ignore: cast_nullable_to_non_nullable
              as List<Carousel>,
    ));
  }
}

/// @nodoc

class _$CarouselStateImpl implements _CarouselState {
  _$CarouselStateImpl({this.index, required final List<Carousel> carouselList})
      : _carouselList = carouselList;

  @override
  final int? index;
  final List<Carousel> _carouselList;
  @override
  List<Carousel> get carouselList {
    if (_carouselList is EqualUnmodifiableListView) return _carouselList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_carouselList);
  }

  @override
  String toString() {
    return 'CarouselState(index: $index, carouselList: $carouselList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarouselStateImpl &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality()
                .equals(other._carouselList, _carouselList));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, index, const DeepCollectionEquality().hash(_carouselList));

  /// Create a copy of CarouselState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarouselStateImplCopyWith<_$CarouselStateImpl> get copyWith =>
      __$$CarouselStateImplCopyWithImpl<_$CarouselStateImpl>(this, _$identity);
}

abstract class _CarouselState implements CarouselState {
  factory _CarouselState(
      {final int? index,
      required final List<Carousel> carouselList}) = _$CarouselStateImpl;

  @override
  int? get index;
  @override
  List<Carousel> get carouselList;

  /// Create a copy of CarouselState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarouselStateImplCopyWith<_$CarouselStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
