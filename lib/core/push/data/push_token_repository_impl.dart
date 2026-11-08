import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/push/domain/push_token_repository.dart';

/// The mock flavor has no profile document to write a token to, and no
/// Cloud Function will ever read it.
class MockPushTokenRepository implements PushTokenRepository {
  @override
  Future<void> registerToken(String token) async {}

  @override
  Future<void> clearToken() async {}
}

/// Stores the device's FCM token on `users/{uid}` for the
/// onOrderEventCreated Cloud Function.
class FirebasePushTokenRepository implements PushTokenRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebasePushTokenRepository(this.auth, this.firestore);

  Future<void> _write(String? token) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    await firestore.collection('users').doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> registerToken(String token) => _write(token);

  @override
  Future<void> clearToken() => _write(null);
}

final pushTokenRepositoryProvider = Provider<PushTokenRepository>(
  (ref) => Env.isMockDataSource
      ? MockPushTokenRepository()
      : FirebasePushTokenRepository(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
        ),
);
