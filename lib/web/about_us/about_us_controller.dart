import 'package:get/get.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';

class AboutUsController extends GetxController {
  // Reactive variables using GetX
  final profileData = Rxn<Map<String, dynamic>>(); // Nullable reactive Map
  final isLoading = true.obs; // Reactive boolean
  final errorMessage = ''.obs; // Reactive error message for UI feedback

  @override
  void onInit() {
    super.onInit();
    fetchProfileDetails(); // Fetch data when controller is initialized
  }

  Future<void> fetchProfileDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Clear previous errors

      final data = await ApiHelper.fetchProfileDetails();
      if (data != null) {
        profileData.value = data; // Update reactive variable
      } else {
        errorMessage.value = 'No profile data received';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching profile details: $e';
      print(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Method to refresh data
  Future<void> refreshData() async {
    await fetchProfileDetails();
  }
}