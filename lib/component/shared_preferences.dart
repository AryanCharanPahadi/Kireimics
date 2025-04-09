import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _productIdsKey = 'cart_product_ids';

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
    return ids.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
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
}
