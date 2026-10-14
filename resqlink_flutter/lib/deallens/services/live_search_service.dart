import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_models.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'product_deduplication_service.dart';

class LiveSearchService {
  final http.Client _client;
  final Map<String, Future<List<Product>>> _inflightRequests = {};

  LiveSearchService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all initial live products sequentially:
  /// "smartphones", "laptops", "headphones", "watches", "sneakers", "home decor", etc.
  /// Cached for 7 days in SharedPreferences.
  Future<List<Product>> fetchAllInitialLiveProducts({
    bool forceReload = false,
  }) async {
    final List<Product> allLive = [];

    for (final query in AppConstants.initialLiveQueries) {
      try {
        final items = await fetchQuery(query, forceReload: forceReload);
        allLive.addAll(items);
        // Small throttle between requests when making fresh network calls
        if (forceReload) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        debugPrint('Silent live search error for query "$query": $e');
      }
    }

    return ProductDeduplicationService.deduplicate(
      allLive,
      preserveOffers: true,
    );
  }

  /// Alias for search_provider
  Future<List<Product>> searchLivePrices(String query) => fetchQuery(query);

  /// Fetch a single query from SerpApi Google Shopping with 7-day SharedPreferences cache
  Future<List<Product>> fetchQuery(
    String query, {
    bool forceReload = false,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final cacheKey = 'deallens_live_query_v4_$cleanQuery';
    final timeKey = 'deallens_live_time_v4_$cleanQuery';

    // 1. Check 7-day cache in SharedPreferences if not forced
    if (!forceReload) {
      final cached = await _loadFromCache(cacheKey, timeKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    // 2. Return in-flight request if already loading
    if (_inflightRequests.containsKey(cacheKey)) {
      return _inflightRequests[cacheKey]!;
    }

    final future = _executeFetch(cleanQuery, cacheKey, timeKey);
    _inflightRequests[cacheKey] = future;
    try {
      return await future;
    } finally {
      _inflightRequests.remove(cacheKey);
    }
  }

  Future<List<Product>> _executeFetch(
    String cleanQuery,
    String cacheKey,
    String timeKey,
  ) async {
    // 1. Query Serverpod backend endpoint (keeps all credentials secure on the server)
    final backendUrl =
        '${AppConstants.serverpodBaseUrl}/api/search?q=${Uri.encodeComponent(cleanQuery)}';

    try {
      final response = await _client
          .get(Uri.parse(backendUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['success'] == true &&
            data.containsKey('results')) {
          final results = data['results'];
          if (results is List && results.isNotEmpty) {
            final List<Product> list = [];
            for (final item in results) {
              if (item is Map<String, dynamic>) {
                list.add(Product.fromJson(item));
              }
            }

            final deduplicated = ProductDeduplicationService.deduplicate(
              list,
              preserveOffers: true,
            );

            debugPrint(
              '[Serverpod LiveSearch] query: "$cleanQuery", returned ${list.length} raw, ${deduplicated.length} unique products.',
            );

            // Save to 7-day cache
            await _saveToCache(cacheKey, timeKey, deduplicated);
            return deduplicated;
          } else {
            // Valid response with 0 results
            await _saveToCache(cacheKey, timeKey, []);
            return [];
          }
        } else if (data is Map && data.containsKey('error')) {
          final errStr = data['error'].toString();
          if (errStr.toLowerCase().contains("hasn't returned any results") ||
              errStr.toLowerCase().contains('zero results') ||
              errStr.toLowerCase().contains('no results')) {
            await _saveToCache(cacheKey, timeKey, []);
            return [];
          }
          if (errStr.toLowerCase().contains('limit') ||
              errStr.toLowerCase().contains('quota') ||
              errStr.toLowerCase().contains('exhausted')) {
            throw Exception(
              'Monthly search quota limit reached. Please try again later.',
            );
          }
          throw Exception(errStr);
        }
      } else if (response.statusCode == 429) {
        throw Exception(
          'Rate limit exceeded. Please wait a moment and try again.',
        );
      } else {
        throw Exception(
          'Serverpod search returned status ${response.statusCode}.',
        );
      }
    } catch (e) {
      debugPrint('Backend fetch failed for "$cleanQuery": $e');
      // 1. If stale cache exists, fall back to it gracefully
      final stale = await _loadFromCache(cacheKey, timeKey, ignoreExpiry: true);
      if (stale != null && stale.isNotEmpty) {
        return stale;
      }

      // 2. Fall back to local catalog search if backend is not reachable on this device
      try {
        final catalog = await ApiService().fetchAllProducts();
        final matches = catalog.where((p) {
          final t = p.title.toLowerCase();
          final c = p.category.toLowerCase();
          final b = (p.brand ?? '').toLowerCase();
          return t.contains(cleanQuery) ||
              c.contains(cleanQuery) ||
              b.contains(cleanQuery);
        }).toList();
        if (matches.isNotEmpty) {
          return ProductDeduplicationService.deduplicate(
            matches,
            preserveOffers: true,
          );
        }
      } catch (_) {}

      return [];
    }

    return [];
  }

  Future<List<Product>?> _loadFromCache(
    String cacheKey,
    String timeKey, {
    bool ignoreExpiry = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeMs = prefs.getInt(timeKey);
      if (timeMs == null && !ignoreExpiry) return null;

      if (!ignoreExpiry && timeMs != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timeMs);
        if (DateTime.now().difference(cachedTime) >
            AppConstants.liveCacheDuration) {
          return null; // Expired (> 7 days)
        }
      }

      final jsonStr = prefs.getString(cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List;
        return list
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToCache(
    String cacheKey,
    String timeKey,
    List<Product> products,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(jsonList));
      await prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }
}
