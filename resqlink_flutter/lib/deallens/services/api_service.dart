import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_models.dart';
import '../utils/constants.dart';
import 'product_deduplication_service.dart';

class ApiService {
  static const String dummyJsonUrl = 'https://dummyjson.com/products?limit=0';
  static const String platziUrl =
      'https://api.escuelajs.co/api/v1/products?offset=0&limit=100';
  static const String fakeStoreUrl = 'https://fakestoreapi.com/products';

  static const String _cacheKey = 'deallens_cached_all_products_v4';
  static const String _cacheTimestampKey = 'deallens_cache_timestamp_v4';
  static const Duration timeoutDuration = Duration(seconds: 12);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch products from authentic public APIs (DummyJSON, Platzi, FakeStore)
  /// with 1-hour SharedPreferences caching. Does not invent fake products or URLs.
  Future<List<Product>> fetchAllProducts({bool forceRefresh = false}) async {
    // Purge old corrupt cache keys from previous versions
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('deallens_cached_all_products')) {
      await prefs.remove('deallens_cached_all_products');
      await prefs.remove('deallens_cache_timestamp');
    }

    // 1. Try reading valid cache first if not forced
    if (!forceRefresh) {
      final cached = await _loadFromCache();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    // 2. Fetch external APIs in parallel
    final dummyJsonFuture = _fetchDummyJson();
    final platziFuture = _fetchPlatzi();
    final fakeStoreFuture = _fetchFakeStore();

    final results = await Future.wait([
      dummyJsonFuture,
      platziFuture,
      fakeStoreFuture,
    ]);

    final List<Product> merged = [];
    merged.addAll(results[0]); // DummyJSON
    merged.addAll(results[1]); // Platzi
    merged.addAll(results[2]); // FakeStore

    if (merged.isEmpty) {
      // If network failed completely, fall back to any stale cache
      final stale = await _loadFromCache(ignoreExpiry: true);
      if (stale != null && stale.isNotEmpty) {
        return ProductDeduplicationService.deduplicate(
          stale,
          preserveOffers: true,
        );
      }
      throw Exception(
        'Could not load products. Please check your internet connection.',
      );
    }

    // Deduplicate merged products and group multi-store offers
    final deduplicated = ProductDeduplicationService.deduplicate(
      merged,
      preserveOffers: true,
    );

    // 3. Save clean deduplicated catalog to cache with 1-hour expiry
    await _saveToCache(deduplicated);

    return deduplicated;
  }

  /// Store 1: DummyJSON (Amazon) — all ~194 products
  Future<List<Product>> _fetchDummyJson() async {
    try {
      final response = await _client
          .get(Uri.parse(dummyJsonUrl))
          .timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['products'] is List) {
          return (data['products'] as List)
              .map(
                (item) => Product.fromDummyJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('DummyJSON fetch error: $e');
    }
    return [];
  }

  /// Store 2: Platzi (Flipkart) — filter out broken/placeholder images
  Future<List<Product>> _fetchPlatzi() async {
    try {
      final response = await _client
          .get(Uri.parse(platziUrl))
          .timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final List<Product> list = [];
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final validImage = Product.extractValidPlatziImage(
                item['images'],
              );
              // Filter out items with broken or empty images
              if (validImage.isNotEmpty) {
                list.add(Product.fromPlatziJson(item, validImage));
              }
            }
          }
          return list;
        }
      }
    } catch (e) {
      debugPrint('Platzi fetch error: $e');
    }
    return [];
  }

  /// Store 3: Fake Store API (Meesho)
  Future<List<Product>> _fetchFakeStore() async {
    try {
      final response = await _client
          .get(Uri.parse(fakeStoreUrl))
          .timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map(
                (item) =>
                    Product.fromFakeStoreJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('FakeStore fetch error: $e');
    }
    return [];
  }

  /// Cache helpers
  Future<List<Product>?> _loadFromCache({bool ignoreExpiry = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeMs = prefs.getInt(_cacheTimestampKey);
      if (timeMs == null && !ignoreExpiry) return null;

      if (!ignoreExpiry && timeMs != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timeMs);
        if (DateTime.now().difference(cachedTime) >
            AppConstants.catalogCacheDuration) {
          return null; // Expired
        }
      }

      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List;
        return list
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Cache read error: $e');
    }
    return null;
  }

  Future<void> _saveToCache(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Cache write error: $e');
    }
  }
}
