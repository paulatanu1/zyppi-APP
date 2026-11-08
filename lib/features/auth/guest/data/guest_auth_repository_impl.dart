import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/auth/guest/domain/guest_auth_repository.dart';

/// Firebase anonymous sign-in. The guest is a real (anonymous) Firebase
/// user, so cart / address / order rules and the Cloud Functions work
/// unchanged. Needs the Anonymous provider enabled in the console.
class FirebaseGuestAuthRepository implements GuestAuthRepository {
  final FirebaseAuth auth;

  FirebaseGuestAuthRepository(this.auth);

  @override
  Future<String?> signIn() async {
    final result = await auth.signInAnonymously();
    return result.user?.uid;
  }
}

final guestAuthRepositoryProvider = Provider<GuestAuthRepository>(
  (ref) => FirebaseGuestAuthRepository(FirebaseAuth.instance),
);
