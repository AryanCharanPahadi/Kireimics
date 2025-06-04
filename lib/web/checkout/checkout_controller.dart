// lib/controller/address_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/shared_preferences/shared_preferences.dart';

class CheckoutController extends GetxController {
  var isLoading = false.obs;
  var addressExists = false.obs;

  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  void onClose() {
    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.onClose();
  }

  Future<void> loadAddressData() async {
    isLoading(true);
    try {
      String? storedUser = await SharedPreferencesHelper.getUserData();
      if (storedUser != null) {
        List<String> userDetails = storedUser.split(', ');
        if (userDetails.isNotEmpty) {
          int userId = int.tryParse(userDetails[0]) ?? 0;

          if (userId > 0) {
            final response = await ApiHelper.getDefaultAddress(userId);
            if (response['error'] == false &&
                response['data'] != null &&
                response['data'].isNotEmpty) {
              final addressData = response['data'][0];

              address1Controller.text = addressData['address1']?.toString() ?? '';
              address2Controller.text = addressData['address2']?.toString() ?? '';
              zipController.text = addressData['pincode']?.toString() ?? '';
              stateController.text = addressData['state']?.toString() ?? '';
              cityController.text = addressData['city']?.toString() ?? '';

              addressExists(true);
            }
          }
        }
      }
    } catch (e) {
      print('Error loading address: $e');
    } finally {
      isLoading(false);
    }
  }
}