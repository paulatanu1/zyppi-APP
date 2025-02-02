import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/dataSource/keyNames.dart';
import 'package:zippy/core/utils/log.dart';
import '../application/sharedPreferenceState.dart';

class SharedPreferenceProvider extends StateNotifier<SharedPreferenceState> {
  SharedPreferenceProvider() : super(SharedPreferenceState.initial()) {
    getLocalStorage();
  }

  Future<void> getLocalStorage() async {
    state = state.copyWith(
        authToken: await state.sharedPreference?.getString(KeyNames.token));

    AppLog.showLog(tag: 'Stored Token', message: state.authToken);
  }

  Future<void> setLocalStorage({required String authToken}) async {
    await state.sharedPreference?.setString(KeyNames.token, authToken);

    state = state.copyWith(authToken: authToken);

    AppLog.showLog(tag: 'Saved Token', message: state.authToken);
  }
}

final sharedPreferenceProvider = StateNotifierProvider.autoDispose<
    SharedPreferenceProvider,
    SharedPreferenceState>((ref) => SharedPreferenceProvider());
