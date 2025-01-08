import 'package:freezed_annotation/freezed_annotation.dart';

part 'googleState.freezed.dart';

@freezed
class GoogleState with _$GoogleState {
  factory GoogleState({
    bool? loading,
    String? googleAccessToken, 
    String? googleIdToken}) =
      _GoogleState;

  factory GoogleState.initial() =>
      GoogleState(loading: false, googleAccessToken: '', googleIdToken: '');
}
