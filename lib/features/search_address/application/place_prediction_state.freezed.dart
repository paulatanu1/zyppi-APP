// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_prediction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlacePredictionState {

 PlacePrediction? get placePrediction; PlaceDetails? get placeDetails; String? get selectedAddress;
/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlacePredictionStateCopyWith<PlacePredictionState> get copyWith => _$PlacePredictionStateCopyWithImpl<PlacePredictionState>(this as PlacePredictionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlacePredictionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlacePredictionState&&(identical(other.placePrediction, _this.placePrediction) || other.placePrediction == _this.placePrediction)&&(identical(other.placeDetails, _this.placeDetails) || other.placeDetails == _this.placeDetails)&&(identical(other.selectedAddress, _this.selectedAddress) || other.selectedAddress == _this.selectedAddress));
}


@override
int get hashCode {
  final _this = this as PlacePredictionState;
  return Object.hash(runtimeType,_this.placePrediction,_this.placeDetails,_this.selectedAddress);
}

@override
String toString() {
  final _this = this as PlacePredictionState;
  return 'PlacePredictionState(placePrediction: ${_this.placePrediction}, placeDetails: ${_this.placeDetails}, selectedAddress: ${_this.selectedAddress})';
}


}

/// @nodoc
abstract mixin class $PlacePredictionStateCopyWith<$Res>  {
  factory $PlacePredictionStateCopyWith(PlacePredictionState value, $Res Function(PlacePredictionState) _then) = _$PlacePredictionStateCopyWithImpl;
@useResult
$Res call({
 PlacePrediction? placePrediction, PlaceDetails? placeDetails, String? selectedAddress
});


$PlacePredictionCopyWith<$Res>? get placePrediction;$PlaceDetailsCopyWith<$Res>? get placeDetails;

}
/// @nodoc
class _$PlacePredictionStateCopyWithImpl<$Res>
    implements $PlacePredictionStateCopyWith<$Res> {
  _$PlacePredictionStateCopyWithImpl(this._self, this._then);

  final PlacePredictionState _self;
  final $Res Function(PlacePredictionState) _then;

/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placePrediction = freezed,Object? placeDetails = freezed,Object? selectedAddress = freezed,}) {
  return _then(PlacePredictionState(
placePrediction: freezed == placePrediction ? _self.placePrediction : placePrediction // ignore: cast_nullable_to_non_nullable
as PlacePrediction?,placeDetails: freezed == placeDetails ? _self.placeDetails : placeDetails // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,selectedAddress: freezed == selectedAddress ? _self.selectedAddress : selectedAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlacePredictionCopyWith<$Res>? get placePrediction {
    if (_self.placePrediction == null) {
    return null;
  }

  return $PlacePredictionCopyWith<$Res>(_self.placePrediction!, (value) {
    return _then(_self.copyWith(placePrediction: value));
  });
}/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceDetailsCopyWith<$Res>? get placeDetails {
    if (_self.placeDetails == null) {
    return null;
  }

  return $PlaceDetailsCopyWith<$Res>(_self.placeDetails!, (value) {
    return _then(_self.copyWith(placeDetails: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlacePredictionState].
extension PlacePredictionStatePatterns on PlacePredictionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlacePredictionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlacePredictionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlacePredictionState value)  $default,){
final _that = this;
switch (_that) {
case _PlacePredictionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlacePredictionState value)?  $default,){
final _that = this;
switch (_that) {
case _PlacePredictionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlacePrediction? placePrediction,  PlaceDetails? placeDetails,  String? selectedAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlacePredictionState() when $default != null:
return $default(_that.placePrediction,_that.placeDetails,_that.selectedAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlacePrediction? placePrediction,  PlaceDetails? placeDetails,  String? selectedAddress)  $default,) {final _that = this;
switch (_that) {
case _PlacePredictionState():
return $default(_that.placePrediction,_that.placeDetails,_that.selectedAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlacePrediction? placePrediction,  PlaceDetails? placeDetails,  String? selectedAddress)?  $default,) {final _that = this;
switch (_that) {
case _PlacePredictionState() when $default != null:
return $default(_that.placePrediction,_that.placeDetails,_that.selectedAddress);case _:
  return null;

}
}

}

/// @nodoc


class _PlacePredictionState extends PlacePredictionState {
   _PlacePredictionState({this.placePrediction, this.placeDetails, this.selectedAddress}): super._();
  

@override final  PlacePrediction? placePrediction;
@override final  PlaceDetails? placeDetails;
@override final  String? selectedAddress;

/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlacePredictionStateCopyWith<_PlacePredictionState> get copyWith => __$PlacePredictionStateCopyWithImpl<_PlacePredictionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlacePredictionState&&(identical(other.placePrediction, placePrediction) || other.placePrediction == placePrediction)&&(identical(other.placeDetails, placeDetails) || other.placeDetails == placeDetails)&&(identical(other.selectedAddress, selectedAddress) || other.selectedAddress == selectedAddress));
}


@override
int get hashCode {
    return Object.hash(runtimeType,placePrediction,placeDetails,selectedAddress);
}

@override
String toString() {
    return 'PlacePredictionState(placePrediction: $placePrediction, placeDetails: $placeDetails, selectedAddress: $selectedAddress)';
}


}

/// @nodoc
abstract mixin class _$PlacePredictionStateCopyWith<$Res> implements $PlacePredictionStateCopyWith<$Res> {
  factory _$PlacePredictionStateCopyWith(_PlacePredictionState value, $Res Function(_PlacePredictionState) _then) = __$PlacePredictionStateCopyWithImpl;
@override @useResult
$Res call({
 PlacePrediction? placePrediction, PlaceDetails? placeDetails, String? selectedAddress
});


@override $PlacePredictionCopyWith<$Res>? get placePrediction;@override $PlaceDetailsCopyWith<$Res>? get placeDetails;

}
/// @nodoc
class __$PlacePredictionStateCopyWithImpl<$Res>
    implements _$PlacePredictionStateCopyWith<$Res> {
  __$PlacePredictionStateCopyWithImpl(this._self, this._then);

  final _PlacePredictionState _self;
  final $Res Function(_PlacePredictionState) _then;

/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placePrediction = freezed,Object? placeDetails = freezed,Object? selectedAddress = freezed,}) {
  return _then(_PlacePredictionState(
placePrediction: freezed == placePrediction ? _self.placePrediction : placePrediction // ignore: cast_nullable_to_non_nullable
as PlacePrediction?,placeDetails: freezed == placeDetails ? _self.placeDetails : placeDetails // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,selectedAddress: freezed == selectedAddress ? _self.selectedAddress : selectedAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlacePredictionCopyWith<$Res>? get placePrediction {
    if (_self.placePrediction == null) {
    return null;
  }

  return $PlacePredictionCopyWith<$Res>(_self.placePrediction!, (value) {
    return _then(_self.copyWith(placePrediction: value));
  });
}/// Create a copy of PlacePredictionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceDetailsCopyWith<$Res>? get placeDetails {
    if (_self.placeDetails == null) {
    return null;
  }

  return $PlaceDetailsCopyWith<$Res>(_self.placeDetails!, (value) {
    return _then(_self.copyWith(placeDetails: value));
  });
}
}

// dart format on
