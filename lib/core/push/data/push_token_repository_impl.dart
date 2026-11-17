import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';
import 'package:zippy/core/push/domain/push_token_repository.dart';

/// The mock flavor has no profile document to write a token to, and no
/// Cloud Function will ever read it.
class MockPushTokenRepository implements PushTokenRepository {
  @override
  Future<void> registerToken(String token, {String? languageCode}) async {}

  @override
  Future<void> clearToken() async {}

  @override
  Future<void> setLanguage(String languageCode) async {}

  @override
  Future<void> recordCampaignOpen(String campaignId) async {}
}

/// Stores the device's FCM token and language on `users/{uid}` for the
/// order-update and offer pushes (functions/src/push.ts, notifications/).
/// Every signed-in phone is kept (`pushTokens`, via registerPushToken), so
/// pushes reach all of them; `fcmToken` is still written for backends
/// that predate it.
class FirebasePushTokenRepository implements PushTokenRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  /// This device's FCM token (null when FCM is unavailable).
  final Future<String?> Function() currentToken;

  FirebasePushTokenRepository(
    this.auth,
    this.firestore,
    this.functions, {
    Future<String?> Function()? currentToken,
  }) : currentToken = currentToken ?? _fcmToken;

  static Future<String?> _fcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(Map<String, Object?> values) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    await firestore
        .collection('users')
        .doc(uid)
        .set(values, SetOptions(merge: true));
  }

  @override
  Future<void> registerToken(String token, {String? languageCode}) async {
    if (auth.currentUser == null) return;
    await _write({'fcmToken': token, 'lang': ?languageCode});
    try {
      await functions.httpsCallable('registerPushToken').call<void>({
        'token': token,
        'lang': ?languageCode,
      });
    } catch (_) {
      // Older backend, or offline: the single fcmToken above still works.
    }
  }

  @override
  Future<void> clearToken() async {
    if (auth.currentUser == null) return;
    final token = await currentToken();
    if (token != null) {
      try {
        await functions.httpsCallable('unregisterPushToken').call<void>({
          'token': token,
        });
      } catch (_) {
        // Best effort; the token is also dropped once FCM reports it dead.
      }
    }
    await _write({'fcmToken': null});
  }

  @override
  Future<void> setLanguage(String languageCode) =>
      _write({'lang': languageCode});

  @override
  Future<void> recordCampaignOpen(String campaignId) async {
    if (auth.currentUser == null) return;
    await functions.httpsCallable('trackCampaignOpen').call<void>({
      'campaignId': campaignId,
    });
  }
}

final pushTokenRepositoryProvider = Provider<PushTokenRepository>(
  (ref) => Env.isMockDataSource
      ? MockPushTokenRepository()
      : FirebasePushTokenRepository(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
          zyppiFunctions(),
        ),
);
