import 'package:get/get.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/categories/categories_controller.dart';
import 'package:kireimics/component/product_details/product_details_modal.dart';

import '../../component/shared_preferences/shared_preferences.dart';
import '../collection/collection_modal.dart';

class SaleController extends GetxController {
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );

  // Reactive variables
  var showSortMenu = false.obs;
  var showFilterMenu = false.obs;
  var isLoading = false.obs;
  var isCollectionView = false.obs;
  var selectedCategoryId = 1.obs;
  var currentFilter = 'All'.obs;
  var currentDescription =
      '/Craftsmanship is catalog involves many steps...'.obs;

  var collectionList = <CollectionModal>[].obs;
  var collectionAllProducts = <CollectionModal>[].obs;
  var productList = <Product>[].obs;
  var allProducts = <Product>[].obs;
  var filteredProductList = <Product>[].obs;
  var isHoveredList = <bool>[].obs;
  var wishlistStates = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllProducts();
    initializeDescription();
    initializeWishlistStates();
  }

  void initializeStates(int count) {
    if (isHoveredList.length != count) {
      isHoveredList.assignAll(List.filled(count, false));
    }
    if (wishlistStates.length != count) {
      wishlistStates.assignAll(List.filled(count, false));
    }
  }

  Future<void> initializeWishlistStates() async {
    update(); // Trigger UI update if needed
  }

  Future<void> initializeDescription() async {
    while (categoriesController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final defaultCategory = categoriesController.categories.firstWhere(
      (cat) => cat['id'] == selectedCategoryId.value,
      orElse: () => {'description': currentDescription.value},
    );

    currentDescription.value = defaultCategory['description'] as String;
  }

  Future<void> fetchAllProducts() async {
    isLoading.value = true;
    isCollectionView.value = false;

    final products = await ApiHelper.fetchProducts();
    allProducts.assignAll(products);
    productList.assignAll(products);
    filteredProductList.assignAll(
      products.where((product) => product.isSale == 1).toList(),
    );
    currentFilter.value = 'All';
    initializeStates(filteredProductList.length);
    isLoading.value = false;
  }

  Future<void> fetchProductsByCategoryId(int catId) async {
    isLoading.value = true;
    isCollectionView.value = false;

    final products = await ApiHelper.fetchProductByCatId(catId);
    final selectedCategory = categoriesController.categories.firstWhere(
      (cat) => cat['id'] == catId,
      orElse: () => {'description': currentDescription.value},
    );

    productList.assignAll(products);
    filteredProductList.assignAll(
      products.where((product) => product.isSale == 1).toList(),
    );
    currentDescription.value = selectedCategory['description'] as String;
    currentFilter.value = 'All';
    initializeStates(filteredProductList.length);
    isLoading.value = false;
  }

  Future<void> fetchCollectionListSort(int catId) async {
    isLoading.value = true;
    final collections = await ApiHelper.fetchCollectionBannerSort();
    collectionList.assignAll(collections ?? []);
    collectionAllProducts.assignAll(collections ?? []);
    currentFilter.value = 'All';
    initializeStates(collections?.length ?? 0);
    isLoading.value = false;
  }


  Future<void> fetchCollectionList(int catId) async {
    isLoading.value = true;
    isCollectionView.value = true;

    final collections = await ApiHelper.fetchCollectionBanner();
    collectionList.assignAll(collections ?? []);
    collectionAllProducts.assignAll(collections ?? []);
    currentFilter.value = 'All';
    initializeStates(collections?.length ?? 0);
    isLoading.value = false;
  }

  Future<int?> fetchStockQuantity(String productId) async {
    try {
      var result = await ApiHelper.getStockDetail(productId);
      if (result['error'] == false && result['data'] != null) {
        for (var stock in result['data']) {
          if (stock['product_id'].toString() == productId) {
            return stock['quantity'];
          }
        }
      }
      return null;
    } catch (e) {
      print("Error fetching stock: $e");
      return null;
    }
  }

  Future<void> filterMakersChoice() async {
    isLoading.value = true;

    final filteredProducts =
        allProducts
            .where(
              (product) => product.isSale == 1 && product.isMakerChoice == 1,
            )
            .toList();

    filteredProductList.assignAll(filteredProducts);
    currentFilter.value = "Maker's Choice";
    initializeStates(filteredProducts.length);
    isLoading.value = false;
  }

  Future<void> filterFewPiecesLeft() async {
    isLoading.value = true;

    List<Product> filteredProducts = [];
    for (var product in allProducts.where((p) => p.isSale == 1)) {
      final quantity = await fetchStockQuantity(product.id.toString());
      if (quantity != null && quantity < 2 && quantity > 0) {
        filteredProducts.add(product);
      }
    }

    filteredProductList.assignAll(filteredProducts);
    currentFilter.value = 'Few Pieces Left';
    initializeStates(filteredProducts.length);
    isLoading.value = false;
  }

  void sortProductsLowToHigh() {
    if (!isCollectionView.value) {
      filteredProductList.sort((a, b) => a.price.compareTo(b.price));
    }
  }

  void sortProductsHighToLow() {
    if (!isCollectionView.value) {
      filteredProductList.sort((a, b) => b.price.compareTo(a.price));
    }
  }

  void resetFilters() {
    if (isCollectionView.value) {
      collectionList.assignAll(collectionAllProducts);
    } else {
      filteredProductList.assignAll(
        allProducts.where((p) => p.isSale == 1).toList(),
      );
    }
    currentFilter.value = 'All';
  }

  void updateHoverState(int index, bool isHovered) {
    isHoveredList[index] = isHovered;
  }

  void updateCategory(int id, String name, String desc) {
    selectedCategoryId.value = id;
    currentDescription.value = desc;
    currentFilter.value = 'All';
    showSortMenu.value = false;
    showFilterMenu.value = false;

    if (name.toLowerCase() == 'all') {
      fetchAllProducts();
    } else if (name.toLowerCase() == 'collections') {
      fetchCollectionList(id);
    } else {
      fetchProductsByCategoryId(id);
    }
  }

  // Add to SaleController class
  void toggleWishlist(
    int index,
    String productId,
    Function(String)? onWishlistChanged,
  ) async {
    final isInWishlist = await SharedPreferencesHelper.isInWishlist(productId);
    if (isInWishlist) {
      await SharedPreferencesHelper.removeFromWishlist(productId);
      wishlistStates[index] = false;
      onWishlistChanged?.call('Product Removed From Wishlist');
    } else {
      await SharedPreferencesHelper.addToWishlist(productId);
      wishlistStates[index] = true;
      onWishlistChanged?.call('Product Added To Wishlist');
    }
  }
}
