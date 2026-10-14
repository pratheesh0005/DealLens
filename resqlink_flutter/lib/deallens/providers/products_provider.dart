import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/api_service.dart';
import '../services/comprehensive_catalog_service.dart';
import '../services/live_search_service.dart';
import '../services/product_deduplication_service.dart';

/// Products / Home Provider managing product ingestion, merging, categories, and deals.
class ProductsProvider extends ChangeNotifier {
  final ApiService _apiService;
  final LiveSearchService _liveSearchService;

  ProductsProvider({
    ApiService? apiService,
    LiveSearchService? liveSearchService,
  }) : _apiService = apiService ?? ApiService(),
       _liveSearchService = liveSearchService ?? LiveSearchService();

  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Trending products: top 15 verified products, prioritizing real ratings
  List<Product> get trendingTop15 {
    final list = List<Product>.from(_allProducts);
    list.sort((a, b) {
      if (a.hasValidRating && !b.hasValidRating) return -1;
      if (!a.hasValidRating && b.hasValidRating) return 1;
      final ratingComp = b.rating.compareTo(a.rating);
      if (ratingComp != 0) return ratingComp;
      return b.price.compareTo(a.price);
    });
    return list.take(15).toList();
  }

  /// All trending products sorted by rating and price
  List<Product> get allTrending {
    final list = List<Product>.from(_allProducts);
    list.sort((a, b) {
      if (a.hasValidRating && !b.hasValidRating) return -1;
      if (!a.hasValidRating && b.hasValidRating) return 1;
      final ratingComp = b.rating.compareTo(a.rating);
      if (ratingComp != 0) return ratingComp;
      return b.price.compareTo(a.price);
    });
    return list;
  }

  /// Best Prices: accurately sort deduplicated products prioritizing real verified savings
  List<Product> get allBestPrices {
    if (_allProducts.isEmpty) return [];

    final list = List<Product>.from(_allProducts);
    list.sort((a, b) {
      final aSavings = a.savingsInr ?? 0.0;
      final bSavings = b.savingsInr ?? 0.0;
      if (aSavings > 0 && bSavings <= 0) return -1;
      if (bSavings > 0 && aSavings <= 0) return 1;
      if (aSavings > 0 && bSavings > 0) {
        final cmp = bSavings.compareTo(aSavings);
        if (cmp != 0) return cmp;
      }
      return a.price.compareTo(b.price);
    });
    return list;
  }

  /// Top 15 Best Price deals for Home screen
  List<Product> get bestPriceDealsTop15 => allBestPrices.take(15).toList();

  /// Top 15 Tech & Electronics Deals (Smartphones, Laptops, Audio, Watches)
  List<Product> get topTechDeals {
    const techCategories = {
      'smartphones',
      'mobiles',
      'laptops',
      'headphones',
      'watches',
      'electronics',
    };
    return _allProducts
        .where((p) => techCategories.contains(p.category.toLowerCase().trim()))
        .take(15)
        .toList();
  }

  /// Top 15 Fashion & Lifestyle Deals (Ethnic Sarees, Kurtis, Shoes, Bags)
  List<Product> get topFashionDeals {
    const fashionCategories = {
      'fashion',
      'shoes',
      'sneakers',
      'bags',
      'beauty',
      'home decor',
      'home',
    };
    return _allProducts
        .where((p) => fashionCategories.contains(p.category.toLowerCase().trim()))
        .take(15)
        .toList();
  }

  /// Master list of app categories with respective icons
  static const List<_CategoryTemplate> _categoryTemplates = [
    _CategoryTemplate('Smartphones', Icons.smartphone_rounded),
    _CategoryTemplate('Laptops', Icons.laptop_mac_rounded),
    _CategoryTemplate('Headphones', Icons.headphones_rounded),
    _CategoryTemplate('Watches', Icons.watch_rounded),
    _CategoryTemplate('Shoes', Icons.directions_run_rounded),
    _CategoryTemplate('Home Decor', Icons.home_rounded),
    _CategoryTemplate('Fashion', Icons.checkroom_rounded),
    _CategoryTemplate('Electronics', Icons.devices_rounded),
    _CategoryTemplate('Beauty', Icons.spa_rounded),
    _CategoryTemplate('Bags', Icons.shopping_bag_rounded),
    _CategoryTemplate('Mobiles', Icons.phone_android_rounded),
  ];

  /// Dynamic list of categories with real counts, strictly hiding categories with 0 products
  List<ProductCategory> get activeCategories {
    if (_allProducts.isEmpty) {
      return [];
    }

    final Map<String, int> counts = {};
    for (final p in _allProducts) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }

    final List<ProductCategory> active = [];
    for (final template in _categoryTemplates) {
      final count = counts[template.name] ?? 0;
      if (count > 0) {
        active.add(
          ProductCategory(
            name: template.name,
            icon: template.icon,
            count: count,
          ),
        );
      }
    }
    return active;
  }

  /// Category count map for quick lookups
  Map<String, int> get categoryCounts {
    final Map<String, int> counts = {};
    for (final p in _allProducts) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Ingest products across comprehensive Indian catalog + multi-store APIs + live searches
  Future<void> fetchHomeData({
    bool forceRefresh = false,
    bool forceLiveReload = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Product> merged = [];

      // 1. Load comprehensive Indian multi-store catalog (1,800+ items: Amazon, Flipkart, Meesho)
      try {
        final compCatalog = await ComprehensiveCatalogService.getCatalog();
        merged.addAll(compCatalog);
      } catch (e) {
        debugPrint('Comprehensive catalog load error: $e');
      }

      // 2. Load multi-store catalog products (DummyJSON, Platzi, FakeStore)
      try {
        final catalogProducts = await _apiService.fetchAllProducts(
          forceRefresh: forceRefresh,
        );
        merged.addAll(catalogProducts);
      } catch (e) {
        debugPrint('Catalog load error: $e');
      }

      // 3. Ingest real live products from Google Shopping India (Amazon, Flipkart, Meesho, Croma, etc.)
      try {
        final List<Product> liveProducts = await _liveSearchService
            .fetchAllInitialLiveProducts(
              forceReload: forceLiveReload,
            );
        merged.addAll(liveProducts);
      } catch (e) {
        debugPrint('Live products load error: $e');
      }

      // Deduplicate using intelligent deduplication service preserving multi-store offers
      final uniqueMerged = ProductDeduplicationService.deduplicate(
        merged,
        preserveOffers: true,
      );

      if (uniqueMerged.isNotEmpty) {
        _allProducts = uniqueMerged;
      } else {
        _errorMessage =
            'Could not load products. Please check your network connection.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByCategory(String categoryName) {
    final target = categoryName.toLowerCase().trim();
    return _allProducts.where((p) {
      final cat = p.category.toLowerCase().trim();
      if (cat == target) return true;
      if (target == 'shoes' && (cat == 'shoes' || cat == 'sneakers')) {
        return true;
      }
      if (target == 'sneakers' && (cat == 'shoes' || cat == 'sneakers')) {
        return true;
      }
      if (target == 'home' && (cat == 'home decor' || cat == 'home')) {
        return true;
      }
      if (target == 'home decor' && (cat == 'home decor' || cat == 'home')) {
        return true;
      }
      if (target == 'mobiles' && (cat == 'smartphones' || cat == 'mobiles')) {
        return true;
      }
      if (target == 'smartphones' &&
          (cat == 'smartphones' || cat == 'mobiles')) {
        return true;
      }
      return false;
    }).toList();
  }
}

class _CategoryTemplate {
  final String name;
  final IconData icon;
  const _CategoryTemplate(this.name, this.icon);
}

/// Alias for HomeProvider as requested
typedef HomeProvider = ProductsProvider;
