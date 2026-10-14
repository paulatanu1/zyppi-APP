// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddressState {

 bool? get isSearchBoxClicked; bool? get boxClick; dynamic get sheetHeight;
/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressStateCopyWith<AddressState> get copyWith => _$AddressStateCopyWithImpl<AddressState>(this as AddressState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddressState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressState&&(identical(other.isSearchBoxClicked, _this.isSearchBoxClicked) || other.isSearchBoxClicked == _this.isSearchBoxClicked)&&(identical(other.boxClick, _this.boxClick) || other.boxClick == _this.boxClick)&&const DeepCollectionEquality().equals(other.sheetHeight, _this.sheetHeight));
}


@override
int get hashCode {
  final _this = this as AddressState;
  return Object.hash(runtimeType,_this.isSearchBoxClicked,_this.boxClick,const DeepCollectionEquality().hash(_this.sheetHeight));
}

@override
String toString() {
  final _this = this as AddressState;
  return 'AddressState(isSearchBoxClicked: ${_this.isSearchBoxClicked}, boxClick: ${_this.boxClick}, sheetHeight: ${_this.sheetHeight})';
}


}

/// @nodoc
abstract mixin class $AddressStateCopyWith<$Res>  {
  factory $AddressStateCopyWith(AddressState value, $Res Function(AddressState) _then) = _$AddressStateCopyWithImpl;
@useResult
$Res call({
 bool? isSearchBoxClicked, bool? boxClick, dynamic sheetHeight
});




}
/// @nodoc
class _$AddressStateCopyWithImpl<$Res>
    implements $AddressStateCopyWith<$Res> {
  _$AddressStateCopyWithImpl(this._self, this._then);

  final AddressState _self;
  final $Res Function(AddressState) _then;

/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSearchBoxClicked = freezed,Object? boxClick = freezed,Object? sheetHeight = freezed,}) {
  return _then(AddressState(
isSearchBoxClicked: freezed == isSearchBoxClicked ? _self.isSearchBoxClicked : isSearchBoxClicked // ignore: cast_nullable_to_non_nullable
as bool?,boxClick: freezed == boxClick ? _self.boxClick : boxClick // ignore: cast_nullable_to_non_nullable
as bool?,sheetHeight: freezed == sheetHeight ? _self.sheetHeight : sheetHeight // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressState].
extension AddressStatePatterns on AddressState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressState value)  $default,){
final _that = this;
switch (_that) {
case _AddressState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressState value)?  $default,){
final _that = this;
switch (_that) {
case _AddressState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? isSearchBoxClicked,  bool? boxClick,  dynamic sheetHeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressState() when $default != null:
return $default(_that.isSearchBoxClicked,_that.boxClick,_that.sheetHeight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? isSearchBoxClicked,  bool? boxClick,  dynamic sheetHeight)  $default,) {final _that = this;
switch (_that) {
case _AddressState():
return $default(_that.isSearchBoxClicked,_that.boxClick,_that.sheetHeight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? isSearchBoxClicked,  bool? boxClick,  dynamic sheetHeight)?  $default,) {final _that = this;
switch (_that) {
case _AddressState() when $default != null:
return $default(_that.isSearchBoxClicked,_that.boxClick,_that.sheetHeight);case _:
  return null;

}
}

}

/// @nodoc


class _AddressState implements AddressState {
   _AddressState({this.isSearchBoxClicked, this.boxClick, this.sheetHeight});
  

@override final  bool? isSearchBoxClicked;
@override final  bool? boxClick;
@override final  dynamic sheetHeight;

/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressStateCopyWith<_AddressState> get copyWith => __$AddressStateCopyWithImpl<_AddressState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressState&&(identical(other.isSearchBoxClicked, isSearchBoxClicked) || other.isSearchBoxClicked == isSearchBoxClicked)&&(identical(other.boxClick, boxClick) || other.boxClick == boxClick)&&const DeepCollectionEquality().equals(other.sheetHeight, sheetHeight));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isSearchBoxClicked,boxClick,const DeepCollectionEquality().hash(sheetHeight));
}

@override
String toString() {
    return 'AddressState(isSearchBoxClicked: $isSearchBoxClicked, boxClick: $boxClick, sheetHeight: $sheetHeight)';
}


}

/// @nodoc
abstract mixin class _$AddressStateCopyWith<$Res> implements $AddressStateCopyWith<$Res> {
  factory _$AddressStateCopyWith(_AddressState value, $Res Function(_AddressState) _then) = __$AddressStateCopyWithImpl;
@override @useResult
$Res call({
 bool? isSearchBoxClicked, bool? boxClick, dynamic sheetHeight
});




}
/// @nodoc
class __$AddressStateCopyWithImpl<$Res>
    implements _$AddressStateCopyWith<$Res> {
  __$AddressStateCopyWithImpl(this._self, this._then);

  final _AddressState _self;
  final $Res Function(_AddressState) _then;

/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSearchBoxClicked = freezed,Object? boxClick = freezed,Object? sheetHeight = freezed,}) {
  return _then(_AddressState(
isSearchBoxClicked: freezed == isSearchBoxClicked ? _self.isSearchBoxClicked : isSearchBoxClicked // ignore: cast_nullable_to_non_nullable
as bool?,boxClick: freezed == boxClick ? _self.boxClick : boxClick // ignore: cast_nullable_to_non_nullable
as bool?,sheetHeight: freezed == sheetHeight ? _self.sheetHeight : sheetHeight // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
