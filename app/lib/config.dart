// Values injected at build time. Copy .env.example to .env, fill in, then:
//   flutter run --dart-define-from-file=.env
class Config {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const clarityProjectId = String.fromEnvironment('CLARITY_PROJECT_ID');
}
