import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Sends a handled error to Crashlytics as a non-fatal, so failures the
/// UI recovers from (a stream that errors, App Check that won't start)
/// still show up on the dashboard. Prints instead when Firebase isn't set
/// up (tests, the mock flavor).
void reportNonFatal(Object error, StackTrace? stack, {required String reason}) {
  if (kDebugMode || Firebase.apps.isEmpty) {
    debugPrint('Non-fatal ($reason): $error');
    if (Firebase.apps.isEmpty) return;
  }
  FirebaseCrashlytics.instance
      .recordError(error, stack, reason: reason, fatal: false)
      .ignore();
}
