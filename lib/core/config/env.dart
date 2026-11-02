/// Build-time config read via `--dart-define-from-file=env/<flavor>.json`.
/// Keys mirror `env/*.example.json`.
class Env {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// 'mock' (default: bundled JSON + Hive, no backend calls) or
  /// 'firebase' (Firestore + Cloud Functions). Sign-in always uses
  /// Firebase Auth.
  static const dataSource = String.fromEnvironment(
    'DATA_SOURCE',
    defaultValue: 'mock',
  );

  static bool get isMockDataSource => dataSource == 'mock';

  /// Talk to the local Firebase emulators (`firebase emulators:start`)
  /// instead of project zippy-app-2024. Debug builds only.
  static const useFirebaseEmulator = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
  );

  /// Host running the emulators. Empty means the default for the platform
  /// (10.0.2.2 on the Android emulator, localhost elsewhere); set your
  /// Mac's LAN IP to reach them from a physical phone.
  static const firebaseEmulatorHost = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
  );

  /// Shows UPI and Card at checkout. Off until PhonePe credentials are set
  /// as Cloud Functions secrets; until then only Cash on delivery is offered,
  /// so testers never reach a payment that can't work.
  static const onlinePaymentsEnabled = bool.fromEnvironment(
    'ONLINE_PAYMENTS_ENABLED',
  );

  /// Customer support number in international format without '+'
  /// (e.g. 919876543210), used for WhatsApp and phone help. Empty hides
  /// those options.
  static const supportPhone = String.fromEnvironment('SUPPORT_PHONE');

  /// Public privacy policy / terms pages, shown under Account & privacy
  /// (Play Store requires a privacy policy link). Empty hides the link.
  static const privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
  static const termsUrl = String.fromEnvironment('TERMS_URL');

  static String get phonePeEnvironment =>
      flavor == 'prod' ? 'PRODUCTION' : 'SANDBOX';
}
