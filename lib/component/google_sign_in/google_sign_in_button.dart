import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api_helper/api_helper.dart';
import '../app_routes/routes.dart';
import '../shared_preferences/shared_preferences.dart';
import 'auth.dart';

class GoogleSignInButton extends StatelessWidget {
  final String functionName;

  const GoogleSignInButton({super.key, required this.functionName});

  String getFormattedDate() {
    return DateTime.now().toIso8601String();
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      User? user = await signInWithGoogle();
      if (user != null) {
        String? name = user.displayName;
        String? userEmail = user.email;

        // Split name
        List<String> nameParts = (name ?? "").split(" ");
        String firstName = nameParts.isNotEmpty ? nameParts[0] : 'Unknown';
        String lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(" ") : 'Unknown';

        String phone = user.phoneNumber ?? 'Unknown';
        String formattedDate = getFormattedDate();

        // Call register API
        final response = await ApiHelper.registerUser(
          firstName: firstName,
          lastName: lastName,
          email: userEmail ?? 'unknown@gmail.com',
          phone: phone,
          password: 'google_login', // Dummy password
          createdAt: formattedDate,
        );

        // Handle backend response
        if (response['error'] == true) {
          print("Register error: ${response['message']}");
        } else {
          print("User registered successfully via Google login");
        }

        final String apiUrl =
            'https://vedvika.com/v1/apis/common/user_data/get_user_data.php?email=$userEmail';
        try {
          final http.Response apiResponse = await http.get(Uri.parse(apiUrl));
          if (apiResponse.statusCode == 200) {
            final Map<String, dynamic> responseData = json.decode(
              apiResponse.body,
            );

            if (responseData['error'] == false &&
                responseData['data'].isNotEmpty) {
              final userData = responseData['data'][0];

              int userId = userData['id'] ?? 'Unknown User Id';
              String firstName = userData['first_name'] ?? 'Unknown';
              String lastName = userData['last_name'] ?? 'Unknown';
              String phone = userData['phone'] ?? 'Unknown';
              String email =
                  userData['email'] ?? userEmail ?? 'unknown@gmail.com';
              String createdAt = userData['createdAt'] ?? formattedDate;

              // Save fetched data to SharedPreferences
              String userDetails =
                  '$userId, $firstName $lastName, $phone, $email, $createdAt';
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('auth', true);
              await SharedPreferencesHelper.saveUserData(userDetails);

              String? storedUser = await SharedPreferencesHelper.getUserData();
              print("Stored user data from API: $storedUser");

              context.go(AppRoutes.myAccount);
            } else {
              print("Failed to fetch user data: ${responseData['message']}");
            }
          } else {
            print("API request failed with status: ${apiResponse.statusCode}");
          }
        } catch (e) {
          print("Error fetching data from API: $e");
        }

        context.go(AppRoutes.myAccount);
      } else {
        print('Google Sign-In failed');
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleGoogleSignIn(context),
      child: SvgPicture.asset(
        "assets/icons/googleLogin.svg",
        height: 24,
        width: 24,
      ),
    );
  }
}
