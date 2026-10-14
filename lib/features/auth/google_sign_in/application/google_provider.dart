import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';

import 'google_state.dart';

class GoogleLogin extends StateNotifier<GoogleState> {
  final GoogleAuthRepository repository;

  GoogleLogin(this.repository) : super(GoogleState.initial());

  Future<void> generateGoogleToken(BuildContext context) async {
    state = state.copyWith(loading: true);

    try {
      final idToken = await repository.signIn();

      state = state.copyWith(
        loading: false,
        googleAccessToken: null,
        googleIdToken: idToken,
      );

      if (!context.mounted) return;
      context.go('/navBar');

      if (kDebugMode) {
        log('Google ID Token: ${state.googleIdToken}');
      }
    } catch (error) {
      state = state.copyWith(loading: false);

      if (kDebugMode) {
        log('Google Error: ${error.toString()}');
      }
    }
  }
}

final googleProvider =
    StateNotifierProvider.autoDispose<GoogleLogin, GoogleState>(
      (ref) => GoogleLogin(ref.read(googleAuthRepositoryProvider)),
    );
