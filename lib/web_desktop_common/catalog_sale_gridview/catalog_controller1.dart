import 'package:get/get.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/categories/categories_controller.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../web_desktop_common/collection/collection_modal.dart';

class CatalogPageController extends GetxController {
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );
  final CatalogController catalogController = Get.put(CatalogController());
  var isCollectionProductView =
      false.obs; // New flag to track collection product view
  var showSortMenu = false.obs;
  var showFilterMenu = false.obs;

  var productList = <Product>[].obs;
  var allProducts = <Product>[].obs;
  var collectionList = <CollectionModal>[].obs;
  var collectionAllProducts = <CollectionModal>[].obs;
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
    // Implement wishlist state initialization if needed
    update();
  }

  Future<void> fetchAllProducts() async {
    isLoading.value = true;
    final products = await ApiHelper.fetchProducts();
    allProducts.assignAll(products);
    productList.assignAll(products);
    catalogController.products.assignAll(products);
    currentFilter.value = 'All';
    initializeStates(products.length);
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
      // print("Error fetching stock: $e");
      return null;
    }
  }

  Future<void> filterMakersChoice() async {
    isLoading.value = true;
    List<Product> filteredProducts =
        allProducts.where((product) => product.isMakerChoice == 1).toList();
    productList.assignAll(filteredProducts);
    catalogController.products.assignAll(filteredProducts);
    currentFilter.value = "Maker's Choice";
    initializeStates(filteredProducts.length);
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
    productList.assignAll(filteredProducts);
    catalogController.products.assignAll(filteredProducts);
    currentFilter.value = 'Few Pieces Left';
    initializeStates(filteredProducts.length);
    isLoading.value = false;
  }

  Future<void> fetchProductsByCategoryId(int catId) async {
    isLoading.value = true;
    if (isCollectionProductView.value) {
      // If in collection product view, use productList directly (already set by CollectionGrid)
      catalogController.products.assignAll(productList);
    } else {
      final products = await ApiHelper.fetchProductByCatId(catId);
      allProducts.assignAll(products);
      productList.assignAll(products);
      catalogController.products.assignAll(products);
    }
    final selectedCategory = categoriesController.categories.firstWhere(
      (cat) => cat['id'] == catId,
      orElse: () => {'catalog_description': currentDescription.value},
    );
    currentDescription.value =
        selectedCategory['catalog_description'] as String;
    currentFilter.value = 'All';
    initializeStates(productList.length);
    isLoading.value = false;
  }

  Future<void> fetchCollectionList(int catId) async {
    isLoading.value = true;
    final collections = await ApiHelper.fetchCollectionBanner();
    collectionList.assignAll(collections ?? []);
    collectionAllProducts.assignAll(collections ?? []);
    currentFilter.value = 'All';
    initializeStates(collections?.length ?? 0);
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

  Future<void> initializeDescription() async {
    while (categoriesController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final defaultCategory = categoriesController.categories.firstWhere(
      (cat) => cat['id'] == selectedCategoryId.value,
      orElse: () => {'catalog_description': currentDescription.value},
    );
    currentDescription.value = defaultCategory['catalog_description'] as String;
  }

  void onCategorySelected(int id, String name, String desc) {
    selectedCategoryId.value = id;
    currentCategoryName.value = name;
    currentDescription.value = desc;
    currentFilter.value = 'All';
    showSortMenu.value = false;
    showFilterMenu.value = false;
    isCollectionProductView.value = false; // Reset collection product view
    if (name.toLowerCase() == 'all') {
      fetchAllProducts();
    } else if (name.toLowerCase() == 'collections') {
      fetchCollectionList(id);
    } else {
      fetchProductsByCategoryId(id);
    }
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

class CatalogController extends GetxController {
  var products = <Product>[].obs;
}
