import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';

import 'google_state.dart';

class GoogleLogin extends StateNotifier<GoogleState> {
  final GoogleAuthRepository repository;
  final Ref ref;

  GoogleLogin(this.repository, this.ref) : super(GoogleState.initial());

  Future<void> generateGoogleToken(BuildContext context) async {
    state = state.copyWith(loading: true);

    try {
      final accessToken = await repository.signIn();

      state = state.copyWith(loading: false);

      if (accessToken == null) {
        showConnectionInterrupted();
        return;
      }

      await ref
          .read(sharedPreferenceProvider.notifier)
          .setLocalStorage(authToken: accessToken);
      // The router's redirect (watching sharedPreferenceProvider) takes
      // it from here — no manual navigation needed.
    } catch (error) {
      state = state.copyWith(loading: false);

      showError(error);
    }
  }
}

final googleProvider =
    StateNotifierProvider.autoDispose<GoogleLogin, GoogleState>(
      (ref) => GoogleLogin(ref.read(googleAuthRepositoryProvider), ref),
    );
