import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// Server-side product search and comparison service for DealLens.
/// Keeps API credentials securely on the server and provides caching,
/// timeout handling, and accurate data preservation.
class DealService {
  static final http.Client _client = http.Client();
  static final Map<String, _CachedResult> _serverCache = {};

  /// Retrieve the active SerpApi API key from environment, session passwords, or server config.
  static String? getApiKey(Session? session) {
    // 1. Check environment variable
    final envKey = Platform.environment['SERPAPI_KEY']?.trim();
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // 2. Check session passwords if available (loaded from git-ignored passwords.yaml)
    if (session != null) {
      final pwdKey = session.passwords['serpApiKey']?.trim();
      if (pwdKey != null && pwdKey.isNotEmpty) {
        return pwdKey;
      }
    }

    // 3. Check local private .env file
    for (final path in ['.env', '../.env', 'config/.env']) {
      final file = File(path);
      if (file.existsSync()) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('SERPAPI_KEY=')) {
            final val = trimmed.substring('SERPAPI_KEY='.length).trim();
            if (val.isNotEmpty) return val;
          }
        }
      }
    }

    return null;
  }

  /// Execute product search for Indian retailers via Google Shopping.
  static Future<Map<String, dynamic>> searchProducts(
    Session session,
    String query, {
    bool forceRefresh = false,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return {
        'success': true,
        'query': query,
        'totalResults': 0,
        'results': <Map<String, dynamic>>[],
        'source': 'DealLens Serverpod Engine',
      };
    }

    // Check 24-hour server memory cache
    if (!forceRefresh && _serverCache.containsKey(cleanQuery)) {
      final cached = _serverCache[cleanQuery]!;
      if (DateTime.now().difference(cached.timestamp) <
          const Duration(hours: 24)) {
        session.log('Serving "$cleanQuery" from Serverpod in-memory cache.');
        return cached.data;
      }
    }

    final apiKey = getApiKey(session);
    if (apiKey == null || apiKey.isEmpty) {
      session.log('SERPAPI_KEY is not configured in private env, .env, or passwords.yaml.');
      return {
        'success': false,
        'error': 'SERPAPI_KEY not configured. Set SERPAPI_KEY in .env or passwords.yaml.',
        'query': cleanQuery,
        'results': <Map<String, dynamic>>[],
      };
    }

    final url =
        'https://serpapi.com/search.json?engine=google_shopping&q=${Uri.encodeComponent(cleanQuery)}&gl=in&hl=en&api_key=$apiKey';

    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data.containsKey('shopping_results')) {
          final rawResults = data['shopping_results'];
          if (rawResults is List) {
            final List<Map<String, dynamic>> products = [];
            for (final item in rawResults) {
              if (item is Map<String, dynamic>) {
                final mapped = _mapSerpApiProduct(item, cleanQuery);
                products.add(mapped);
              }
            }

            final deduplicated = _deduplicateServerResults(products);

            final result = {
              'success': true,
              'query': cleanQuery,
              'totalResults': deduplicated.length,
              'results': deduplicated,
              'source': 'Google Shopping India (via Serverpod)',
            };

            _serverCache[cleanQuery] = _CachedResult(
              data: result,
              timestamp: DateTime.now(),
            );

            session.log(
              'Fetched ${products.length} live products for "$cleanQuery" from Google Shopping India.',
            );
            return result;
          }
        }

        if (data is Map && data.containsKey('error')) {
          final errStr = data['error'].toString();
          if (errStr.toLowerCase().contains("hasn't returned any results") ||
              errStr.toLowerCase().contains('zero results') ||
              errStr.toLowerCase().contains('no results')) {
            final emptyResult = {
              'success': true,
              'query': cleanQuery,
              'totalResults': 0,
              'results': <Map<String, dynamic>>[],
              'message': 'No products found for "$cleanQuery".',
              'source': 'Google Shopping India',
            };
            _serverCache[cleanQuery] = _CachedResult(
              data: emptyResult,
              timestamp: DateTime.now(),
            );
            return emptyResult;
          }

          if (errStr.toLowerCase().contains('limit') ||
              errStr.toLowerCase().contains('quota') ||
              errStr.toLowerCase().contains('exhausted')) {
            throw StateError(
              'Monthly search quota limit reached. Please try again later.',
            );
          }

          throw StateError(errStr);
        }

        // Response without shopping_results or error
        return {
          'success': true,
          'query': cleanQuery,
          'totalResults': 0,
          'results': <Map<String, dynamic>>[],
          'source': 'Google Shopping India',
        };
      } else if (response.statusCode == 429) {
        throw StateError(
          'Rate limit reached on product search provider. Please try again in a few moments.',
        );
      } else {
        throw StateError(
          'Search provider returned HTTP ${response.statusCode}.',
        );
      }
    } catch (e, st) {
      session.log(
        'DealService error for query "$cleanQuery": $e',
        level: LogLevel.error,
        stackTrace: st,
      );
      // Fallback to stale cache if present
      if (_serverCache.containsKey(cleanQuery)) {
        return _serverCache[cleanQuery]!.data;
      }
      rethrow;
    }
  }

  /// Maps a SerpApi shopping item preserving authentic data.
  static Map<String, dynamic> _mapSerpApiProduct(
    Map<String, dynamic> json,
    String fallbackCategory,
  ) {
    final title = json['title'] as String? ?? 'Product';
    final rawSource = (json['source'] as String? ?? '').trim();
    final source = rawSource.isNotEmpty ? rawSource : 'Google Shopping';
    final sourceIcon = json['source_icon'] as String?;
    final rawPrice = json['extracted_price'] ?? json['price'];

    double parsedPrice = 0.0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      final digits = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedPrice = double.tryParse(digits) ?? 0.0;
    }

    final rawLink = (json['link'] as String? ?? '').trim();
    final rawProductLink = (json['product_link'] as String? ?? '').trim();
    final destinationUrl = _selectBestUrl(rawLink, rawProductLink);

    final rawRating = json['rating'];
    final double ratingVal = (rawRating is num) ? rawRating.toDouble() : 0.0;

    final rawReviews = json['reviews'];
    final int reviewsVal = (rawReviews is num) ? rawReviews.toInt() : 0;

    final thumbnail = (json['thumbnail'] as String?) ?? '';

    final lowerSource = source.toLowerCase();
    final storeName = lowerSource.contains('flipkart')
        ? 'Flipkart'
        : (lowerSource.contains('meesho')
              ? 'Meesho'
              : (lowerSource.contains('amazon')
                    ? 'Amazon'
                    : (lowerSource.contains('croma')
                          ? 'Croma'
                          : (lowerSource.contains('reliance')
                                ? 'Reliance Digital'
                                : (lowerSource.contains('myntra')
                                      ? 'Myntra'
                                      : source)))));

    final productIdVal = json['product_id'] ?? '${title.hashCode.abs()}';
    final idStr = 'serp_$productIdVal';

    final primaryOffer = {
      'productId': idStr,
      'productName': title,
      'storeName': storeName,
      'storeLabel': source,
      'price': parsedPrice,
      'currency': 'INR',
      'isLowest': true,
      'url': destinationUrl,
      'imageUrl': thumbnail,
      'iconUrl': sourceIcon,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    return {
      'id': idStr,
      'title': title,
      'description': 'Live verified deal from $source via DealLens Engine',
      'category': fallbackCategory,
      'imageUrl': thumbnail,
      'images': [if (thumbnail.isNotEmpty) thumbnail],
      'price': parsedPrice,
      'rating': ratingVal,
      'reviewCount': reviewsVal,
      'storeName': storeName,
      'storeLabel': source,
      'offers': [primaryOffer],
      'isLive': true,
      'buyUrl': destinationUrl,
      'storeIconUrl': sourceIcon,
      'priceFetchedAt': DateTime.now().toIso8601String(),
    };
  }

  static String? _selectBestUrl(String link, String productLink) {
    final unLink = _unwrapGoogleUrl(link);
    final unProductLink = _unwrapGoogleUrl(productLink);

    if (_isDirectRetailerUrl(unLink)) return unLink;
    if (_isDirectRetailerUrl(unProductLink)) return unProductLink;
    if (_isDirectRetailerUrl(link)) return link;
    if (_isDirectRetailerUrl(productLink)) return productLink;

    if (productLink.isNotEmpty &&
        (productLink.startsWith('http://') ||
            productLink.startsWith('https://'))) {
      return productLink;
    }
    if (link.isNotEmpty &&
        (link.startsWith('http://') || link.startsWith('https://'))) {
      return link;
    }
    return null;
  }

  static String? _unwrapGoogleUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return rawUrl;

    final host = uri.host.toLowerCase();
    if (host.contains('google.') || host.contains('googleadservices.')) {
      final target =
          uri.queryParameters['url'] ??
          uri.queryParameters['q'] ??
          uri.queryParameters['adurl'];

      if (target != null && target.isNotEmpty) {
        final decoded = Uri.decodeFull(target);
        if (decoded.startsWith('http://') || decoded.startsWith('https://')) {
          final decodedUri = Uri.tryParse(decoded);
          if (decodedUri != null &&
              !decodedUri.host.toLowerCase().contains('google.')) {
            return decoded;
          }
        }
      }
    }
    return rawUrl;
  }

  static bool _isDirectRetailerUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://'))
      return false;

    if (lower.contains('/s?k=') ||
        lower.contains('/s?') ||
        lower.contains('/search?') ||
        lower.contains('/search/') ||
        lower.contains('search_query=') ||
        lower.contains('query=')) {
      return false;
    }

    if (lower.contains('google.com') ||
        lower.contains('google.co.in') ||
        lower.contains('google.co.')) {
      return false;
    }

    return true;
  }

  /// Deduplicate products on the server and combine multiple retailer offers
  static List<Map<String, dynamic>> _deduplicateServerResults(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) return items;

    final Map<String, Map<String, dynamic>> master = {};

    for (final item in items) {
      final title = item['title'] as String? ?? '';
      final category = item['category'] as String? ?? '';
      final key = _getServerDedupKey(
        title,
        category,
        item['buyUrl'] as String?,
      );

      if (master.containsKey(key)) {
        final existing = master[key]!;
        // Merge offers
        final List<dynamic> existingOffers = List.from(
          existing['offers'] as List? ?? [],
        );
        final List<dynamic> incomingOffers = List.from(
          item['offers'] as List? ?? [],
        );

        final Map<String, Map<String, dynamic>> offerMap = {};
        for (final o in [...existingOffers, ...incomingOffers]) {
          if (o is Map<String, dynamic>) {
            final sName = (o['storeName'] as String? ?? '').toLowerCase();
            if (offerMap.containsKey(sName)) {
              final prev = offerMap[sName]!;
              final prevPrice = (prev['price'] as num?)?.toDouble() ?? 0.0;
              final curPrice = (o['price'] as num?)?.toDouble() ?? 0.0;
              if (curPrice > 0 && (prevPrice <= 0 || curPrice < prevPrice)) {
                offerMap[sName] = o;
              }
            } else {
              offerMap[sName] = o;
            }
          }
        }

        final combinedOffers = offerMap.values.toList();
        combinedOffers.sort((a, b) {
          final pA = (a['price'] as num?)?.toDouble() ?? 0.0;
          final pB = (b['price'] as num?)?.toDouble() ?? 0.0;
          if (pA > 0 && pB <= 0) return -1;
          if (pA <= 0 && pB > 0) return 1;
          return pA.compareTo(pB);
        });

        final validOffers = combinedOffers
            .where((o) => ((o['price'] as num?)?.toDouble() ?? 0.0) > 0)
            .toList();
        final lowestPrice = validOffers.isNotEmpty
            ? (validOffers.first['price'] as num).toDouble()
            : 0.0;
        final highestPrice = validOffers.isNotEmpty
            ? (validOffers.last['price'] as num).toDouble()
            : 0.0;
        final savings = (highestPrice - lowestPrice > 0)
            ? (highestPrice - lowestPrice).roundToDouble()
            : null;

        for (final o in combinedOffers) {
          final p = (o['price'] as num?)?.toDouble() ?? 0.0;
          o['isLowest'] = (p > 0 && p == lowestPrice && validOffers.length > 1);
        }

        final leadOffer = validOffers.isNotEmpty
            ? validOffers.first
            : combinedOffers.first;

        existing['offers'] = combinedOffers;
        if (lowestPrice > 0) {
          existing['price'] = lowestPrice;
          existing['storeName'] = leadOffer['storeName'];
          existing['storeLabel'] = leadOffer['storeLabel'];
          existing['buyUrl'] = leadOffer['url'] ?? existing['buyUrl'];
          existing['storeIconUrl'] =
              leadOffer['iconUrl'] ?? existing['storeIconUrl'];
        }
        if (savings != null) {
          existing['savingsInr'] = savings;
          existing['matchedStore'] = validOffers.last['storeName'];
          existing['matchedPriceInr'] = highestPrice;
        }
      } else {
        master[key] = Map<String, dynamic>.from(item);
      }
    }

    return master.values.toList();
  }

  static String _getServerDedupKey(
    String title,
    String category,
    String? url,
  ) {
    if (url != null) {
      final asinMatch = RegExp(
        r'/(?:dp|product)/([bB]0[a-zA-Z0-9]{8})',
      ).firstMatch(url);
      if (asinMatch != null) return 'asin_${asinMatch.group(1)!.toUpperCase()}';

      final fsnMatch = RegExp(
        r'/(?:p|itm)/([a-zA-Z0-9]{16}|itm[a-zA-Z0-9]+)',
      ).firstMatch(url.toLowerCase());
      if (fsnMatch != null) return 'fsn_${fsnMatch.group(1)}';
    }

    final lower = title.toLowerCase();
    final List<String> tokens = [];

    // Specs
    final storageMatch = RegExp(
      r'\b(64|128|256|512)\s*(?:gb|gigabytes)\b',
    ).firstMatch(lower);
    if (storageMatch != null) tokens.add('s:${storageMatch.group(1)}gb');

    final tbMatch = RegExp(r'\b(1|2)\s*(?:tb|terabytes)\b').firstMatch(lower);
    if (tbMatch != null) tokens.add('s:${tbMatch.group(1)}tb');

    final ramMatch = RegExp(
      r'\b(4|6|8|12|16|18|24|32|36|64)\s*(?:gb)?\s*(?:ram|memory)\b',
    ).firstMatch(lower);
    if (ramMatch != null) tokens.add('r:${ramMatch.group(1)}gb');

    final mChipMatch = RegExp(r'\b(m1|m2|m3|m4)\b').firstMatch(lower);
    if (mChipMatch != null) tokens.add('chip:${mChipMatch.group(1)}');

    final genMatch = RegExp(
      r'\b(\d+)(?:st|nd|rd|th)?\s*(?:gen|generation)\b',
    ).firstMatch(lower);
    if (genMatch != null) tokens.add('gen:${genMatch.group(1)}');

    if (lower.contains('slim')) tokens.add('ed:slim');
    if (lower.contains('digital')) tokens.add('ed:digital');
    if (lower.contains('disc')) tokens.add('ed:disc');
    if (lower.contains('ultra')) tokens.add('ed:ultra');
    if (lower.contains('pro max')) {
      tokens.add('ed:promax');
    } else if (lower.contains('pro')) {
      tokens.add('ed:pro');
    }
    if (lower.contains('plus')) tokens.add('ed:plus');

    // Clean title
    final cleanWords = lower
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where(
          (w) =>
              w.length > 2 &&
              w != 'amazon' &&
              w != 'flipkart' &&
              w != 'best' &&
              w != 'deal',
        )
        .take(5)
        .join('_');

    tokens.sort();
    return '${category.toLowerCase()}_${cleanWords}_${tokens.join('|')}';
  }
}

class _CachedResult {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  _CachedResult({required this.data, required this.timestamp});
}
