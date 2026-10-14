// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carousel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CarouselState {

 int? get index; List<Carousel> get carouselList;
/// Create a copy of CarouselState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarouselStateCopyWith<CarouselState> get copyWith => _$CarouselStateCopyWithImpl<CarouselState>(this as CarouselState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CarouselState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarouselState&&(identical(other.index, _this.index) || other.index == _this.index)&&const DeepCollectionEquality().equals(other.carouselList, _this.carouselList));
}


@override
int get hashCode {
  final _this = this as CarouselState;
  return Object.hash(runtimeType,_this.index,const DeepCollectionEquality().hash(_this.carouselList));
}

@override
String toString() {
  final _this = this as CarouselState;
  return 'CarouselState(index: ${_this.index}, carouselList: ${_this.carouselList})';
}


}

/// @nodoc
abstract mixin class $CarouselStateCopyWith<$Res>  {
  factory $CarouselStateCopyWith(CarouselState value, $Res Function(CarouselState) _then) = _$CarouselStateCopyWithImpl;
@useResult
$Res call({
 int? index, List<Carousel> carouselList
});




}
/// @nodoc
class _$CarouselStateCopyWithImpl<$Res>
    implements $CarouselStateCopyWith<$Res> {
  _$CarouselStateCopyWithImpl(this._self, this._then);

  final CarouselState _self;
  final $Res Function(CarouselState) _then;

/// Create a copy of CarouselState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = freezed,Object? carouselList = null,}) {
  return _then(CarouselState(
index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,carouselList: null == carouselList ? _self.carouselList : carouselList // ignore: cast_nullable_to_non_nullable
as List<Carousel>,
  ));
}

}


/// Adds pattern-matching-related methods to [CarouselState].
extension CarouselStatePatterns on CarouselState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarouselState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarouselState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarouselState value)  $default,){
final _that = this;
switch (_that) {
case _CarouselState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarouselState value)?  $default,){
final _that = this;
switch (_that) {
case _CarouselState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? index,  List<Carousel> carouselList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarouselState() when $default != null:
return $default(_that.index,_that.carouselList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? index,  List<Carousel> carouselList)  $default,) {final _that = this;
switch (_that) {
case _CarouselState():
return $default(_that.index,_that.carouselList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? index,  List<Carousel> carouselList)?  $default,) {final _that = this;
switch (_that) {
case _CarouselState() when $default != null:
return $default(_that.index,_that.carouselList);case _:
  return null;

}
}

}

/// @nodoc


class _CarouselState implements CarouselState {
   _CarouselState({this.index, required  List<Carousel> carouselList}): _carouselList = carouselList;
  

@override final  int? index;
 final  List<Carousel> _carouselList;
@override List<Carousel> get carouselList {
  if (_carouselList is EqualUnmodifiableListView) return _carouselList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_carouselList);
}


/// Create a copy of CarouselState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarouselStateCopyWith<_CarouselState> get copyWith => __$CarouselStateCopyWithImpl<_CarouselState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarouselState&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.carouselList, _carouselList));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index,const DeepCollectionEquality().hash(_carouselList));
}

@override
String toString() {
    return 'CarouselState(index: $index, carouselList: $carouselList)';
}


}

/// @nodoc
abstract mixin class _$CarouselStateCopyWith<$Res> implements $CarouselStateCopyWith<$Res> {
  factory _$CarouselStateCopyWith(_CarouselState value, $Res Function(_CarouselState) _then) = __$CarouselStateCopyWithImpl;
@override @useResult
$Res call({
 int? index, List<Carousel> carouselList
});




}
/// @nodoc
class __$CarouselStateCopyWithImpl<$Res>
    implements _$CarouselStateCopyWith<$Res> {
  __$CarouselStateCopyWithImpl(this._self, this._then);

  final _CarouselState _self;
  final $Res Function(_CarouselState) _then;

/// Create a copy of CarouselState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = freezed,Object? carouselList = null,}) {
  return _then(_CarouselState(
index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,carouselList: null == carouselList ? _self._carouselList : carouselList // ignore: cast_nullable_to_non_nullable
as List<Carousel>,
  ));
}


}

// dart format on
