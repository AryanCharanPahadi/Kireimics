import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../../../component/api_helper/api_helper.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../web/checkout/checkout_controller.dart';

class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String loginMessage = "";

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  final CheckoutController checkoutController = Get.put(CheckoutController());

  Future<bool> handleLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      loginMessage = "Please fill all fields correctly";
      return false;
    }

    try {
      final response = await ApiHelper.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // print("Login Response: $response");

      if (response['error'] == true) {
        loginMessage = response['message'] ?? "Login failed";
        return false;
      }

      var user = response['user'];
      if (user is Map) {
        int userId = user['id'] ?? -1;
        String firstName = user['first_name'] ?? 'Unknown';
        String lastName = user['last_name'] ?? 'Unknown';
        String phone = user['phone'] ?? 'Unknown';
        String email = user['email'] ?? 'Unknown';
        String createdAt = user['createdAt'] ?? 'Unknown';

        String userDetails =
            '$userId, $firstName $lastName, $phone, $email, $createdAt';

        await SharedPreferencesHelper.saveUserData(userDetails);
        // print("Stored user data: $userDetails");

        checkoutController.isLoggedIn.value = true;
        emailController.clear();
        passwordController.clear();

        final currentRoute =
            GoRouter.of(context).routeInformationProvider.value.uri.toString();

        if (currentRoute.contains(AppRoutes.checkOut)) {
          // Load user data and address data
          await checkoutController.loadUserData();
          await checkoutController.loadAddressData();

          // If address exists, SelectAddress will be shown in CheckoutPageWeb
          // If no address, user data is already loaded, and form will be shown
          Navigator.of(context).pop();
        }

        // print('Login successful, user: $userDetails');
        return true;
      } else {
        loginMessage = "Invalid user data received";
        return false;
      }
    } catch (e) {
      // print("Login exception: $e");
      loginMessage = "An error occurred during login";
      return false;
    }
  }
}
