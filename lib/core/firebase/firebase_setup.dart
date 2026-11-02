import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:zippy/core/config/env.dart';

/// Cloud Functions live in Mumbai (functions/src/shared/firebase.ts).
const functionsRegion = 'asia-south1';

FirebaseFunctions zyppiFunctions() =>
    FirebaseFunctions.instanceFor(region: functionsRegion);

/// Points Auth, Firestore and Functions at the local emulators when
/// `USE_FIREBASE_EMULATOR=true` (debug builds only). Call once, right
/// after Firebase.initializeApp().
Future<void> configureFirebase() async {
  if (!Env.useFirebaseEmulator || kReleaseMode) return;

  final host = Env.firebaseEmulatorHost.isNotEmpty
      ? Env.firebaseEmulatorHost
      : (Platform.isAndroid ? '10.0.2.2' : 'localhost');

  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  zyppiFunctions().useFunctionsEmulator(host, 5001);
}
