// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlacePrediction _$PlacePredictionFromJson(Map<String, dynamic> json) =>
    _PlacePrediction(
      predictions: (json['predictions'] as List<dynamic>?)
          ?.map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$PlacePredictionToJson(_PlacePrediction instance) =>
    <String, dynamic>{
      'predictions': instance.predictions,
      'status': instance.status,
    };

_Prediction _$PredictionFromJson(Map<String, dynamic> json) => _Prediction(
  description: json['description'] as String?,
  matchedSubstrings: (json['matchedSubstrings'] as List<dynamic>?)
      ?.map((e) => MatchedSubstring.fromJson(e as Map<String, dynamic>))
      .toList(),
  placeId: json['placeId'] as String?,
  reference: json['reference'] as String?,
  structuredFormatting: json['structuredFormatting'] == null
      ? null
      : StructuredFormatting.fromJson(
          json['structuredFormatting'] as Map<String, dynamic>,
        ),
  terms: (json['terms'] as List<dynamic>?)
      ?.map((e) => Term.fromJson(e as Map<String, dynamic>))
      .toList(),
  types: (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$PredictionToJson(_Prediction instance) =>
    <String, dynamic>{
      'description': instance.description,
      'matchedSubstrings': instance.matchedSubstrings,
      'placeId': instance.placeId,
      'reference': instance.reference,
      'structuredFormatting': instance.structuredFormatting,
      'terms': instance.terms,
      'types': instance.types,
    };

_MatchedSubstring _$MatchedSubstringFromJson(Map<String, dynamic> json) =>
    _MatchedSubstring(
      length: (json['length'] as num?)?.toInt(),
      offset: (json['offset'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MatchedSubstringToJson(_MatchedSubstring instance) =>
    <String, dynamic>{'length': instance.length, 'offset': instance.offset};

_StructuredFormatting _$StructuredFormattingFromJson(
  Map<String, dynamic> json,
) => _StructuredFormatting(
  mainText: json['mainText'] as String?,
  mainTextMatchedSubstrings:
      (json['mainTextMatchedSubstrings'] as List<dynamic>?)
          ?.map((e) => MatchedSubstring.fromJson(e as Map<String, dynamic>))
          .toList(),
  secondaryText: json['secondaryText'] as String?,
);

Map<String, dynamic> _$StructuredFormattingToJson(
  _StructuredFormatting instance,
) => <String, dynamic>{
  'mainText': instance.mainText,
  'mainTextMatchedSubstrings': instance.mainTextMatchedSubstrings,
  'secondaryText': instance.secondaryText,
};

_Term _$TermFromJson(Map<String, dynamic> json) => _Term(
  offset: (json['offset'] as num?)?.toInt(),
  value: json['value'] as String?,
);

Map<String, dynamic> _$TermToJson(_Term instance) => <String, dynamic>{
  'offset': instance.offset,
  'value': instance.value,
};
