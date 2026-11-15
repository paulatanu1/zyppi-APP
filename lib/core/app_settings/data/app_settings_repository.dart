import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zippy/core/app_settings/domain/app_settings.dart';
import 'package:zippy/core/config/env.dart';

/// Server-side switches and app settings, live: a change in the admin
/// reaches open apps within seconds (`config/*` is public read).
abstract class AppSettingsRepository {
  Stream<FeatureFlags> watchFlags();
  Stream<AppConfig> watchAppConfig();
}

class FirebaseAppSettingsRepository implements AppSettingsRepository {
  FirebaseAppSettingsRepository(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Stream<FeatureFlags> watchFlags() => firestore
      .doc('config/features')
      .snapshots()
      .map((s) => FeatureFlags.fromMap(s.data()));

  @override
  Stream<AppConfig> watchAppConfig() => firestore
      .doc('config/app')
      .snapshots()
      .map((s) => AppConfig.fromMap(s.data()));
}

/// Everything on (mock data source and tests).
class MockAppSettingsRepository implements AppSettingsRepository {
  @override
  Stream<FeatureFlags> watchFlags() => Stream.value(FeatureFlags.defaults);

  @override
  Stream<AppConfig> watchAppConfig() => Stream.value(AppConfig.empty);
}

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>(
  (ref) => Env.isMockDataSource
      ? MockAppSettingsRepository()
      : FirebaseAppSettingsRepository(FirebaseFirestore.instance),
);

final _flagsStreamProvider = StreamProvider<FeatureFlags>(
  (ref) => ref.watch(appSettingsRepositoryProvider).watchFlags(),
);

final _appConfigStreamProvider = StreamProvider<AppConfig>(
  (ref) => ref.watch(appSettingsRepositoryProvider).watchAppConfig(),
);

/// The current switches. While loading, or if they can't be read, every
/// switch is ON: the server still refuses what's really off.
final featureFlagsProvider = Provider<FeatureFlags>(
  (ref) => ref.watch(_flagsStreamProvider).value ?? FeatureFlags.defaults,
);

/// Support contacts and the announcement (empty until loaded).
final appConfigProvider = Provider<AppConfig>(
  (ref) => ref.watch(_appConfigStreamProvider).value ?? AppConfig.empty,
);

/// Digits for WhatsApp / call links (see [supportDigits]).
final supportPhoneProvider = Provider<String>(
  (ref) => supportDigits(
    ref.watch(appConfigProvider).supportPhone,
    Env.supportPhone,
  ),
);

final supportWhatsAppProvider = Provider<String>((ref) {
  final c = ref.watch(appConfigProvider);
  return supportDigits(c.whatsappNumber ?? c.supportPhone, Env.supportPhone);
});

/// The installed app's version name ("1.4.0"), or null until read.
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } catch (_) {
    return null;
  }
});

/// True when Settings → Services requires a newer app than this one.
final updateRequiredProvider = Provider<bool>((ref) {
  final version = ref.watch(appVersionProvider).value;
  if (version == null) return false;
  return isOlderVersion(version, ref.watch(featureFlagsProvider).minAppVersion);
});
