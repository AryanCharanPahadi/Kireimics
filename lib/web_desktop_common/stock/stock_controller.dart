import 'package:get/get.dart';
import '../../component/api_helper/api_helper.dart';

class StockController extends GetxController {
  var stockQuantity = RxnInt(); // nullable int observable
  var isLoading = false.obs;

  Future<void> fetchStockQuantity(String productId) async {
    try {
      isLoading.value = true;
      var result = await ApiHelper.getStockDetail(productId);
      if (result['error'] == false && result['data'] != null) {
        for (var stock in result['data']) {
          if (stock['product_id'].toString() == productId) {
            stockQuantity.value = stock['quantity'];
            return;
          }
        }
      }
      stockQuantity.value = null;
    } catch (e) {
      print("Error fetching stock: $e");
      stockQuantity.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
