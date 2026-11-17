import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';
import 'package:zippy/core/legal/domain/legal_repository.dart';

/// legalDocs/{type} (+ versions/{v}) are public; acceptance goes through
/// the acceptLegal callable, which stores the consent with the text's
/// fingerprint, time and device.
class FirebaseLegalRepository implements LegalRepository {
  FirebaseLegalRepository(this.db, this.functions);

  final FirebaseFirestore db;
  final FirebaseFunctions functions;

  @override
  Future<List<PendingLegalDoc>> pending() async {
    final res = await functions
        .httpsCallable('legalStatus')
        .call<Map<String, dynamic>>({'audience': 'customer'});
    final list = (res.data['pending'] as List?) ?? const [];
    return [
      for (final raw in list)
        if (raw is Map)
          PendingLegalDoc(
            type: raw['type'] as String,
            version: (raw['version'] as num).toInt(),
            title: (raw['title'] as String?) ?? raw['type'] as String,
            sha256: (raw['sha256'] as String?) ?? '',
          ),
    ];
  }

  @override
  Future<LegalDocText?> fetchText(String type, String languageCode) async {
    final head = await db.collection('legalDocs').doc(type).get();
    final version = (head.data()?['currentVersion'] as num?)?.toInt();
    if (version == null) return null;
    final v = await head.reference.collection('versions').doc('$version').get();
    final data = v.data();
    if (data == null) return null;
    final body = Map<String, dynamic>.from(data['body'] as Map? ?? const {});
    return LegalDocText(
      type: type,
      version: version,
      title: (data['title'] as String?) ?? type,
      body: (body[languageCode] ?? body['en'] ?? '') as String,
    );
  }

  @override
  Future<void> accept(List<PendingLegalDoc> docs) async {
    if (docs.isEmpty) return;
    final info = await PackageInfo.fromPlatform();
    await functions.httpsCallable('acceptLegal').call<void>({
      'audience': 'customer',
      'items': [
        for (final d in docs)
          {'type': d.type, 'version': d.version, 'sha256': d.sha256},
      ],
      'appId': info.packageName,
      'appVersion': '${info.version}+${info.buildNumber}',
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
    });
  }
}

/// Mock flavor: nothing to accept, and the in-app reader explains that
/// the documents come from the server.
class MockLegalRepository implements LegalRepository {
  @override
  Future<List<PendingLegalDoc>> pending() async => const [];

  @override
  Future<LegalDocText?> fetchText(String type, String languageCode) async =>
      null;

  @override
  Future<void> accept(List<PendingLegalDoc> docs) async {}
}

final legalRepositoryProvider = Provider<LegalRepository>(
  (ref) => Env.isMockDataSource
      ? MockLegalRepository()
      : FirebaseLegalRepository(FirebaseFirestore.instance, zyppiFunctions()),
);
