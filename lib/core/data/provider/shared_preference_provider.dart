import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/data_source/key_names.dart';
import 'package:zippy/core/utils/log.dart';

import '../application/shared_preference_state.dart';

/// Opened once in bootstrap() and provided via this override, same
/// pattern as core/cart's cartBoxProvider.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with an awaited '
    'SharedPreferences.getInstance() in bootstrap()',
  ),
);

class SharedPreferenceProvider extends StateNotifier<SharedPreferenceState> {
  final Ref ref;

  SharedPreferenceProvider(this.ref) : super(SharedPreferenceState.initial()) {
    getLocalStorage();
  }

  Future<void> getLocalStorage() async {
    state = state.copyWith(
      authToken: ref.read(sharedPreferencesProvider).getString(KeyNames.token),
    );

    // Never log the token itself — it's a live bearer credential.
    AppLog.showLog(
      tag: 'Stored Token',
      message: state.authToken == null ? 'none' : 'present',
    );
  }

  Future<void> setLocalStorage({required String authToken}) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(KeyNames.token, authToken);

    state = state.copyWith(authToken: authToken);

    AppLog.showLog(tag: 'Saved Token', message: 'present');
  }

  Future<void> logOut() async {
    await ref.read(sharedPreferencesProvider).remove(KeyNames.token);

    state = state.copyWith(authToken: null);
  }
}

final sharedPreferenceProvider =
    StateNotifierProvider.autoDispose<
      SharedPreferenceProvider,
      SharedPreferenceState
    >((ref) => SharedPreferenceProvider(ref));
