import 'package:flutter/material.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/utilities/utility.dart';

class SignupController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }

  String signupMessage = ""; // Add this

  Future<bool> handleSignUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      String formattedDate = getFormattedDate();

      try {
        final response = await ApiHelper.registerUser(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          password: passwordController.text.trim(),
          createdAt: formattedDate,
        );

        // Print the full API response
        print("Signup Response: $response");

        if (response['error'] == true) {
          // Optionally print error message
          signupMessage =
              response['message'] ?? "Signup failed"; // Store the message
          return false;
        } else {
          // Clear controllers after successful sign up
          firstNameController.clear();
          lastNameController.clear();
          emailController.clear();
          phoneController.clear();
          passwordController.clear();

       return true;
        }
      } catch (e) {
        print("Signup exception: $e");
        signupMessage =
            "An error occurred during signup"; // Store generic error

        return false;
      }
    }
    signupMessage =
        "Please fill all fields correctly"; // Validation failed message

    return false;
  }
}
