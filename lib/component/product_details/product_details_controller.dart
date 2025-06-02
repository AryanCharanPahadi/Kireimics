import 'package:get/get.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/product_details/product_details_modal.dart';

import '../shared_preferences/shared_preferences.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  String _currentQuery = ''; // Store the current query

  @override
  void onInit() {
    super.onInit();
    fetchProductList();
  }

  Future<void> fetchProductList() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await ApiHelper.fetchProducts();
      products.assignAll(result);
      // Do not initialize filteredProducts here; let filterProducts handle it
      // Reapply the current query if it exists
      filterProducts(_currentQuery);
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void filterProducts(String query) {
    _currentQuery = query; // Store the query for reapplication
    filteredProducts.clear(); // Clear previous results
    if (query.isEmpty) {
      filteredProducts.assignAll(
        products,
      ); // Show all products if query is empty
      return;
    }
    final lowerQuery = query.toLowerCase();
    filteredProducts.assignAll(
      products.where((product) {
        final name = product.name.toLowerCase();
        final tag = product.tag.toLowerCase();
        return name.contains(lowerQuery) || tag.contains(lowerQuery);
      }).toList(),
    );
  }

  // Optional: Method to reset filter state
  void resetFilter() {
    filteredProducts.clear();
    _currentQuery = '';
  }
  var wishlistStatus = <String, bool>{}.obs;

  // Initialize wishlist status for a product
  void initWishlistStatus(String productId) async {
    bool isInWishlist = await SharedPreferencesHelper.isInWishlist(productId);
    wishlistStatus[productId] = isInWishlist;
  }

  // Toggle wishlist status
  Future<void> toggleWishlist(String productId, Function(String)? onWishlistChanged) async {
    bool currentStatus = wishlistStatus[productId] ?? false;
    if (currentStatus) {
      await SharedPreferencesHelper.removeFromWishlist(productId);
      wishlistStatus[productId] = false;
      onWishlistChanged?.call('Product Removed From Wishlist');
    } else {
      await SharedPreferencesHelper.addToWishlist(productId);
      wishlistStatus[productId] = true;
      onWishlistChanged?.call('Product Added To Wishlist');
    }
  }

}
