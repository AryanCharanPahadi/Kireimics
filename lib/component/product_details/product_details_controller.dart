import 'package:get/get.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/product_details/product_details_modal.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductList();
  }

  void fetchProductList() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await ApiHelper.fetchProducts();
      products.assignAll(result);
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
