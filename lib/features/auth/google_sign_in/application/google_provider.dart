import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/session/auth_session.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';

import 'google_state.dart';

class GoogleLogin extends StateNotifier<GoogleState> {
  final GoogleAuthRepository repository;
  final Ref ref;

  GoogleLogin(this.repository, this.ref) : super(GoogleState.initial());

  /// Signs in with Google. Returns what to show next, or null when it
  /// didn't happen (cancelled, or an error that was already shown).
  Future<SignInResult?> signIn() async {
    state = state.copyWith(loading: true);
    // Read up front: the redirect that follows a sign-in disposes this
    // provider, and its ref with it.
    final session = ref.read(authSessionProvider);

    try {
      final uid = await repository.signIn();
      if (uid == null) {
        if (mounted) state = state.copyWith(loading: false);
        showConnectionInterrupted();
        return null;
      }
      final result = await session.complete(uid);
      if (mounted) state = state.copyWith(loading: false);
      return result;
    } on GoogleSignInCancelled {
      if (mounted) state = state.copyWith(loading: false);
      return null;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(loading: false);
      showError(error);
      return null;
    }
  }
}

final googleProvider =
    StateNotifierProvider.autoDispose<GoogleLogin, GoogleState>(
      (ref) => GoogleLogin(ref.read(googleAuthRepositoryProvider), ref),
    );
