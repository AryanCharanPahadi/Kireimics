import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _productIdsKey = 'cart_product_ids';
  static const _wishlistKey = 'wishlist_items';
  static const String _selectedAddressKey = 'selectedAddress';
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

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> saveUserData(String user) async {
    final prefs = await _getPrefs();
    await prefs.setString('user', user);
  }

  // Get user data from SharedPreferences
  static Future<String?> getUserData() async {
    final prefs = await _getPrefs();
    return prefs.getString('user');
  }

  // Clear user data from SharedPreferences
  static Future<void> clearUserData() async {
    final prefs = await _getPrefs();
    await prefs.remove('user');
  }

  Future<bool> isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  // Get user ID from stored user data
  static Future<String?> getUserId() async {
    final userData = await getUserData();
    if (userData == null || userData.isEmpty) return null;
    try {
      // Split the user data string by comma and take the first element (userId)
      final userId = userData.split(',')[0].trim();
      return userId.isNotEmpty ? userId : null;
    } catch (e) {
      print('Error parsing user ID: $e');
      return null;
    }
  }

  static Future<void> saveSelectedAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedAddressKey, address);
  }

  // Get selected address
  static Future<String?> getSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedAddressKey);
  }

  // Clear selected address
  static Future<void> clearSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedAddressKey);
  }

}
