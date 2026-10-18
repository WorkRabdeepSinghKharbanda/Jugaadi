// Values injected at build time. Copy .env.example to .env, fill in, then:
//   flutter run --dart-define-from-file=.env
class Config {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const clarityProjectId = String.fromEnvironment('CLARITY_PROJECT_ID');
  // ADS OFF — uncomment to enable (RUNNING.md). Native ad unit for the nearby-jobs list. Empty in a release build = no ads (never ship Google's test unit).
  // static const admobNativeUnitId = String.fromEnvironment('ADMOB_NATIVE_UNIT_ID');
}
