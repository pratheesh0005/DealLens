class AppConstants {
  /// Base URL for the Serverpod backend server
  static const String serverpodBaseUrl = String.fromEnvironment(
    'SERVERPOD_URL',
    defaultValue: 'http://localhost:8082',
  );

  /// 7 days cache duration for SerpApi live shopping queries
  static const Duration liveCacheDuration = Duration(days: 7);

  /// Flag to enable demo data only for testing (disabled by default to prevent fake data)
  static const bool enableDemoData = bool.fromEnvironment(
    'ENABLE_DEMO_DATA',
    defaultValue: false,
  );

  /// Catalog cache duration (1 hour)
  static const Duration catalogCacheDuration = Duration(hours: 1);

  /// Backward-compatible alias for cache duration
  static const Duration cacheExpiryDuration = Duration(hours: 1);

  /// Default pagination page size
  static const int pageSize = 20;

  /// Initial live queries to run on launch (including authentic Meesho queries)
  static const List<String> initialLiveQueries = [
    'smartphones',
    'laptops',
    'headphones',
    'watches',
    'sneakers',
    'home decor',
    'meesho sarees',
    'meesho kurtis',
    'meesho handbags',
    'electronics',
    'beauty products',
    'croma electronics',
    'reliance digital',
    'myntra fashion',
  ];
}
