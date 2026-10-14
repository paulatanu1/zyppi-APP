import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_prediction.freezed.dart';
part 'place_prediction.g.dart';

@freezed
abstract class PlacePrediction with _$PlacePrediction {
  const factory PlacePrediction({
    List<Prediction>? predictions,
    String? status,
  }) = _PlacePrediction;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) =>
      _$PlacePredictionFromJson(json);
}

@freezed
abstract class Prediction with _$Prediction {
  const factory Prediction({
    String? description,
    List<MatchedSubstring>? matchedSubstrings,
    String? placeId,
    String? reference,
    StructuredFormatting? structuredFormatting,
    List<Term>? terms,
    List<String>? types,
  }) = _Prediction;

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
}

@freezed
abstract class MatchedSubstring with _$MatchedSubstring {
  const factory MatchedSubstring({int? length, int? offset}) =
      _MatchedSubstring;

  factory MatchedSubstring.fromJson(Map<String, dynamic> json) =>
      _$MatchedSubstringFromJson(json);
}

@freezed
abstract class StructuredFormatting with _$StructuredFormatting {
  const factory StructuredFormatting({
    String? mainText,
    List<MatchedSubstring>? mainTextMatchedSubstrings,
    String? secondaryText,
  }) = _StructuredFormatting;

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) =>
      _$StructuredFormattingFromJson(json);
}

@freezed
abstract class Term with _$Term {
  const factory Term({int? offset, String? value}) = _Term;

  factory Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);
}
