/// Email + password accounts (Firebase Auth). Every call returns the
/// signed-in user's uid, or throws [EmailAuthFailure].
abstract class EmailAuthRepository {
  Future<String> signIn({required String email, required String password});

  /// Creates the account and sets its display name.
  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sends Firebase's "reset your password" email. Succeeds whether or not
  /// an account exists, so the form can't be used to look up emails.
  Future<void> sendPasswordReset(String email);
}

/// Why an email sign-in failed, as a translation key to show.
class EmailAuthFailure implements Exception {
  const EmailAuthFailure(this.messageKey);

  /// e.g. `authWrongCredentials`; shown with `.tr()`.
  final String messageKey;

  /// Maps a Firebase Auth error code to a message key.
  factory EmailAuthFailure.fromCode(String code) =>
      EmailAuthFailure(switch (code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'INVALID_LOGIN_CREDENTIALS' => 'authWrongCredentials',
        'email-already-in-use' ||
        'credential-already-in-use' ||
        'account-exists-with-different-credential' => 'authEmailInUse',
        'weak-password' => 'authWeakPassword',
        'invalid-email' => 'invalidEmail',
        'user-disabled' => 'errorAccountBlocked',
        'too-many-requests' => 'errorTooManyTries',
        'network-request-failed' => 'authNetwork',
        'operation-not-allowed' => 'authEmailOff',
        _ => 'somethingWentWrong',
      });

  @override
  String toString() => 'EmailAuthFailure($messageKey)';
}
