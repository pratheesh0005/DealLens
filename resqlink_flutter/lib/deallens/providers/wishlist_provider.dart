import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/firestore_wishlist_service.dart';
import '../services/storage_service.dart';

enum WishlistStatus { initial, loading, loaded, error }

/// Wishlist Provider managing Firestore persistence, optimistic updates, and offline fallback.
class WishlistProvider extends ChangeNotifier {
  final FirestoreWishlistService _firestoreService;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Product>>? _firestoreSubscription;

  List<Product> _items = [];
  WishlistStatus _status = WishlistStatus.initial;
  String? _errorMessage;
  String? _currentUserId;

  List<Product> get items => _items;
  WishlistStatus get status => _status;
  bool get isLoading => _status == WishlistStatus.loading;
  String? get errorMessage => _errorMessage;
  int get count => _items.length;
  bool get isSyncedWithFirestore => _currentUserId != null;
  String? get currentUserId => _currentUserId;

  WishlistProvider({FirestoreWishlistService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreWishlistService() {
    _init();
  }

  void _init() {
    // 1. Initial local load
    _loadFromLocalCache();

    // 2. Listen to Firebase Auth state to bind Firestore wishlist
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user != null) {
        _bindUser(user.uid);
      } else {
        _unbindUser();
      }
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _bindUser(currentUser.uid);
    } else {
      _ensureUserId();
    }
  }

  /// Ensure there is an active Firebase UID (user, anonymous, or persistent guest) to store in Firestore
  Future<String> _ensureUserId() async {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      return _currentUserId!;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      return _currentUserId!;
    }
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      if (cred.user != null) {
        _currentUserId = cred.user!.uid;
        _bindUser(cred.user!.uid);
        return _currentUserId!;
      }
    } catch (e) {
      debugPrint('Anonymous auth notice for wishlist: $e');
    }

    final guestId = await StorageService.getOrCreateGuestId();
    _currentUserId = guestId;
    _bindUser(guestId);
    return guestId;
  }

  Future<void> _loadFromLocalCache() async {
    _status = WishlistStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await StorageService.loadWishlist();
      _status = WishlistStatus.loaded;
    } catch (e) {
      _status = WishlistStatus.error;
      _errorMessage = 'Could not load local wishlist.';
    } finally {
      notifyListeners();
    }
  }

  void _bindUser(String userId) async {
    _currentUserId = userId;
    _firestoreSubscription?.cancel();

    _status = WishlistStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Load local items first so existing items are never lost
      final localItems = await StorageService.loadWishlist();
      if (_items.isEmpty && localItems.isNotEmpty) {
        _items = localItems;
        notifyListeners();
      }

      // 2. Read from Firestore
      final firestoreItems = await _firestoreService.getWishlist(userId);

      // 3. Merge local and Firestore items without duplicates
      final Map<String, Product> mergedMap = {};
      for (final item in firestoreItems) {
        mergedMap[item.id] = item;
      }
      for (final item in localItems) {
        if (!mergedMap.containsKey(item.id)) {
          mergedMap[item.id] = item;
          // Sync missing local item to Firestore
          _firestoreService.addToWishlist(userId, item).catchError((err) {
            debugPrint('Silent Firestore sync error for local item: $err');
          });
        }
      }

      _items = mergedMap.values.toList();
      await StorageService.saveWishlist(_items);
      _status = WishlistStatus.loaded;
      notifyListeners();

      // 4. Listen to real-time changes
      _firestoreSubscription = _firestoreService
          .streamWishlist(userId)
          .listen(
            (updatedList) {
              _items = updatedList;
              StorageService.saveWishlist(updatedList);
              _status = WishlistStatus.loaded;
              _errorMessage = null;
              notifyListeners();
            },
            onError: (err) {
              debugPrint('Firestore wishlist listener error: $err');
              // Keep local items loaded
              _status = WishlistStatus.loaded;
              _errorMessage = _parseFirebaseErrorMessage(err);
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('Error binding user wishlist to Firestore: $e');
      if (_items.isEmpty) {
        _items = await StorageService.loadWishlist();
      }
      _status = WishlistStatus.loaded;
      _errorMessage = _parseFirebaseErrorMessage(e);
      notifyListeners();
    }
  }

  void _unbindUser() async {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    final guestId = await StorageService.getOrCreateGuestId();
    _currentUserId = guestId;
    _bindUser(guestId);
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  /// Toggle product in wishlist with immediate optimistic UI update
  Future<bool> toggleWishlist(Product product) async {
    final exists = isInWishlist(product.id);
    _errorMessage = null;

    if (exists) {
      return await removeFromWishlist(product.id);
    } else {
      return await addToWishlist(product);
    }
  }

  /// Add product to wishlist (Firestore + local cache fallback)
  Future<bool> addToWishlist(Product product) async {
    if (isInWishlist(product.id)) {
      // Prevent duplicate entries
      return true;
    }

    _errorMessage = null;
    final previousItems = List<Product>.from(_items);

    // Optimistic UI update
    _items.insert(0, product);
    notifyListeners();

    try {
      // Local cache backup
      await StorageService.saveWishlist(_items);

      // Ensure user ID and store directly in Cloud Firestore
      final uid = await _ensureUserId();
      try {
        await _firestoreService.addToWishlist(uid, product);
      } catch (firestoreErr) {
        debugPrint('Firestore sync error: $firestoreErr');
        _errorMessage = _parseFirebaseErrorMessage(firestoreErr);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Failed to save product to wishlist: $e');
      // Rollback on local failure
      _items = previousItems;
      _errorMessage = _parseFirebaseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Remove product from wishlist
  Future<bool> removeFromWishlist(String productId) async {
    final previousItems = List<Product>.from(_items);
    _errorMessage = null;

    // Optimistic UI update
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();

    try {
      // Local cache
      await StorageService.saveWishlist(_items);

      // Firestore remove
      final uid = await _ensureUserId();
      try {
        await _firestoreService.removeFromWishlist(uid, productId);
      } catch (firestoreErr) {
        debugPrint('Firestore remove error: $firestoreErr');
        _errorMessage = _parseFirebaseErrorMessage(firestoreErr);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Failed to remove product from wishlist: $e');
      // Rollback on failure
      _items = previousItems;
      _errorMessage = _parseFirebaseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Clear all items from wishlist
  Future<bool> clearWishlist() async {
    final previousItems = List<Product>.from(_items);
    _errorMessage = null;

    // Optimistic UI update
    _items.clear();
    notifyListeners();

    try {
      await StorageService.clearWishlist();

      final uid = await _ensureUserId();
      try {
        await _firestoreService.clearWishlist(uid);
      } catch (firestoreErr) {
        debugPrint('Firestore clear error: $firestoreErr');
        _errorMessage = _parseFirebaseErrorMessage(firestoreErr);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Failed to clear wishlist: $e');
      _items = previousItems;
      _errorMessage = _parseFirebaseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Retry loading wishlist from Firestore
  Future<void> retry() async {
    if (_currentUserId != null) {
      _bindUser(_currentUserId!);
    } else {
      _loadFromLocalCache();
    }
  }

  String _parseFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. Please publish security rules in Firebase Console (Firestore > Rules).';
        case 'unavailable':
          return 'Network unavailable. Displaying local wishlist cache.';
        case 'unauthenticated':
          return 'User is not signed in. Please sign in to save deals.';
        default:
          return error.message ?? 'Firestore error (${error.code}).';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
