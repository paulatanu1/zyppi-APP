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
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const razorpayKeyId = String.fromEnvironment('RAZORPAY_KEY_ID');

  static bool get isMockDataSource => dataSource == 'mock';
}
