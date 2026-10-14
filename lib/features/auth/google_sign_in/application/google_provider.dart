import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_state.dart';

class GoogleLogin extends StateNotifier<GoogleState> {
  GoogleLogin() : super(GoogleState.initial());

  bool _initialized = false;

  Future<void> generateGoogleToken(BuildContext context) async {
    state = state.copyWith(loading: true);

    try {
      final googleSignIn = GoogleSignIn.instance;

      if (!_initialized) {
        await googleSignIn.initialize();
        _initialized = true;
      }

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      state = state.copyWith(
        loading: false,
        googleAccessToken: null,
        googleIdToken: googleAuth.idToken,
      );

      if (!context.mounted) return;
      context.go('/navBar');

      if (kDebugMode) {
        // log('Google Full Response: ${googleAuth.}');
        log('Google Auth: $googleUser');
        log('Google Response: ${state.hashCode}');
        log('Google Access Token: ${state.googleAccessToken}');
        log('Google ID Token: ${state.googleIdToken}');
      }

      await FirebaseAuth.instance.signInWithCredential(credential);
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
      (ref) => GoogleLogin(),
    );
