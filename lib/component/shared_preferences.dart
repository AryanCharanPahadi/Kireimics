import 'package:shared_preferences/shared_preferences.dart';

import 'cart_loader.dart';

class SharedPreferencesHelper {
  static const String _productIdsKey = 'cart_product_ids';
  static const _wishlistKey = 'wishlist_items';

  // Save a new product ID (append to existing ones, avoid duplicates)
  static Future<void> addProductId(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentIds = prefs.getStringList(_productIdsKey) ?? [];
    if (!currentIds.contains(productId.toString())) {
      currentIds.add(productId.toString());
      await prefs.setStringList(_productIdsKey, currentIds);
    }
  }

  // Get all product IDs
  static Future<List<int>> getAllProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = prefs.getStringList(_productIdsKey) ?? [];
    return ids
        .map((id) => int.tryParse(id) ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  // Remove a product ID
  static Future<void> removeProductId(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentIds = prefs.getStringList(_productIdsKey) ?? [];
    currentIds.remove(productId.toString());
    await prefs.setStringList(_productIdsKey, currentIds);
  }

  // Clear all cart items
  static Future<void> clearAllProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productIdsKey);
  }

  static Future<void> addToWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = await getWishlist();
    if (!wishlist.contains(productId)) {
      wishlist.add(productId);
      await prefs.setStringList(_wishlistKey, wishlist);
    }
    print('Current wishlist: $wishlist');
  }

  static Future<void> removeFromWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = await getWishlist();
    wishlist.remove(productId);
    await prefs.setStringList(_wishlistKey, wishlist);
    print('Current wishlist: $wishlist');
  }

  static Future<List<String>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_wishlistKey) ?? [];
  }

  // Check if a product is in wishlist
  static Future<bool> isInWishlist(String productId) async {
    final wishlist = await getWishlist();
    return wishlist.contains(productId);
  }

  static Future<void> clearWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wishlistKey);
  }
}
