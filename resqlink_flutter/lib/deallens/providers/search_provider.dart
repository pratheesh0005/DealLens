import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/live_search_service.dart';
import '../services/product_deduplication_service.dart';
import '../utils/constants.dart';

class SearchProvider extends ChangeNotifier {
  final LiveSearchService _liveSearchService;

  SearchProvider({LiveSearchService? liveSearchService})
    : _liveSearchService = liveSearchService ?? LiveSearchService();

  List<Product> _catalog = [];
  List<Product> _allMatched = [];
  bool _isLoading = false;
  bool _isLiveLoading = false;
  bool _isNetworkError = false;
  String? _errorMessage;
  String? _liveSearchMessage;

  String _currentQuery = '';
  String? _selectedCategoryName;
  SortOption _currentSort = SortOption.relevance;
  String? _selectedStore; // null = all, 'Amazon', 'Flipkart', 'Meesho'

  int _currentPage = 1;
  final int _pageSize = AppConstants.pageSize; // 20 at a time
  Timer? _debounceTimer;

  void updateCatalog(List<Product> products) {
    _catalog = products;
    if (_currentQuery.isNotEmpty || _selectedCategoryName != null) {
      _applyLocalSearchAndFilter(autoFetchLive: false);
    }
  }

  /// Total count before store filter is applied
  int get allMatchedCount => _allMatched.length;

  List<Product> get allResults {
    List<Product> list = List.from(_allMatched);

    if (_selectedStore != null && _selectedStore!.isNotEmpty) {
      final sel = _selectedStore!.toLowerCase().trim();
      list = list.where((p) {
        final sName = p.storeName.toLowerCase();
        final sLabel = p.storeLabel.toLowerCase();
        return sName.contains(sel) || sLabel.contains(sel);
      }).toList();
    }

    switch (_currentSort) {
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingHighToLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.relevance:
        break;
    }

    return list;
  }

  /// Paginated visible results (20 at a time)
  List<Product> get visibleResults {
    final full = allResults;
    final count = (_currentPage * _pageSize).clamp(0, full.length);
    return full.take(count).toList();
  }

  bool get hasMore => visibleResults.length < allResults.length;
  bool get isLoading => _isLoading;
  bool get isLiveLoading => _isLiveLoading;
  bool get isNetworkError => _isNetworkError;
  String? get errorMessage => _errorMessage;
  String? get liveSearchMessage => _liveSearchMessage;
  String get currentQuery => _currentQuery;
  String? get selectedCategoryName => _selectedCategoryName;
  SortOption get currentSort => _currentSort;
  String? get selectedStore => _selectedStore;
  bool get hasSearched =>
      _currentQuery.isNotEmpty || _selectedCategoryName != null;

  /// Debounced search while typing (300ms)
  void onQueryChanged(String query, List<Product> catalog) {
    _debounceTimer?.cancel();
    if (catalog.isNotEmpty) {
      _catalog = catalog;
    }
    final clean = query.trim();
    if (clean.isEmpty) {
      clear();
      return;
    }
    _currentQuery = clean;
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      search(clean, _catalog, autoFetchLive: true);
    });
  }

  /// Immediate search triggered on Enter/Search key submission
  void submitSearch(String query, List<Product> catalog) {
    _debounceTimer?.cancel();
    if (catalog.isNotEmpty) {
      _catalog = catalog;
    }
    final clean = query.trim();
    if (clean.isEmpty) {
      clear();
      return;
    }
    search(clean, _catalog, autoFetchLive: true, forceLive: true);
  }

  /// Execute search across local products and live SerpApi Google Shopping
  void search(
    String query,
    List<Product> catalog, {
    bool autoFetchLive = true,
    bool forceLive = false,
  }) {
    if (catalog.isNotEmpty) {
      _catalog = catalog;
    }
    _currentQuery = query.trim();
    _selectedCategoryName = null;
    _currentPage = 1;
    _isNetworkError = false;
    _liveSearchMessage = null;

    if (_currentQuery.isEmpty) {
      clear();
      return;
    }

    _applyLocalSearchAndFilter(
      autoFetchLive: autoFetchLive,
      forceLive: forceLive,
    );
  }

  void filterByCategory(String categoryTitle, List<Product> catalog) {
    _debounceTimer?.cancel();
    if (catalog.isNotEmpty) {
      _catalog = catalog;
    }
    _currentQuery = '';
    _selectedCategoryName = categoryTitle.trim();
    _currentPage = 1;
    _isNetworkError = false;
    _liveSearchMessage = null;

    _applyLocalSearchAndFilter(autoFetchLive: true);
  }

  void _applyLocalSearchAndFilter({
    bool autoFetchLive = true,
    bool forceLive = false,
  }) {
    _errorMessage = null;

    final query = _currentQuery.toLowerCase();
    final cat = _selectedCategoryName?.toLowerCase();

    List<Product> matched = List<Product>.from(_catalog);

    if (cat != null && cat.isNotEmpty) {
      matched = matched.where((p) {
        final c = p.category.toLowerCase().trim();
        if (c == cat) return true;
        if (cat == 'shoes' && (c == 'shoes' || c == 'sneakers')) return true;
        if (cat == 'sneakers' && (c == 'shoes' || c == 'sneakers')) return true;
        if (cat == 'home' && (c == 'home decor' || c == 'home')) return true;
        if (cat == 'home decor' && (c == 'home decor' || c == 'home')) {
          return true;
        }
        if (cat == 'mobiles' && (c == 'smartphones' || c == 'mobiles')) {
          return true;
        }
        if (cat == 'smartphones' && (c == 'smartphones' || c == 'mobiles')) {
          return true;
        }
        return false;
      }).toList();
    }

    if (query.isNotEmpty) {
      matched = matched.where((p) {
        final t = p.title.toLowerCase();
        final c = p.category.toLowerCase();
        final b = (p.brand ?? '').toLowerCase();
        return t.contains(query) || c.contains(query) || b.contains(query);
      }).toList();
    }

    _allMatched = ProductDeduplicationService.deduplicate(
      matched,
      preserveOffers: true,
    );

    if (forceLive) {
      // User explicitly submitted: search live immediately
      _isLoading = _allMatched.isEmpty;
      notifyListeners();
      fetchLivePrices(force: true);
      return;
    }

    if (_allMatched.isNotEmpty) {
      // Show local matches immediately (zero latency)
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      // Optionally enrich in background if autoFetchLive is enabled
      if (autoFetchLive && _currentQuery.isNotEmpty) {
        fetchLivePrices(quiet: true);
      }
    } else {
      // Zero local matches found: auto-fetch live Google Shopping deals
      if (autoFetchLive &&
          (_currentQuery.length >= 2 || (cat != null && cat.isNotEmpty))) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
        fetchLivePrices();
      } else {
        _isLoading = false;
        _errorMessage =
            'No products found for "${_currentQuery.isNotEmpty ? _currentQuery : _selectedCategoryName}".';
        notifyListeners();
      }
    }
  }

  /// Lazy loading / pagination: load next 20 items
  void loadMore() {
    if (hasMore) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// Live search using SerpApi Google Shopping (gl=in, hl=en)
  Future<void> fetchLivePrices({
    bool force = false,
    bool quiet = false,
  }) async {
    final cleanQuery = _currentQuery.isNotEmpty
        ? _currentQuery
        : (_selectedCategoryName ?? '');
    if (cleanQuery.isEmpty) return;

    if (!quiet) {
      _isLiveLoading = true;
      _isNetworkError = false;
      _liveSearchMessage = null;
      notifyListeners();
    }

    try {
      final liveProducts = await _liveSearchService.searchLivePrices(
        cleanQuery,
      );

      // Validate that the query hasn't changed while request was in-flight
      final currentTarget = _currentQuery.isNotEmpty
          ? _currentQuery.trim().toLowerCase()
          : (_selectedCategoryName?.trim().toLowerCase() ?? '');
      if (cleanQuery.toLowerCase() != currentTarget) {
        return; // Discard stale in-flight response
      }

      final usable = liveProducts.where((p) => p.hasUsableUrl).toList();

      if (usable.isNotEmpty) {
        // Keep local matches only if they actually match the current search query
        final List<Product> relevantLocal = [];
        for (final p in _allMatched) {
          final t = p.title.toLowerCase();
          final c = p.category.toLowerCase();
          final b = (p.brand ?? '').toLowerCase();
          if (t.contains(cleanQuery) ||
              c.contains(cleanQuery) ||
              b.contains(cleanQuery)) {
            relevantLocal.add(p);
          }
        }

        // Deduplicate and aggregate retailer offers across live and local products
        _allMatched = ProductDeduplicationService.deduplicate(
          [...usable, ...relevantLocal],
          preserveOffers: true,
        );
        _currentPage = 1;
        _errorMessage = null;
        _isNetworkError = false;
        _liveSearchMessage =
            'Showing ${_allMatched.length} live deals for "$cleanQuery"';
      } else {
        if (_allMatched.isEmpty) {
          _errorMessage = 'No products found for "$cleanQuery".';
          _isNetworkError = false;
        }
      }
    } catch (e) {
      if (_allMatched.isEmpty) {
        _isNetworkError = true;
        _errorMessage = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('StateError: ', '');
      } else {
        _liveSearchMessage = 'Offline: Showing local matches.';
      }
    } finally {
      _isLiveLoading = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSort(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  void setSelectedStore(String? store) {
    _selectedStore = store;
    _currentPage = 1;
    notifyListeners();
  }

  void clear() {
    _debounceTimer?.cancel();
    _currentQuery = '';
    _selectedCategoryName = null;
    _selectedStore = null; // Reset store filter on clear
    _allMatched = [];
    _errorMessage = null;
    _liveSearchMessage = null;
    _isNetworkError = false;
    _currentPage = 1;
    _isLoading = false;
    _isLiveLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
