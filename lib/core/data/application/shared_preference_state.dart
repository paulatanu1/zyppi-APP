import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preference_state.freezed.dart';

@freezed
abstract class SharedPreferenceState with _$SharedPreferenceState {
  factory SharedPreferenceState({
    String? authToken,
    SharedPreferences? sharedPreference,
  }) = _SharedPreferenceState;

  factory SharedPreferenceState.initial() =>
      SharedPreferenceState(authToken: '');
}
