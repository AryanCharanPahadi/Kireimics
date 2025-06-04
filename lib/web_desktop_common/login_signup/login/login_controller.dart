import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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

  Future<bool> handleLogin(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        final response = await ApiHelper.loginUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        print("Login Response: $response");

        if (response['error'] == true) {
          loginMessage = response['message'] ?? "Login failed";
          return false;
        } else {
          var user = response['user'];

          if (user is Map) {
            int userId = user['id'] ?? 'Unknown User Id';
            String firstName = user['first_name'] ?? 'Unknown';
            String lastName = user['last_name'] ?? 'Unknown';
            String phone = user['phone'] ?? 'Unknown';
            String email = user['email'] ?? 'Unknown';
            String createdAt = user['createdAt'] ?? 'Unknown';

            String userDetails =
                '$userId, $firstName $lastName, $phone, $email, $createdAt';

            // Only save to SharedPreferences if rememberMe is true

            await SharedPreferencesHelper.saveUserData(userDetails);
            String? storedUser = await SharedPreferencesHelper.getUserData();
            print("Stored user data: $storedUser");

            emailController.clear();
            passwordController.clear();
            // Check if the current route is the checkout route
            final currentRoute =
                GoRouter.of(
                  context,
                ).routeInformationProvider.value.uri.toString();
            if (currentRoute.contains(AppRoutes.checkOut)) {
              final CheckoutController checkoutController = Get.put(
                CheckoutController(),
              );
              checkoutController.loadUserData();
              checkoutController.loadAddressData();
              // If on checkout route, pop the current screen (e.g., login dialog or page)
              Navigator.of(context).pop();
            } else {
              // Otherwise, navigate to the myAccount route
              context.go(AppRoutes.myAccount);
            }
            print('Login successful, user: $userDetails');
            return true;
          }
        }
      } catch (e) {
        print("Login exception: $e");
        loginMessage = "An error occurred during login";
        return false;
      }
    }

    loginMessage = "Please fill all fields correctly";
    return false;
  }
}
