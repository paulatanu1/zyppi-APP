import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/auth/email/domain/email_auth_repository.dart';

class FirebaseEmailAuthRepository implements EmailAuthRepository {
  FirebaseEmailAuthRepository(this.auth);

  final FirebaseAuth auth;

  @override
  Future<String> signIn({required String email, required String password}) =>
      _guard(() async {
        final result = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        return result.user!.uid;
      });

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
  }) => _guard(() async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = result.user!;
    await user.updateDisplayName(fullName.trim());
    return user.uid;
  });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Don't reveal whether an account exists.
      if (e.code != 'user-not-found') rethrow;
    }
  });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseAuthException catch (e) {
      throw EmailAuthFailure.fromCode(e.code);
    }
  }
}

final emailAuthRepositoryProvider = Provider<EmailAuthRepository>(
  (ref) => FirebaseEmailAuthRepository(FirebaseAuth.instance),
);
