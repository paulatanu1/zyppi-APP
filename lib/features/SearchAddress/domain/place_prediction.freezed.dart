// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_prediction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlacePrediction {

 List<Prediction>? get predictions; String? get status;
/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlacePredictionCopyWith<PlacePrediction> get copyWith => _$PlacePredictionCopyWithImpl<PlacePrediction>(this as PlacePrediction, _$identity);

  /// Serializes this PlacePrediction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlacePrediction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlacePrediction&&const DeepCollectionEquality().equals(other.predictions, _this.predictions)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlacePrediction;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.predictions),_this.status);
}

@override
String toString() {
  final _this = this as PlacePrediction;
  return 'PlacePrediction(predictions: ${_this.predictions}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $PlacePredictionCopyWith<$Res>  {
  factory $PlacePredictionCopyWith(PlacePrediction value, $Res Function(PlacePrediction) _then) = _$PlacePredictionCopyWithImpl;
@useResult
$Res call({
 List<Prediction>? predictions, String? status
});




}
/// @nodoc
class _$PlacePredictionCopyWithImpl<$Res>
    implements $PlacePredictionCopyWith<$Res> {
  _$PlacePredictionCopyWithImpl(this._self, this._then);

  final PlacePrediction _self;
  final $Res Function(PlacePrediction) _then;

/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? predictions = freezed,Object? status = freezed,}) {
  return _then(PlacePrediction(
predictions: freezed == predictions ? _self.predictions : predictions // ignore: cast_nullable_to_non_nullable
as List<Prediction>?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlacePrediction].
extension PlacePredictionPatterns on PlacePrediction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlacePrediction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlacePrediction value)  $default,){
final _that = this;
switch (_that) {
case _PlacePrediction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlacePrediction value)?  $default,){
final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Prediction>? predictions,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
return $default(_that.predictions,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Prediction>? predictions,  String? status)  $default,) {final _that = this;
switch (_that) {
case _PlacePrediction():
return $default(_that.predictions,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Prediction>? predictions,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
return $default(_that.predictions,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlacePrediction implements PlacePrediction {
  const _PlacePrediction({ List<Prediction>? predictions, this.status}): _predictions = predictions;
  factory _PlacePrediction.fromJson(Map<String, dynamic> json) => _$PlacePredictionFromJson(json);

 final  List<Prediction>? _predictions;
@override List<Prediction>? get predictions {
  final value = _predictions;
  if (value == null) return null;
  if (_predictions is EqualUnmodifiableListView) return _predictions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? status;

/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlacePredictionCopyWith<_PlacePrediction> get copyWith => __$PlacePredictionCopyWithImpl<_PlacePrediction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlacePredictionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlacePrediction&&const DeepCollectionEquality().equals(other.predictions, _predictions)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_predictions),status);
}

@override
String toString() {
    return 'PlacePrediction(predictions: $predictions, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PlacePredictionCopyWith<$Res> implements $PlacePredictionCopyWith<$Res> {
  factory _$PlacePredictionCopyWith(_PlacePrediction value, $Res Function(_PlacePrediction) _then) = __$PlacePredictionCopyWithImpl;
@override @useResult
$Res call({
 List<Prediction>? predictions, String? status
});




}
/// @nodoc
class __$PlacePredictionCopyWithImpl<$Res>
    implements _$PlacePredictionCopyWith<$Res> {
  __$PlacePredictionCopyWithImpl(this._self, this._then);

  final _PlacePrediction _self;
  final $Res Function(_PlacePrediction) _then;

/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? predictions = freezed,Object? status = freezed,}) {
  return _then(_PlacePrediction(
predictions: freezed == predictions ? _self._predictions : predictions // ignore: cast_nullable_to_non_nullable
as List<Prediction>?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Prediction {

 String? get description; List<MatchedSubstring>? get matchedSubstrings; String? get placeId; String? get reference; StructuredFormatting? get structuredFormatting; List<Term>? get terms; List<String>? get types;
/// Create a copy of Prediction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictionCopyWith<Prediction> get copyWith => _$PredictionCopyWithImpl<Prediction>(this as Prediction, _$identity);

  /// Serializes this Prediction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Prediction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Prediction&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.matchedSubstrings, _this.matchedSubstrings)&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.structuredFormatting, _this.structuredFormatting) || other.structuredFormatting == _this.structuredFormatting)&&const DeepCollectionEquality().equals(other.terms, _this.terms)&&const DeepCollectionEquality().equals(other.types, _this.types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Prediction;
  return Object.hash(runtimeType,_this.description,const DeepCollectionEquality().hash(_this.matchedSubstrings),_this.placeId,_this.reference,_this.structuredFormatting,const DeepCollectionEquality().hash(_this.terms),const DeepCollectionEquality().hash(_this.types));
}

@override
String toString() {
  final _this = this as Prediction;
  return 'Prediction(description: ${_this.description}, matchedSubstrings: ${_this.matchedSubstrings}, placeId: ${_this.placeId}, reference: ${_this.reference}, structuredFormatting: ${_this.structuredFormatting}, terms: ${_this.terms}, types: ${_this.types})';
}


}

/// @nodoc
abstract mixin class $PredictionCopyWith<$Res>  {
  factory $PredictionCopyWith(Prediction value, $Res Function(Prediction) _then) = _$PredictionCopyWithImpl;
@useResult
$Res call({
 String? description, List<MatchedSubstring>? matchedSubstrings, String? placeId, String? reference, StructuredFormatting? structuredFormatting, List<Term>? terms, List<String>? types
});


$StructuredFormattingCopyWith<$Res>? get structuredFormatting;

}
/// @nodoc
class _$PredictionCopyWithImpl<$Res>
    implements $PredictionCopyWith<$Res> {
  _$PredictionCopyWithImpl(this._self, this._then);

  final Prediction _self;
  final $Res Function(Prediction) _then;

/// Create a copy of Prediction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = freezed,Object? matchedSubstrings = freezed,Object? placeId = freezed,Object? reference = freezed,Object? structuredFormatting = freezed,Object? terms = freezed,Object? types = freezed,}) {
  return _then(Prediction(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,matchedSubstrings: freezed == matchedSubstrings ? _self.matchedSubstrings : matchedSubstrings // ignore: cast_nullable_to_non_nullable
as List<MatchedSubstring>?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,structuredFormatting: freezed == structuredFormatting ? _self.structuredFormatting : structuredFormatting // ignore: cast_nullable_to_non_nullable
as StructuredFormatting?,terms: freezed == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as List<Term>?,types: freezed == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of Prediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredFormattingCopyWith<$Res>? get structuredFormatting {
    if (_self.structuredFormatting == null) {
    return null;
  }

  return $StructuredFormattingCopyWith<$Res>(_self.structuredFormatting!, (value) {
    return _then(_self.copyWith(structuredFormatting: value));
  });
}
}


/// Adds pattern-matching-related methods to [Prediction].
extension PredictionPatterns on Prediction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Prediction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Prediction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Prediction value)  $default,){
final _that = this;
switch (_that) {
case _Prediction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Prediction value)?  $default,){
final _that = this;
switch (_that) {
case _Prediction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? description,  List<MatchedSubstring>? matchedSubstrings,  String? placeId,  String? reference,  StructuredFormatting? structuredFormatting,  List<Term>? terms,  List<String>? types)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Prediction() when $default != null:
return $default(_that.description,_that.matchedSubstrings,_that.placeId,_that.reference,_that.structuredFormatting,_that.terms,_that.types);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? description,  List<MatchedSubstring>? matchedSubstrings,  String? placeId,  String? reference,  StructuredFormatting? structuredFormatting,  List<Term>? terms,  List<String>? types)  $default,) {final _that = this;
switch (_that) {
case _Prediction():
return $default(_that.description,_that.matchedSubstrings,_that.placeId,_that.reference,_that.structuredFormatting,_that.terms,_that.types);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? description,  List<MatchedSubstring>? matchedSubstrings,  String? placeId,  String? reference,  StructuredFormatting? structuredFormatting,  List<Term>? terms,  List<String>? types)?  $default,) {final _that = this;
switch (_that) {
case _Prediction() when $default != null:
return $default(_that.description,_that.matchedSubstrings,_that.placeId,_that.reference,_that.structuredFormatting,_that.terms,_that.types);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Prediction implements Prediction {
  const _Prediction({this.description,  List<MatchedSubstring>? matchedSubstrings, this.placeId, this.reference, this.structuredFormatting,  List<Term>? terms,  List<String>? types}): _matchedSubstrings = matchedSubstrings,_terms = terms,_types = types;
  factory _Prediction.fromJson(Map<String, dynamic> json) => _$PredictionFromJson(json);

@override final  String? description;
 final  List<MatchedSubstring>? _matchedSubstrings;
@override List<MatchedSubstring>? get matchedSubstrings {
  final value = _matchedSubstrings;
  if (value == null) return null;
  if (_matchedSubstrings is EqualUnmodifiableListView) return _matchedSubstrings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? placeId;
@override final  String? reference;
@override final  StructuredFormatting? structuredFormatting;
 final  List<Term>? _terms;
@override List<Term>? get terms {
  final value = _terms;
  if (value == null) return null;
  if (_terms is EqualUnmodifiableListView) return _terms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _types;
@override List<String>? get types {
  final value = _types;
  if (value == null) return null;
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Prediction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictionCopyWith<_Prediction> get copyWith => __$PredictionCopyWithImpl<_Prediction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Prediction&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.matchedSubstrings, _matchedSubstrings)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.structuredFormatting, structuredFormatting) || other.structuredFormatting == structuredFormatting)&&const DeepCollectionEquality().equals(other.terms, _terms)&&const DeepCollectionEquality().equals(other.types, _types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,description,const DeepCollectionEquality().hash(_matchedSubstrings),placeId,reference,structuredFormatting,const DeepCollectionEquality().hash(_terms),const DeepCollectionEquality().hash(_types));
}

@override
String toString() {
    return 'Prediction(description: $description, matchedSubstrings: $matchedSubstrings, placeId: $placeId, reference: $reference, structuredFormatting: $structuredFormatting, terms: $terms, types: $types)';
}


}

/// @nodoc
abstract mixin class _$PredictionCopyWith<$Res> implements $PredictionCopyWith<$Res> {
  factory _$PredictionCopyWith(_Prediction value, $Res Function(_Prediction) _then) = __$PredictionCopyWithImpl;
@override @useResult
$Res call({
 String? description, List<MatchedSubstring>? matchedSubstrings, String? placeId, String? reference, StructuredFormatting? structuredFormatting, List<Term>? terms, List<String>? types
});


@override $StructuredFormattingCopyWith<$Res>? get structuredFormatting;

}
/// @nodoc
class __$PredictionCopyWithImpl<$Res>
    implements _$PredictionCopyWith<$Res> {
  __$PredictionCopyWithImpl(this._self, this._then);

  final _Prediction _self;
  final $Res Function(_Prediction) _then;

/// Create a copy of Prediction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = freezed,Object? matchedSubstrings = freezed,Object? placeId = freezed,Object? reference = freezed,Object? structuredFormatting = freezed,Object? terms = freezed,Object? types = freezed,}) {
  return _then(_Prediction(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,matchedSubstrings: freezed == matchedSubstrings ? _self._matchedSubstrings : matchedSubstrings // ignore: cast_nullable_to_non_nullable
as List<MatchedSubstring>?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,structuredFormatting: freezed == structuredFormatting ? _self.structuredFormatting : structuredFormatting // ignore: cast_nullable_to_non_nullable
as StructuredFormatting?,terms: freezed == terms ? _self._terms : terms // ignore: cast_nullable_to_non_nullable
as List<Term>?,types: freezed == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of Prediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredFormattingCopyWith<$Res>? get structuredFormatting {
    if (_self.structuredFormatting == null) {
    return null;
  }

  return $StructuredFormattingCopyWith<$Res>(_self.structuredFormatting!, (value) {
    return _then(_self.copyWith(structuredFormatting: value));
  });
}
}


/// @nodoc
mixin _$MatchedSubstring {

 int? get length; int? get offset;
/// Create a copy of MatchedSubstring
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchedSubstringCopyWith<MatchedSubstring> get copyWith => _$MatchedSubstringCopyWithImpl<MatchedSubstring>(this as MatchedSubstring, _$identity);

  /// Serializes this MatchedSubstring to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MatchedSubstring;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchedSubstring&&(identical(other.length, _this.length) || other.length == _this.length)&&(identical(other.offset, _this.offset) || other.offset == _this.offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MatchedSubstring;
  return Object.hash(runtimeType,_this.length,_this.offset);
}

@override
String toString() {
  final _this = this as MatchedSubstring;
  return 'MatchedSubstring(length: ${_this.length}, offset: ${_this.offset})';
}


}

/// @nodoc
abstract mixin class $MatchedSubstringCopyWith<$Res>  {
  factory $MatchedSubstringCopyWith(MatchedSubstring value, $Res Function(MatchedSubstring) _then) = _$MatchedSubstringCopyWithImpl;
@useResult
$Res call({
 int? length, int? offset
});




}
/// @nodoc
class _$MatchedSubstringCopyWithImpl<$Res>
    implements $MatchedSubstringCopyWith<$Res> {
  _$MatchedSubstringCopyWithImpl(this._self, this._then);

  final MatchedSubstring _self;
  final $Res Function(MatchedSubstring) _then;

/// Create a copy of MatchedSubstring
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? length = freezed,Object? offset = freezed,}) {
  return _then(MatchedSubstring(
length: freezed == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchedSubstring].
extension MatchedSubstringPatterns on MatchedSubstring {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchedSubstring value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchedSubstring() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchedSubstring value)  $default,){
final _that = this;
switch (_that) {
case _MatchedSubstring():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchedSubstring value)?  $default,){
final _that = this;
switch (_that) {
case _MatchedSubstring() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? length,  int? offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchedSubstring() when $default != null:
return $default(_that.length,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? length,  int? offset)  $default,) {final _that = this;
switch (_that) {
case _MatchedSubstring():
return $default(_that.length,_that.offset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? length,  int? offset)?  $default,) {final _that = this;
switch (_that) {
case _MatchedSubstring() when $default != null:
return $default(_that.length,_that.offset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchedSubstring implements MatchedSubstring {
  const _MatchedSubstring({this.length, this.offset});
  factory _MatchedSubstring.fromJson(Map<String, dynamic> json) => _$MatchedSubstringFromJson(json);

@override final  int? length;
@override final  int? offset;

/// Create a copy of MatchedSubstring
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchedSubstringCopyWith<_MatchedSubstring> get copyWith => __$MatchedSubstringCopyWithImpl<_MatchedSubstring>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchedSubstringToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchedSubstring&&(identical(other.length, length) || other.length == length)&&(identical(other.offset, offset) || other.offset == offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,length,offset);
}

@override
String toString() {
    return 'MatchedSubstring(length: $length, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$MatchedSubstringCopyWith<$Res> implements $MatchedSubstringCopyWith<$Res> {
  factory _$MatchedSubstringCopyWith(_MatchedSubstring value, $Res Function(_MatchedSubstring) _then) = __$MatchedSubstringCopyWithImpl;
@override @useResult
$Res call({
 int? length, int? offset
});




}
/// @nodoc
class __$MatchedSubstringCopyWithImpl<$Res>
    implements _$MatchedSubstringCopyWith<$Res> {
  __$MatchedSubstringCopyWithImpl(this._self, this._then);

  final _MatchedSubstring _self;
  final $Res Function(_MatchedSubstring) _then;

/// Create a copy of MatchedSubstring
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? length = freezed,Object? offset = freezed,}) {
  return _then(_MatchedSubstring(
length: freezed == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$StructuredFormatting {

 String? get mainText; List<MatchedSubstring>? get mainTextMatchedSubstrings; String? get secondaryText;
/// Create a copy of StructuredFormatting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StructuredFormattingCopyWith<StructuredFormatting> get copyWith => _$StructuredFormattingCopyWithImpl<StructuredFormatting>(this as StructuredFormatting, _$identity);

  /// Serializes this StructuredFormatting to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StructuredFormatting;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StructuredFormatting&&(identical(other.mainText, _this.mainText) || other.mainText == _this.mainText)&&const DeepCollectionEquality().equals(other.mainTextMatchedSubstrings, _this.mainTextMatchedSubstrings)&&(identical(other.secondaryText, _this.secondaryText) || other.secondaryText == _this.secondaryText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StructuredFormatting;
  return Object.hash(runtimeType,_this.mainText,const DeepCollectionEquality().hash(_this.mainTextMatchedSubstrings),_this.secondaryText);
}

@override
String toString() {
  final _this = this as StructuredFormatting;
  return 'StructuredFormatting(mainText: ${_this.mainText}, mainTextMatchedSubstrings: ${_this.mainTextMatchedSubstrings}, secondaryText: ${_this.secondaryText})';
}


}

/// @nodoc
abstract mixin class $StructuredFormattingCopyWith<$Res>  {
  factory $StructuredFormattingCopyWith(StructuredFormatting value, $Res Function(StructuredFormatting) _then) = _$StructuredFormattingCopyWithImpl;
@useResult
$Res call({
 String? mainText, List<MatchedSubstring>? mainTextMatchedSubstrings, String? secondaryText
});




}
/// @nodoc
class _$StructuredFormattingCopyWithImpl<$Res>
    implements $StructuredFormattingCopyWith<$Res> {
  _$StructuredFormattingCopyWithImpl(this._self, this._then);

  final StructuredFormatting _self;
  final $Res Function(StructuredFormatting) _then;

/// Create a copy of StructuredFormatting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mainText = freezed,Object? mainTextMatchedSubstrings = freezed,Object? secondaryText = freezed,}) {
  return _then(StructuredFormatting(
mainText: freezed == mainText ? _self.mainText : mainText // ignore: cast_nullable_to_non_nullable
as String?,mainTextMatchedSubstrings: freezed == mainTextMatchedSubstrings ? _self.mainTextMatchedSubstrings : mainTextMatchedSubstrings // ignore: cast_nullable_to_non_nullable
as List<MatchedSubstring>?,secondaryText: freezed == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StructuredFormatting].
extension StructuredFormattingPatterns on StructuredFormatting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StructuredFormatting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StructuredFormatting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StructuredFormatting value)  $default,){
final _that = this;
switch (_that) {
case _StructuredFormatting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StructuredFormatting value)?  $default,){
final _that = this;
switch (_that) {
case _StructuredFormatting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? mainText,  List<MatchedSubstring>? mainTextMatchedSubstrings,  String? secondaryText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StructuredFormatting() when $default != null:
return $default(_that.mainText,_that.mainTextMatchedSubstrings,_that.secondaryText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? mainText,  List<MatchedSubstring>? mainTextMatchedSubstrings,  String? secondaryText)  $default,) {final _that = this;
switch (_that) {
case _StructuredFormatting():
return $default(_that.mainText,_that.mainTextMatchedSubstrings,_that.secondaryText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? mainText,  List<MatchedSubstring>? mainTextMatchedSubstrings,  String? secondaryText)?  $default,) {final _that = this;
switch (_that) {
case _StructuredFormatting() when $default != null:
return $default(_that.mainText,_that.mainTextMatchedSubstrings,_that.secondaryText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StructuredFormatting implements StructuredFormatting {
  const _StructuredFormatting({this.mainText,  List<MatchedSubstring>? mainTextMatchedSubstrings, this.secondaryText}): _mainTextMatchedSubstrings = mainTextMatchedSubstrings;
  factory _StructuredFormatting.fromJson(Map<String, dynamic> json) => _$StructuredFormattingFromJson(json);

@override final  String? mainText;
 final  List<MatchedSubstring>? _mainTextMatchedSubstrings;
@override List<MatchedSubstring>? get mainTextMatchedSubstrings {
  final value = _mainTextMatchedSubstrings;
  if (value == null) return null;
  if (_mainTextMatchedSubstrings is EqualUnmodifiableListView) return _mainTextMatchedSubstrings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? secondaryText;

/// Create a copy of StructuredFormatting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StructuredFormattingCopyWith<_StructuredFormatting> get copyWith => __$StructuredFormattingCopyWithImpl<_StructuredFormatting>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StructuredFormattingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StructuredFormatting&&(identical(other.mainText, mainText) || other.mainText == mainText)&&const DeepCollectionEquality().equals(other.mainTextMatchedSubstrings, _mainTextMatchedSubstrings)&&(identical(other.secondaryText, secondaryText) || other.secondaryText == secondaryText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mainText,const DeepCollectionEquality().hash(_mainTextMatchedSubstrings),secondaryText);
}

@override
String toString() {
    return 'StructuredFormatting(mainText: $mainText, mainTextMatchedSubstrings: $mainTextMatchedSubstrings, secondaryText: $secondaryText)';
}


}

/// @nodoc
abstract mixin class _$StructuredFormattingCopyWith<$Res> implements $StructuredFormattingCopyWith<$Res> {
  factory _$StructuredFormattingCopyWith(_StructuredFormatting value, $Res Function(_StructuredFormatting) _then) = __$StructuredFormattingCopyWithImpl;
@override @useResult
$Res call({
 String? mainText, List<MatchedSubstring>? mainTextMatchedSubstrings, String? secondaryText
});




}
/// @nodoc
class __$StructuredFormattingCopyWithImpl<$Res>
    implements _$StructuredFormattingCopyWith<$Res> {
  __$StructuredFormattingCopyWithImpl(this._self, this._then);

  final _StructuredFormatting _self;
  final $Res Function(_StructuredFormatting) _then;

/// Create a copy of StructuredFormatting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mainText = freezed,Object? mainTextMatchedSubstrings = freezed,Object? secondaryText = freezed,}) {
  return _then(_StructuredFormatting(
mainText: freezed == mainText ? _self.mainText : mainText // ignore: cast_nullable_to_non_nullable
as String?,mainTextMatchedSubstrings: freezed == mainTextMatchedSubstrings ? _self._mainTextMatchedSubstrings : mainTextMatchedSubstrings // ignore: cast_nullable_to_non_nullable
as List<MatchedSubstring>?,secondaryText: freezed == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Term {

 int? get offset; String? get value;
/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TermCopyWith<Term> get copyWith => _$TermCopyWithImpl<Term>(this as Term, _$identity);

  /// Serializes this Term to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Term;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Term&&(identical(other.offset, _this.offset) || other.offset == _this.offset)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Term;
  return Object.hash(runtimeType,_this.offset,_this.value);
}

@override
String toString() {
  final _this = this as Term;
  return 'Term(offset: ${_this.offset}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $TermCopyWith<$Res>  {
  factory $TermCopyWith(Term value, $Res Function(Term) _then) = _$TermCopyWithImpl;
@useResult
$Res call({
 int? offset, String? value
});




}
/// @nodoc
class _$TermCopyWithImpl<$Res>
    implements $TermCopyWith<$Res> {
  _$TermCopyWithImpl(this._self, this._then);

  final Term _self;
  final $Res Function(Term) _then;

/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offset = freezed,Object? value = freezed,}) {
  return _then(Term(
offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Term].
extension TermPatterns on Term {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Term value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Term() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Term value)  $default,){
final _that = this;
switch (_that) {
case _Term():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Term value)?  $default,){
final _that = this;
switch (_that) {
case _Term() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? offset,  String? value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Term() when $default != null:
return $default(_that.offset,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? offset,  String? value)  $default,) {final _that = this;
switch (_that) {
case _Term():
return $default(_that.offset,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? offset,  String? value)?  $default,) {final _that = this;
switch (_that) {
case _Term() when $default != null:
return $default(_that.offset,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Term implements Term {
  const _Term({this.offset, this.value});
  factory _Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);

@override final  int? offset;
@override final  String? value;

/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TermCopyWith<_Term> get copyWith => __$TermCopyWithImpl<_Term>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TermToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Term&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,offset,value);
}

@override
String toString() {
    return 'Term(offset: $offset, value: $value)';
}


}

/// @nodoc
abstract mixin class _$TermCopyWith<$Res> implements $TermCopyWith<$Res> {
  factory _$TermCopyWith(_Term value, $Res Function(_Term) _then) = __$TermCopyWithImpl;
@override @useResult
$Res call({
 int? offset, String? value
});




}
/// @nodoc
class __$TermCopyWithImpl<$Res>
    implements _$TermCopyWith<$Res> {
  __$TermCopyWithImpl(this._self, this._then);

  final _Term _self;
  final $Res Function(_Term) _then;

/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offset = freezed,Object? value = freezed,}) {
  return _then(_Term(
offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
