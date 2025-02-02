// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'placePrediction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlacePrediction _$PlacePredictionFromJson(Map<String, dynamic> json) {
  return _PlacePrediction.fromJson(json);
}

/// @nodoc
mixin _$PlacePrediction {
  List<Prediction>? get predictions => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this PlacePrediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlacePrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlacePredictionCopyWith<PlacePrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlacePredictionCopyWith<$Res> {
  factory $PlacePredictionCopyWith(
          PlacePrediction value, $Res Function(PlacePrediction) then) =
      _$PlacePredictionCopyWithImpl<$Res, PlacePrediction>;
  @useResult
  $Res call({List<Prediction>? predictions, String? status});
}

/// @nodoc
class _$PlacePredictionCopyWithImpl<$Res, $Val extends PlacePrediction>
    implements $PlacePredictionCopyWith<$Res> {
  _$PlacePredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlacePrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? predictions = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      predictions: freezed == predictions
          ? _value.predictions
          : predictions // ignore: cast_nullable_to_non_nullable
              as List<Prediction>?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlacePredictionImplCopyWith<$Res>
    implements $PlacePredictionCopyWith<$Res> {
  factory _$$PlacePredictionImplCopyWith(_$PlacePredictionImpl value,
          $Res Function(_$PlacePredictionImpl) then) =
      __$$PlacePredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Prediction>? predictions, String? status});
}

/// @nodoc
class __$$PlacePredictionImplCopyWithImpl<$Res>
    extends _$PlacePredictionCopyWithImpl<$Res, _$PlacePredictionImpl>
    implements _$$PlacePredictionImplCopyWith<$Res> {
  __$$PlacePredictionImplCopyWithImpl(
      _$PlacePredictionImpl _value, $Res Function(_$PlacePredictionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlacePrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? predictions = freezed,
    Object? status = freezed,
  }) {
    return _then(_$PlacePredictionImpl(
      predictions: freezed == predictions
          ? _value._predictions
          : predictions // ignore: cast_nullable_to_non_nullable
              as List<Prediction>?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlacePredictionImpl implements _PlacePrediction {
  const _$PlacePredictionImpl(
      {final List<Prediction>? predictions, this.status})
      : _predictions = predictions;

  factory _$PlacePredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlacePredictionImplFromJson(json);

  final List<Prediction>? _predictions;
  @override
  List<Prediction>? get predictions {
    final value = _predictions;
    if (value == null) return null;
    if (_predictions is EqualUnmodifiableListView) return _predictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? status;

  @override
  String toString() {
    return 'PlacePrediction(predictions: $predictions, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlacePredictionImpl &&
            const DeepCollectionEquality()
                .equals(other._predictions, _predictions) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_predictions), status);

  /// Create a copy of PlacePrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlacePredictionImplCopyWith<_$PlacePredictionImpl> get copyWith =>
      __$$PlacePredictionImplCopyWithImpl<_$PlacePredictionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlacePredictionImplToJson(
      this,
    );
  }
}

abstract class _PlacePrediction implements PlacePrediction {
  const factory _PlacePrediction(
      {final List<Prediction>? predictions,
      final String? status}) = _$PlacePredictionImpl;

  factory _PlacePrediction.fromJson(Map<String, dynamic> json) =
      _$PlacePredictionImpl.fromJson;

  @override
  List<Prediction>? get predictions;
  @override
  String? get status;

  /// Create a copy of PlacePrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlacePredictionImplCopyWith<_$PlacePredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Prediction _$PredictionFromJson(Map<String, dynamic> json) {
  return _Prediction.fromJson(json);
}

/// @nodoc
mixin _$Prediction {
  String? get description => throw _privateConstructorUsedError;
  List<MatchedSubstring>? get matchedSubstrings =>
      throw _privateConstructorUsedError;
  String? get placeId => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  StructuredFormatting? get structuredFormatting =>
      throw _privateConstructorUsedError;
  List<Term>? get terms => throw _privateConstructorUsedError;
  List<String>? get types => throw _privateConstructorUsedError;

  /// Serializes this Prediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictionCopyWith<Prediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionCopyWith<$Res> {
  factory $PredictionCopyWith(
          Prediction value, $Res Function(Prediction) then) =
      _$PredictionCopyWithImpl<$Res, Prediction>;
  @useResult
  $Res call(
      {String? description,
      List<MatchedSubstring>? matchedSubstrings,
      String? placeId,
      String? reference,
      StructuredFormatting? structuredFormatting,
      List<Term>? terms,
      List<String>? types});

  $StructuredFormattingCopyWith<$Res>? get structuredFormatting;
}

/// @nodoc
class _$PredictionCopyWithImpl<$Res, $Val extends Prediction>
    implements $PredictionCopyWith<$Res> {
  _$PredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? matchedSubstrings = freezed,
    Object? placeId = freezed,
    Object? reference = freezed,
    Object? structuredFormatting = freezed,
    Object? terms = freezed,
    Object? types = freezed,
  }) {
    return _then(_value.copyWith(
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedSubstrings: freezed == matchedSubstrings
          ? _value.matchedSubstrings
          : matchedSubstrings // ignore: cast_nullable_to_non_nullable
              as List<MatchedSubstring>?,
      placeId: freezed == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String?,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      structuredFormatting: freezed == structuredFormatting
          ? _value.structuredFormatting
          : structuredFormatting // ignore: cast_nullable_to_non_nullable
              as StructuredFormatting?,
      terms: freezed == terms
          ? _value.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as List<Term>?,
      types: freezed == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  /// Create a copy of Prediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StructuredFormattingCopyWith<$Res>? get structuredFormatting {
    if (_value.structuredFormatting == null) {
      return null;
    }

    return $StructuredFormattingCopyWith<$Res>(_value.structuredFormatting!,
        (value) {
      return _then(_value.copyWith(structuredFormatting: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PredictionImplCopyWith<$Res>
    implements $PredictionCopyWith<$Res> {
  factory _$$PredictionImplCopyWith(
          _$PredictionImpl value, $Res Function(_$PredictionImpl) then) =
      __$$PredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? description,
      List<MatchedSubstring>? matchedSubstrings,
      String? placeId,
      String? reference,
      StructuredFormatting? structuredFormatting,
      List<Term>? terms,
      List<String>? types});

  @override
  $StructuredFormattingCopyWith<$Res>? get structuredFormatting;
}

/// @nodoc
class __$$PredictionImplCopyWithImpl<$Res>
    extends _$PredictionCopyWithImpl<$Res, _$PredictionImpl>
    implements _$$PredictionImplCopyWith<$Res> {
  __$$PredictionImplCopyWithImpl(
      _$PredictionImpl _value, $Res Function(_$PredictionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Prediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? matchedSubstrings = freezed,
    Object? placeId = freezed,
    Object? reference = freezed,
    Object? structuredFormatting = freezed,
    Object? terms = freezed,
    Object? types = freezed,
  }) {
    return _then(_$PredictionImpl(
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedSubstrings: freezed == matchedSubstrings
          ? _value._matchedSubstrings
          : matchedSubstrings // ignore: cast_nullable_to_non_nullable
              as List<MatchedSubstring>?,
      placeId: freezed == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String?,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      structuredFormatting: freezed == structuredFormatting
          ? _value.structuredFormatting
          : structuredFormatting // ignore: cast_nullable_to_non_nullable
              as StructuredFormatting?,
      terms: freezed == terms
          ? _value._terms
          : terms // ignore: cast_nullable_to_non_nullable
              as List<Term>?,
      types: freezed == types
          ? _value._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PredictionImpl implements _Prediction {
  const _$PredictionImpl(
      {this.description,
      final List<MatchedSubstring>? matchedSubstrings,
      this.placeId,
      this.reference,
      this.structuredFormatting,
      final List<Term>? terms,
      final List<String>? types})
      : _matchedSubstrings = matchedSubstrings,
        _terms = terms,
        _types = types;

  factory _$PredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictionImplFromJson(json);

  @override
  final String? description;
  final List<MatchedSubstring>? _matchedSubstrings;
  @override
  List<MatchedSubstring>? get matchedSubstrings {
    final value = _matchedSubstrings;
    if (value == null) return null;
    if (_matchedSubstrings is EqualUnmodifiableListView)
      return _matchedSubstrings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? placeId;
  @override
  final String? reference;
  @override
  final StructuredFormatting? structuredFormatting;
  final List<Term>? _terms;
  @override
  List<Term>? get terms {
    final value = _terms;
    if (value == null) return null;
    if (_terms is EqualUnmodifiableListView) return _terms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _types;
  @override
  List<String>? get types {
    final value = _types;
    if (value == null) return null;
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Prediction(description: $description, matchedSubstrings: $matchedSubstrings, placeId: $placeId, reference: $reference, structuredFormatting: $structuredFormatting, terms: $terms, types: $types)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._matchedSubstrings, _matchedSubstrings) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.structuredFormatting, structuredFormatting) ||
                other.structuredFormatting == structuredFormatting) &&
            const DeepCollectionEquality().equals(other._terms, _terms) &&
            const DeepCollectionEquality().equals(other._types, _types));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      description,
      const DeepCollectionEquality().hash(_matchedSubstrings),
      placeId,
      reference,
      structuredFormatting,
      const DeepCollectionEquality().hash(_terms),
      const DeepCollectionEquality().hash(_types));

  /// Create a copy of Prediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionImplCopyWith<_$PredictionImpl> get copyWith =>
      __$$PredictionImplCopyWithImpl<_$PredictionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictionImplToJson(
      this,
    );
  }
}

abstract class _Prediction implements Prediction {
  const factory _Prediction(
      {final String? description,
      final List<MatchedSubstring>? matchedSubstrings,
      final String? placeId,
      final String? reference,
      final StructuredFormatting? structuredFormatting,
      final List<Term>? terms,
      final List<String>? types}) = _$PredictionImpl;

  factory _Prediction.fromJson(Map<String, dynamic> json) =
      _$PredictionImpl.fromJson;

  @override
  String? get description;
  @override
  List<MatchedSubstring>? get matchedSubstrings;
  @override
  String? get placeId;
  @override
  String? get reference;
  @override
  StructuredFormatting? get structuredFormatting;
  @override
  List<Term>? get terms;
  @override
  List<String>? get types;

  /// Create a copy of Prediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredictionImplCopyWith<_$PredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchedSubstring _$MatchedSubstringFromJson(Map<String, dynamic> json) {
  return _MatchedSubstring.fromJson(json);
}

/// @nodoc
mixin _$MatchedSubstring {
  int? get length => throw _privateConstructorUsedError;
  int? get offset => throw _privateConstructorUsedError;

  /// Serializes this MatchedSubstring to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchedSubstring
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchedSubstringCopyWith<MatchedSubstring> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchedSubstringCopyWith<$Res> {
  factory $MatchedSubstringCopyWith(
          MatchedSubstring value, $Res Function(MatchedSubstring) then) =
      _$MatchedSubstringCopyWithImpl<$Res, MatchedSubstring>;
  @useResult
  $Res call({int? length, int? offset});
}

/// @nodoc
class _$MatchedSubstringCopyWithImpl<$Res, $Val extends MatchedSubstring>
    implements $MatchedSubstringCopyWith<$Res> {
  _$MatchedSubstringCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchedSubstring
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? length = freezed,
    Object? offset = freezed,
  }) {
    return _then(_value.copyWith(
      length: freezed == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int?,
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchedSubstringImplCopyWith<$Res>
    implements $MatchedSubstringCopyWith<$Res> {
  factory _$$MatchedSubstringImplCopyWith(_$MatchedSubstringImpl value,
          $Res Function(_$MatchedSubstringImpl) then) =
      __$$MatchedSubstringImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? length, int? offset});
}

/// @nodoc
class __$$MatchedSubstringImplCopyWithImpl<$Res>
    extends _$MatchedSubstringCopyWithImpl<$Res, _$MatchedSubstringImpl>
    implements _$$MatchedSubstringImplCopyWith<$Res> {
  __$$MatchedSubstringImplCopyWithImpl(_$MatchedSubstringImpl _value,
      $Res Function(_$MatchedSubstringImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchedSubstring
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? length = freezed,
    Object? offset = freezed,
  }) {
    return _then(_$MatchedSubstringImpl(
      length: freezed == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int?,
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchedSubstringImpl implements _MatchedSubstring {
  const _$MatchedSubstringImpl({this.length, this.offset});

  factory _$MatchedSubstringImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchedSubstringImplFromJson(json);

  @override
  final int? length;
  @override
  final int? offset;

  @override
  String toString() {
    return 'MatchedSubstring(length: $length, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchedSubstringImpl &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.offset, offset) || other.offset == offset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, length, offset);

  /// Create a copy of MatchedSubstring
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchedSubstringImplCopyWith<_$MatchedSubstringImpl> get copyWith =>
      __$$MatchedSubstringImplCopyWithImpl<_$MatchedSubstringImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchedSubstringImplToJson(
      this,
    );
  }
}

abstract class _MatchedSubstring implements MatchedSubstring {
  const factory _MatchedSubstring({final int? length, final int? offset}) =
      _$MatchedSubstringImpl;

  factory _MatchedSubstring.fromJson(Map<String, dynamic> json) =
      _$MatchedSubstringImpl.fromJson;

  @override
  int? get length;
  @override
  int? get offset;

  /// Create a copy of MatchedSubstring
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchedSubstringImplCopyWith<_$MatchedSubstringImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StructuredFormatting _$StructuredFormattingFromJson(Map<String, dynamic> json) {
  return _StructuredFormatting.fromJson(json);
}

/// @nodoc
mixin _$StructuredFormatting {
  String? get mainText => throw _privateConstructorUsedError;
  List<MatchedSubstring>? get mainTextMatchedSubstrings =>
      throw _privateConstructorUsedError;
  String? get secondaryText => throw _privateConstructorUsedError;

  /// Serializes this StructuredFormatting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StructuredFormatting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StructuredFormattingCopyWith<StructuredFormatting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StructuredFormattingCopyWith<$Res> {
  factory $StructuredFormattingCopyWith(StructuredFormatting value,
          $Res Function(StructuredFormatting) then) =
      _$StructuredFormattingCopyWithImpl<$Res, StructuredFormatting>;
  @useResult
  $Res call(
      {String? mainText,
      List<MatchedSubstring>? mainTextMatchedSubstrings,
      String? secondaryText});
}

/// @nodoc
class _$StructuredFormattingCopyWithImpl<$Res,
        $Val extends StructuredFormatting>
    implements $StructuredFormattingCopyWith<$Res> {
  _$StructuredFormattingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StructuredFormatting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mainText = freezed,
    Object? mainTextMatchedSubstrings = freezed,
    Object? secondaryText = freezed,
  }) {
    return _then(_value.copyWith(
      mainText: freezed == mainText
          ? _value.mainText
          : mainText // ignore: cast_nullable_to_non_nullable
              as String?,
      mainTextMatchedSubstrings: freezed == mainTextMatchedSubstrings
          ? _value.mainTextMatchedSubstrings
          : mainTextMatchedSubstrings // ignore: cast_nullable_to_non_nullable
              as List<MatchedSubstring>?,
      secondaryText: freezed == secondaryText
          ? _value.secondaryText
          : secondaryText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StructuredFormattingImplCopyWith<$Res>
    implements $StructuredFormattingCopyWith<$Res> {
  factory _$$StructuredFormattingImplCopyWith(_$StructuredFormattingImpl value,
          $Res Function(_$StructuredFormattingImpl) then) =
      __$$StructuredFormattingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? mainText,
      List<MatchedSubstring>? mainTextMatchedSubstrings,
      String? secondaryText});
}

/// @nodoc
class __$$StructuredFormattingImplCopyWithImpl<$Res>
    extends _$StructuredFormattingCopyWithImpl<$Res, _$StructuredFormattingImpl>
    implements _$$StructuredFormattingImplCopyWith<$Res> {
  __$$StructuredFormattingImplCopyWithImpl(_$StructuredFormattingImpl _value,
      $Res Function(_$StructuredFormattingImpl) _then)
      : super(_value, _then);

  /// Create a copy of StructuredFormatting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mainText = freezed,
    Object? mainTextMatchedSubstrings = freezed,
    Object? secondaryText = freezed,
  }) {
    return _then(_$StructuredFormattingImpl(
      mainText: freezed == mainText
          ? _value.mainText
          : mainText // ignore: cast_nullable_to_non_nullable
              as String?,
      mainTextMatchedSubstrings: freezed == mainTextMatchedSubstrings
          ? _value._mainTextMatchedSubstrings
          : mainTextMatchedSubstrings // ignore: cast_nullable_to_non_nullable
              as List<MatchedSubstring>?,
      secondaryText: freezed == secondaryText
          ? _value.secondaryText
          : secondaryText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StructuredFormattingImpl implements _StructuredFormatting {
  const _$StructuredFormattingImpl(
      {this.mainText,
      final List<MatchedSubstring>? mainTextMatchedSubstrings,
      this.secondaryText})
      : _mainTextMatchedSubstrings = mainTextMatchedSubstrings;

  factory _$StructuredFormattingImpl.fromJson(Map<String, dynamic> json) =>
      _$$StructuredFormattingImplFromJson(json);

  @override
  final String? mainText;
  final List<MatchedSubstring>? _mainTextMatchedSubstrings;
  @override
  List<MatchedSubstring>? get mainTextMatchedSubstrings {
    final value = _mainTextMatchedSubstrings;
    if (value == null) return null;
    if (_mainTextMatchedSubstrings is EqualUnmodifiableListView)
      return _mainTextMatchedSubstrings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? secondaryText;

  @override
  String toString() {
    return 'StructuredFormatting(mainText: $mainText, mainTextMatchedSubstrings: $mainTextMatchedSubstrings, secondaryText: $secondaryText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StructuredFormattingImpl &&
            (identical(other.mainText, mainText) ||
                other.mainText == mainText) &&
            const DeepCollectionEquality().equals(
                other._mainTextMatchedSubstrings, _mainTextMatchedSubstrings) &&
            (identical(other.secondaryText, secondaryText) ||
                other.secondaryText == secondaryText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mainText,
      const DeepCollectionEquality().hash(_mainTextMatchedSubstrings),
      secondaryText);

  /// Create a copy of StructuredFormatting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StructuredFormattingImplCopyWith<_$StructuredFormattingImpl>
      get copyWith =>
          __$$StructuredFormattingImplCopyWithImpl<_$StructuredFormattingImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StructuredFormattingImplToJson(
      this,
    );
  }
}

abstract class _StructuredFormatting implements StructuredFormatting {
  const factory _StructuredFormatting(
      {final String? mainText,
      final List<MatchedSubstring>? mainTextMatchedSubstrings,
      final String? secondaryText}) = _$StructuredFormattingImpl;

  factory _StructuredFormatting.fromJson(Map<String, dynamic> json) =
      _$StructuredFormattingImpl.fromJson;

  @override
  String? get mainText;
  @override
  List<MatchedSubstring>? get mainTextMatchedSubstrings;
  @override
  String? get secondaryText;

  /// Create a copy of StructuredFormatting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StructuredFormattingImplCopyWith<_$StructuredFormattingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

Term _$TermFromJson(Map<String, dynamic> json) {
  return _Term.fromJson(json);
}

/// @nodoc
mixin _$Term {
  int? get offset => throw _privateConstructorUsedError;
  String? get value => throw _privateConstructorUsedError;

  /// Serializes this Term to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Term
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TermCopyWith<Term> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TermCopyWith<$Res> {
  factory $TermCopyWith(Term value, $Res Function(Term) then) =
      _$TermCopyWithImpl<$Res, Term>;
  @useResult
  $Res call({int? offset, String? value});
}

/// @nodoc
class _$TermCopyWithImpl<$Res, $Val extends Term>
    implements $TermCopyWith<$Res> {
  _$TermCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Term
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = freezed,
    Object? value = freezed,
  }) {
    return _then(_value.copyWith(
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TermImplCopyWith<$Res> implements $TermCopyWith<$Res> {
  factory _$$TermImplCopyWith(
          _$TermImpl value, $Res Function(_$TermImpl) then) =
      __$$TermImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? offset, String? value});
}

/// @nodoc
class __$$TermImplCopyWithImpl<$Res>
    extends _$TermCopyWithImpl<$Res, _$TermImpl>
    implements _$$TermImplCopyWith<$Res> {
  __$$TermImplCopyWithImpl(_$TermImpl _value, $Res Function(_$TermImpl) _then)
      : super(_value, _then);

  /// Create a copy of Term
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = freezed,
    Object? value = freezed,
  }) {
    return _then(_$TermImpl(
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TermImpl implements _Term {
  const _$TermImpl({this.offset, this.value});

  factory _$TermImpl.fromJson(Map<String, dynamic> json) =>
      _$$TermImplFromJson(json);

  @override
  final int? offset;
  @override
  final String? value;

  @override
  String toString() {
    return 'Term(offset: $offset, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TermImpl &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, offset, value);

  /// Create a copy of Term
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TermImplCopyWith<_$TermImpl> get copyWith =>
      __$$TermImplCopyWithImpl<_$TermImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TermImplToJson(
      this,
    );
  }
}

abstract class _Term implements Term {
  const factory _Term({final int? offset, final String? value}) = _$TermImpl;

  factory _Term.fromJson(Map<String, dynamic> json) = _$TermImpl.fromJson;

  @override
  int? get offset;
  @override
  String? get value;

  /// Create a copy of Term
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TermImplCopyWith<_$TermImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
