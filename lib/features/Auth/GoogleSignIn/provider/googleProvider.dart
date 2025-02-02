import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../application/googleState.dart';

class GoogleLogin extends StateNotifier<GoogleState> {
  GoogleLogin() : super(GoogleState.initial()) {}

  generateGoogleToken(BuildContext context) async {
    state = state.copyWith(loading: true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      state = state.copyWith(
          loading: false,
          googleAccessToken: googleAuth.accessToken,
          googleIdToken: googleAuth.idToken);

      context.go('/navBar');

      if (kDebugMode) {
        // log('Google Full Response: ${googleAuth.}');
        log('Google Auth: ${googleUser}');
        log('Google Response: ${state.hashCode}');
        log('Google Access Token: ${state.googleAccessToken}');
        log('Google ID Token: ${state.googleIdToken}');
      }

      return await FirebaseAuth.instance.signInWithCredential(credential);
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
        (ref) => GoogleLogin());
