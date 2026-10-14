/// Centralized API configuration loaded securely via environment variables
/// at build or runtime.
///
/// Run with:
///   flutter run --dart-define-from-file=.env
/// or
///   flutter run --dart-define=SERPAPI_KEY=your_key
class ApiKeys {
  static const String _compileTimeKey = String.fromEnvironment('SERPAPI_KEY');
  static const String _privateDefaultKey =
      'fda1866e6d1e794b664f958e65b8d691db9e9da3d836b7ac68ce4f254ed45795';

  /// SerpApi API Key from compile-time / runtime environment, falling back to private key
  static String get serpApiKey =>
      _compileTimeKey.trim().isNotEmpty ? _compileTimeKey : _privateDefaultKey;

  /// Serverpod backend URL
  static const String serverpodUrl = String.fromEnvironment(
    'SERVERPOD_URL',
    defaultValue: 'http://localhost:8082',
  );

  /// Whether a valid SerpApi key has been provided via environment or private default
  static bool get hasSerpApiKey => serpApiKey.trim().isNotEmpty;
}
