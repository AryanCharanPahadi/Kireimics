import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart'; // Add GetX for state management
import '../../../component/api_helper/api_helper.dart';
import '../../../component/app_routes/routes.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/utilities/utility.dart';
import '../../../web/checkout/checkout_controller.dart';

class SignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final CheckoutController checkoutController = Get.put(CheckoutController());

  // Add loading state
  var isLoading = false.obs; // Observable boolean for loading state

  String signupMessage = '';

  @override
  void onClose() {
    disposeControllers();
    super.onClose();
  }

  void disposeControllers() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }

  Future<bool> handleSignUp(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      signupMessage = 'Please fill all fields correctly';
      return false;
    }

    isLoading.value = true; // Start loading
    update(); // Notify UI of state change

    final String email = emailController.text.trim();
    final String formattedDate = getFormattedDate();

    try {
      final response = await ApiHelper.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: email,
        phone: phoneController.text.trim(),
        createdAt: formattedDate,
      );

      if (response['error'] == true) {
        signupMessage = response['message'] ?? 'Signup failed';
        isLoading.value = false; // Stop loading
        update();
        return false;
      }

      final mailResponse = await ApiHelper.registerMail(email: email);
      print('Register Mail Response: $mailResponse');

      final String apiUrl =
          'https://vedvika.com/v1/apis/common/user_data/get_user_data.php?email=$email';
      final http.Response apiResponse = await http.get(Uri.parse(apiUrl));

      if (apiResponse.statusCode != 200) {
        signupMessage = 'Failed to fetch user data';
        isLoading.value = false; // Stop loading
        update();
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(apiResponse.body);

      if (responseData['error'] == true || responseData['data'].isEmpty) {
        signupMessage = 'Failed to fetch user data';
        isLoading.value = false; // Stop loading
        update();
        return false;
      }

      final userData = responseData['data'][0];
      int userId = userData['id'] ?? -1;
      String firstName = userData['first_name'] ?? 'Unknown';
      String lastName = userData['last_name'] ?? 'Unknown';
      String phone = userData['phone'] ?? 'Unknown';
      String createdAt = userData['createdAt'] ?? formattedDate;

      String userDetails =
          '$userId, $firstName $lastName, $phone, $email, $createdAt';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
      await SharedPreferencesHelper.saveUserData(userDetails);

      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
      signupMessage = 'Signup successfully';
      final currentRoute =
      GoRouter.of(context).routeInformationProvider.value.uri.toString();

      if (currentRoute.contains(AppRoutes.checkOut)) {
        // Load user data and address data
        await checkoutController.loadUserData();
        await checkoutController.loadAddressData();


      }

      isLoading.value = false; // Stop loading
      update();
      return true;
    } catch (e) {
      signupMessage = 'An error occurred during signup';
      isLoading.value = false; // Stop loading
      update();
      return false;
    }
  }
}