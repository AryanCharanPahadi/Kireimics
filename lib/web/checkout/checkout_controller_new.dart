import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/shared_preferences/shared_preferences.dart';

class CheckoutControllerNew extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isChecked = false;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  var isPincodeLoading = false.obs;

  // Function to fetch PIN code data from the API
  Future<void> fetchPincodeData(String pincode) async {
    try {
      isPincodeLoading.value = true; // Set loading to true
      final data = await ApiHelper().fetchPincodeData(pincode);
      stateController.text = data['state'] ?? '';
      cityController.text = data['city'] ?? '';
    } catch (e) {
      stateController.text = '';
      cityController.text = '';
    } finally {
      isPincodeLoading.value = false; // Set loading to false when done
    }
  }

  Future<bool> isUserLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  var subtotal = 0.0.obs;

  Future<void> loadProductData(BuildContext context) async {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());

    subtotal.value =
        double.tryParse(uri.queryParameters['subtotal'] ?? '0.0') ?? 0.0;

  }

  String firstName = "";
  String lastName = "";
  String email = "";
  String phoneNumber = "";
  String? userId = "";
  var addressExists = false.obs;

  Future<void> loadUserData() async {
    String? storedUser = await SharedPreferencesHelper.getUserData();
    userId = await SharedPreferencesHelper.getUserId();

    if (storedUser != null) {
      List<String> userDetails = storedUser.split(', ');

      if (userDetails.length >= 4) {
        List<String> nameParts = userDetails[1].split(' ');
        firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        phoneNumber = userDetails[2];
        email = userDetails[3];
        // Populate the controllers with user data
        firstNameController.text = firstName;
        lastNameController.text = lastName;
        emailController.text = email;
        mobileController.text = phoneNumber;

      } else {
        print('Invalid user data format: $storedUser');
      }
    } else {
      print('No user data found in SharedPreferences');
    }
  }

  Future<void> checkIfDefaultAddressExists() async {
    userId = await SharedPreferencesHelper.getUserId();
    try {
      if (userId != null && userId!.isNotEmpty) {
        final response = await ApiHelper.getDefaultAddress(int.parse(userId!));
        if (response['error'] == false) {
          addressExists.value = true; // When response['error'] == false
          print(
            "This is the address from the new controller ${response['data']}",
          );
        } else {
          addressExists.value = false;
        }
      } else {
        print("No user id found");
      }
    } catch (e) {}
  }
}
