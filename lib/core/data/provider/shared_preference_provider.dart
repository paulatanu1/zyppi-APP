import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/data_source/key_names.dart';
import 'package:zippy/core/utils/log.dart';

import '../application/shared_preference_state.dart';

class SharedPreferenceProvider extends StateNotifier<SharedPreferenceState> {
  SharedPreferenceProvider() : super(SharedPreferenceState.initial()) {
    getLocalStorage();
  }

  Future<void> getLocalStorage() async {
    state = state.copyWith(
      authToken: state.sharedPreference?.getString(KeyNames.token),
    );

    AppLog.showLog(tag: 'Stored Token', message: state.authToken);
  }

  Future<void> setLocalStorage({required String authToken}) async {
    await state.sharedPreference?.setString(KeyNames.token, authToken);

    state = state.copyWith(authToken: authToken);

    AppLog.showLog(tag: 'Saved Token', message: state.authToken);
  }

  Future<void> logOut() async {
    await state.sharedPreference?.remove(KeyNames.token);

    state = state.copyWith(authToken: null);
  }
}

final sharedPreferenceProvider =
    StateNotifierProvider.autoDispose<
      SharedPreferenceProvider,
      SharedPreferenceState
    >((ref) => SharedPreferenceProvider());
