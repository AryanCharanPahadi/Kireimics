import 'package:get/get.dart';
import '../../component/api_helper/api_helper.dart';

class SaleCategoriesController extends GetxController {
  var categories = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() async {
    isLoading.value = true;

    final data = await ApiHelper.fetchSaleCategoriesData();
    if (data != null) {
      categories.value = List<Map<String, dynamic>>.from(data);
    }

    isLoading.value = false;
  }
}
