import 'dart:convert';

import 'package:get/get.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/categories/categories_controller.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../web_desktop_common/collection/collection_modal.dart';

class CollectionViewController extends GetxController {
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );
  final CollectionController collectionController = Get.put(
    CollectionController(),
  );

  var showSortMenu = false.obs;
  var showFilterMenu = false.obs;

  var productList = <Product>[].obs;
  var allProducts = <Product>[].obs;
  var isLoading = false.obs;
  var selectedCategoryId = 1.obs;
  var isHoveredList = <bool>[].obs;
  var wishlistStates = <bool>[].obs;
  var currentFilter = 'All'.obs;
  var currentCategoryName = 'All'.obs;
  var currentDescription =
      "/Craftsmanship is catalog involves many steps...".obs;

  @override
  void onInit() {
    super.onInit();
    initializeDescription();
  }

  void initializeStates(int count) {
    if (isHoveredList.length != count) {
      isHoveredList.assignAll(List.filled(count, false));
    }
    if (wishlistStates.length != count) {
      wishlistStates.assignAll(List.filled(count, false));
    }
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
    } catch (e) {
      print("Error fetching stock: $e");
    }
    return null;
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

  void onCategorySelected(int id, String name, String desc, {int? productIds}) {
    selectedCategoryId.value = id;
    currentCategoryName.value = name;
    currentDescription.value = desc;
    currentFilter.value = 'All';
    showSortMenu.value = false;
    showFilterMenu.value = false;

    if (name == "All") {
      // Fetch all products when "All" category is selected
      if (productIds != null) {
        fetchProducts(productIds);
      } else {
        productList.clear();
        collectionController.products.clear();
        initializeStates(0);
      }
    } else {
      // Fetch products based on specific category
      if (productIds != null) {
        fetchProductsByParams(productIds: productIds, categoryId: id);
      } else {
        productList.clear();
        collectionController.products.clear();
        initializeStates(0);
      }
    }
  }

  Future<void> fetchProductsByParams({
    required int productIds,
    required int categoryId,
  }) async {
    isLoading.value = true;
    try {
      final products = await ApiHelper.fetchBannerProductByCatIdAndId(
        productIds,
        categoryId,
      ).timeout(Duration(seconds: 10));
      _updateProductsList(products);
      for (var product in productList) {
        print("Collection Name For Cat id and Id: ${product.collectionName}");
      }
    } catch (e) {
      print('Error fetching products: $e');
      _updateProductsList([]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProducts(int productIds) async {
    isLoading.value = true;
    print('Fetching products with productIds: $productIds');
    try {
      final products = await ApiHelper.fetchBannerProductById(
        productIds,
      ).timeout(Duration(seconds: 10));
      allProducts.assignAll(products);
      productList.assignAll(products);
      collectionController.products.assignAll(productList);
      final selectedCategory = categoriesController.categories.firstWhere(
        (cat) => cat['id'] == selectedCategoryId.value,
        orElse: () => {'description': currentDescription.value},
      );
      currentDescription.value = selectedCategory['description'] as String;
      currentFilter.value = 'All';
      initializeStates(productList.length);
      for (var product in productList) {
        print("Collection Name: ${product.collectionName}");
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateProductsList(List<Product> products) {
    allProducts.assignAll(products);
    productList.assignAll(products);
    collectionController.products.assignAll(products);

    final selectedCategory = categoriesController.categories.firstWhere(
      (cat) => cat['id'] == selectedCategoryId.value,
      orElse: () => {'description': currentDescription.value},
    );
    currentDescription.value = selectedCategory['description'] as String;
    currentFilter.value = 'All';
    initializeStates(products.length);
  }

  Future<void> filterMakersChoice() async {
    isLoading.value = true;
    final filtered = allProducts.where((p) => p.isMakerChoice == 1).toList();
    _updateProductsList(filtered);
    currentFilter.value = "Maker's Choice";
    isLoading.value = false;
  }

  Future<void> filterFewPiecesLeft() async {
    isLoading.value = true;
    List<Product> filteredProducts = [];
    for (var product in allProducts) {
      final quantity = await fetchStockQuantity(product.id.toString());
      if (quantity != null && quantity < 2 && quantity > 0) {
        filteredProducts.add(product);
      }
    }
    _updateProductsList(filteredProducts);
    currentFilter.value = 'Few Pieces Left';
    isLoading.value = false;
  }

  void onHoverChanged(int index, bool isHovered) {
    isHoveredList[index] = isHovered;
    update();
  }

  void toggleWishlistState(int index, bool newState) {
    wishlistStates[index] = newState;
    update();
  }
}

class CollectionController extends GetxController {
  var products = <Product>[].obs;
}
