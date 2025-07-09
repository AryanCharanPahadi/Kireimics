import 'package:get/get.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';

class FooterController extends GetxController {
  // Reactive variables using GetX
   String footerData = ''; // Nullable reactive Map
  final isLoading = true.obs; // Reactive boolean
  final errorMessage = ''.obs; // Reactive error message for UI feedback

  @override
  void onInit() {
    super.onInit();
    fetchFooterDetails(); // Fetch data when controller is initialized
  }

  Future<void> fetchFooterDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Clear previous errors

      final data = await ApiHelper.fetchFooterDetails();
      if (data != null) {
        footerData = data['footer_text']; // Update reactive variable
      } else {
        errorMessage.value = 'No footer data received';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching footer details: $e';
      // print(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Method to refresh data
  Future<void> refreshData() async {
    await footerData;
  }
}
