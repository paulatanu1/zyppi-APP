import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/report_error.dart';

/// Cloud Functions live in Mumbai (functions/src/shared/firebase.ts).
const functionsRegion = 'asia-south1';

FirebaseFunctions zyppiFunctions() =>
    FirebaseFunctions.instanceFor(region: functionsRegion);

/// App Check: every callable sends a token proving the call comes from
/// this app (functions/src/shared/hardening.ts). Release builds use Play
/// Integrity; debug builds use the debug provider, which logs a token to
/// register under App Check → Apps → Manage debug tokens. Never blocks
/// startup: without a token the functions decide (monitor or enforce).
Future<void> activateAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: kReleaseMode
          ? const AppleAppAttestWithDeviceCheckFallbackProvider()
          : const AppleDebugProvider(),
    );
  } catch (e, stack) {
    // Still never blocks startup, but shows on the Crashlytics dashboard so
    // a broken Play Integrity setup is seen before enforcement is turned on.
    reportNonFatal(e, stack, reason: 'App Check activation failed');
  }
}

/// Points Auth, Firestore and Functions at the local emulators when
/// `USE_FIREBASE_EMULATOR=true` (debug builds only). Call once, right
/// after Firebase.initializeApp().
Future<void> configureFirebase() async {
  if (!Env.useFirebaseEmulator || kReleaseMode) {
    await activateAppCheck();
    return;
  }

  final host = Env.firebaseEmulatorHost.isNotEmpty
      ? Env.firebaseEmulatorHost
      : (Platform.isAndroid ? '10.0.2.2' : 'localhost');

  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  zyppiFunctions().useFunctionsEmulator(host, 5001);
}
