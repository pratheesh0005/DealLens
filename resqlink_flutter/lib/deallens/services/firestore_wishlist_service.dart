import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_models.dart';

/// Secure Firestore Database Service implementing users/{firebaseUid}/wishlist/{productId}.
class FirestoreWishlistService {
  final FirebaseFirestore _firestore;

  FirestoreWishlistService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userWishlistRef(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('Firebase UID cannot be empty.');
    }
    return _firestore.collection('users').doc(userId).collection('wishlist');
  }

  /// Get all wishlist items for the authenticated user from Firestore
  Future<List<Product>> getWishlist(String userId) async {
    if (userId.trim().isEmpty) return [];

    try {
      final snapshot = await _userWishlistRef(
        userId,
      ).orderBy('savedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => Product.fromFirestoreWishlist(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore getWishlist error (${e.code}): ${e.message}');
      // Fallback without ordering if index is building
      if (e.code == 'failed-precondition') {
        try {
          final fallbackSnapshot = await _userWishlistRef(userId).get();
          final list = fallbackSnapshot.docs
              .map((doc) => Product.fromFirestoreWishlist(doc.data(), doc.id))
              .toList();
          list.sort((a, b) {
            final tA = a.savedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final tB = b.savedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return tB.compareTo(tA);
          });
          return list;
        } catch (_) {}
      }
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error fetching wishlist: $e');
      rethrow;
    }
  }

  /// Real-time stream of wishlist items from Firestore
  Stream<List<Product>> streamWishlist(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value([]);
    }

    return _userWishlistRef(userId).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Product.fromFirestoreWishlist(doc.data(), doc.id))
          .toList();

      list.sort((a, b) {
        final tA = a.savedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tB = b.savedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return tB.compareTo(tA);
      });

      return list;
    });
  }

  /// Sanitize product IDs into valid Firestore document path IDs
  static String safeDocId(String id) {
    var clean = id
        .trim()
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(' ', '_')
        .replaceAll('..', '_');
    if (clean.isEmpty) {
      clean = 'item_${DateTime.now().millisecondsSinceEpoch}';
    }
    if (clean.length > 200) {
      clean = clean.substring(0, 200);
    }
    return clean;
  }

  /// Add a product to the user's Firestore wishlist:
  /// users/{firebaseUid}/wishlist/{productId}
  Future<void> addToWishlist(String userId, Product product) async {
    if (userId.trim().isEmpty) {
      throw StateError('User is not authenticated.');
    }
    if (product.id.trim().isEmpty) {
      throw ArgumentError('Product ID is missing or invalid.');
    }

    try {
      final data = product.toFirestoreWishlistMap();
      final docRef = _userWishlistRef(userId).doc(safeDocId(product.id));
      await docRef.set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('Firestore addToWishlist error (${e.code}): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Failed to add product to Firestore: $e');
      rethrow;
    }
  }

  /// Remove a product from the user's Firestore wishlist
  Future<void> removeFromWishlist(String userId, String productId) async {
    if (userId.trim().isEmpty) {
      throw StateError('User is not authenticated.');
    }
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    try {
      await _userWishlistRef(userId).doc(safeDocId(productId)).delete();
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore removeFromWishlist error (${e.code}): ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Failed to delete product from Firestore: $e');
      rethrow;
    }
  }

  /// Clear all products from user's Firestore wishlist
  Future<void> clearWishlist(String userId) async {
    if (userId.trim().isEmpty) {
      throw StateError('User is not authenticated.');
    }

    try {
      final snapshot = await _userWishlistRef(userId).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      debugPrint('Firestore clearWishlist error (${e.code}): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Failed to clear wishlist from Firestore: $e');
      rethrow;
    }
  }
}
