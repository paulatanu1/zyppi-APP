import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_preference_state.freezed.dart';

@freezed
abstract class SharedPreferenceState with _$SharedPreferenceState {
  factory SharedPreferenceState({String? authToken}) = _SharedPreferenceState;

  factory SharedPreferenceState.initial() =>
      SharedPreferenceState(authToken: '');
}
