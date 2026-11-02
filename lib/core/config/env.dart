/// Build-time config read via `--dart-define-from-file=env/<flavor>.json`.
/// Keys mirror `env/*.example.json`.
class Env {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// 'mock' (default, no backend calls) or 'supabase'.
  static const dataSource = String.fromEnvironment(
    'DATA_SOURCE',
    defaultValue: 'mock',
  );

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isMockDataSource => dataSource == 'mock';

  /// Shows UPI and Card at checkout. Off until PhonePe credentials are set
  /// as Edge Function secrets; until then only Cash on delivery is offered,
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
