import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/push/data/push_token_repository_impl.dart';
import 'package:zippy/core/push/push_notification_service.dart';

/// Where to go once Firebase has signed someone in.
enum SignInResult {
  /// Signed in: the router's redirect takes them to Home.
  signedIn,

  /// Their profile has no mobile number yet (a first Google sign-in, or
  /// an account from before numbers were required): show "Add mobile
  /// number" first. They count as signed in only after that.
  needsPhone,
}

/// The last step of every sign-in (Google, email, sign-up, adding the
/// number). Not autoDispose: the redirect that follows a sign-in disposes
/// the screen's providers, and this one must outlive them.
class AuthSession {
  AuthSession(this._ref);

  final Ref _ref;

  Future<SignInResult> complete(String uid) async {
    final profile = await _ref.read(profileRepositoryProvider).fetchProfile();
    if ((profile.phone ?? '').trim().isEmpty) return SignInResult.needsPhone;
    await markSignedIn(uid);
    return SignInResult.signedIn;
  }

  /// Saves the local "signed in" marker (the router watches it) and
  /// registers this phone for push notifications.
  Future<void> markSignedIn(String uid) async {
    final pushTokens = _ref.read(pushTokenRepositoryProvider);
    await _ref
        .read(sharedPreferenceProvider.notifier)
        .setLocalStorage(authToken: uid);
    PushNotificationService.registerTokenAfterLogin(pushTokens);
  }
}

final authSessionProvider = Provider<AuthSession>(AuthSession.new);

/// Who Firebase has signed in right now (null when nobody is): shown on
/// "One last step" and used to mark the session signed in after it.
typedef CurrentAccount = ({String uid, String name, String email});

final currentAccountProvider = Provider.autoDispose<CurrentAccount?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return (uid: user.uid, name: user.displayName ?? '', email: user.email ?? '');
});
