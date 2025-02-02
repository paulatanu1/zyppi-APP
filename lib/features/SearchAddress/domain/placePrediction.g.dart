// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placePrediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlacePredictionImpl _$$PlacePredictionImplFromJson(
        Map<String, dynamic> json) =>
    _$PlacePredictionImpl(
      predictions: (json['predictions'] as List<dynamic>?)
          ?.map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$PlacePredictionImplToJson(
        _$PlacePredictionImpl instance) =>
    <String, dynamic>{
      'predictions': instance.predictions,
      'status': instance.status,
    };

_$PredictionImpl _$$PredictionImplFromJson(Map<String, dynamic> json) =>
    _$PredictionImpl(
      description: json['description'] as String?,
      matchedSubstrings: (json['matchedSubstrings'] as List<dynamic>?)
          ?.map((e) => MatchedSubstring.fromJson(e as Map<String, dynamic>))
          .toList(),
      placeId: json['placeId'] as String?,
      reference: json['reference'] as String?,
      structuredFormatting: json['structuredFormatting'] == null
          ? null
          : StructuredFormatting.fromJson(
              json['structuredFormatting'] as Map<String, dynamic>),
      terms: (json['terms'] as List<dynamic>?)
          ?.map((e) => Term.fromJson(e as Map<String, dynamic>))
          .toList(),
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$PredictionImplToJson(_$PredictionImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'matchedSubstrings': instance.matchedSubstrings,
      'placeId': instance.placeId,
      'reference': instance.reference,
      'structuredFormatting': instance.structuredFormatting,
      'terms': instance.terms,
      'types': instance.types,
    };

_$MatchedSubstringImpl _$$MatchedSubstringImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchedSubstringImpl(
      length: (json['length'] as num?)?.toInt(),
      offset: (json['offset'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$MatchedSubstringImplToJson(
        _$MatchedSubstringImpl instance) =>
    <String, dynamic>{
      'length': instance.length,
      'offset': instance.offset,
    };

_$StructuredFormattingImpl _$$StructuredFormattingImplFromJson(
        Map<String, dynamic> json) =>
    _$StructuredFormattingImpl(
      mainText: json['mainText'] as String?,
      mainTextMatchedSubstrings:
          (json['mainTextMatchedSubstrings'] as List<dynamic>?)
              ?.map((e) => MatchedSubstring.fromJson(e as Map<String, dynamic>))
              .toList(),
      secondaryText: json['secondaryText'] as String?,
    );

Map<String, dynamic> _$$StructuredFormattingImplToJson(
        _$StructuredFormattingImpl instance) =>
    <String, dynamic>{
      'mainText': instance.mainText,
      'mainTextMatchedSubstrings': instance.mainTextMatchedSubstrings,
      'secondaryText': instance.secondaryText,
    };

_$TermImpl _$$TermImplFromJson(Map<String, dynamic> json) => _$TermImpl(
      offset: (json['offset'] as num?)?.toInt(),
      value: json['value'] as String?,
    );

Map<String, dynamic> _$$TermImplToJson(_$TermImpl instance) =>
    <String, dynamic>{
      'offset': instance.offset,
      'value': instance.value,
    };
