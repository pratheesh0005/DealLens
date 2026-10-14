import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_models.dart';

class StorageService {
  static const String _wishlistKey = 'deallens_wishlist_items';

  /// Load wishlist from local storage
  static Future<List<Product>> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_wishlistKey);
      if (jsonList != null && jsonList.isNotEmpty) {
        return jsonList
            .map(
              (item) =>
                  Product.fromJson(jsonDecode(item) as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading wishlist from SharedPreferences: $e');
    }
    return [];
  }

  /// Save wishlist to local storage
  static Future<bool> saveWishlist(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = products.map((p) => jsonEncode(p.toJson())).toList();
      return await prefs.setStringList(_wishlistKey, stringList);
    } catch (e) {
      debugPrint('Error saving wishlist to SharedPreferences: $e');
      return false;
    }
  }

  /// Clear all saved wishlist items
  static Future<bool> clearWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_wishlistKey);
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
      return false;
    }
  }

  static const String _guestIdKey = 'deallens_guest_device_id';

  /// Get or create a persistent guest user ID for unauthenticated Firestore sync
  static Future<String> getOrCreateGuestId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var id = prefs.getString(_guestIdKey);
      if (id == null || id.isEmpty) {
        id = 'guest_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 10000}';
        await prefs.setString(_guestIdKey, id);
      }
      return id;
    } catch (_) {
      return 'guest_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
