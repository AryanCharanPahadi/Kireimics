import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http show Response, get;
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/shared_preferences/shared_preferences.dart';
import 'package:kireimics/web_desktop_common/add_address_ui/add_address_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../component/app_routes/routes.dart';
import '../../component/utilities/utility.dart';

class CheckoutController extends GetxController {
  var isLoading = false.obs;
  bool isChecked = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String signupMessage = "";
  var addressExists = false.obs;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  var productIds = <String>[].obs; // New observable list for productIds

  // Callbacks for wishlist changes
  Function(String)? onWishlistChanged;
  Function(String)? onErrorWishlistChanged;

  // Method to set callbacks
  void setCallbacks({
    Function(String)? onWishlistChanged,
    Function(String)? onErrorWishlistChanged,
  }) {
    this.onWishlistChanged = onWishlistChanged;
    this.onErrorWishlistChanged = onErrorWishlistChanged;
  }

  @override
  void onClose() {
    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.onClose();
  }

  var isPincodeLoading = false.obs;

  // New method to load productIds from route query parameters
  void loadProductIds(BuildContext context) {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    productIds.value = uri.queryParameters['productIds']?.split(',') ?? [];
    print('Product IDs loaded in CheckoutController: ${productIds.value}');
  }

  Future<void> fetchPincodeData(String pincode) async {
    try {
      isPincodeLoading.value = true;
      final data = await ApiHelper().fetchPincodeData(pincode);
      stateController.text = data['state'] ?? '';
      cityController.text = data['city'] ?? '';
    } catch (e) {
      stateController.text = '';
      cityController.text = '';
    } finally {
      isPincodeLoading.value = false;
    }
  }

  Future<void> loadAddressData() async {
    try {
      isLoading.value = true;

      // Step 1: Check if a selected address ID exists in SharedPreferences
      String? selectedAddressId =
          await SharedPreferencesHelper.getSelectedAddress();
      print('Selected Address ID in SharedPreferences: $selectedAddressId');

      if (selectedAddressId != null && selectedAddressId.isNotEmpty) {
        // Fetch address data by ID from API
        final response = await ApiHelper.getUserAddressById(selectedAddressId);
        print('API Response for getUserAddress($selectedAddressId): $response');
        if (response['error'] == false && response['data'] != null) {
          final data = response['data'][0];

          // Populate address-related controllers with selected address data
          address1Controller.text = data['address1']?.toString() ?? '';
          address2Controller.text = data['address2']?.toString() ?? '';
          zipController.text = data['pincode']?.toString() ?? '';
          stateController.text = data['state']?.toString() ?? '';
          cityController.text = data['city']?.toString() ?? '';
          addressExists.value = true;
          print(
            'Populated address from SharedPreferences ID: $selectedAddressId',
          );
          return; // Exit after populating with selected address
        } else {
          // Clear controllers if selected address ID is invalid or not found
          print(
            'Invalid or not found address ID: $selectedAddressId, clearing SharedPreferences',
          );
          address1Controller.clear();
          address2Controller.clear();
          zipController.clear();
          stateController.clear();
          cityController.clear();
          addressExists.value = false;
          // Clear the invalid selected address ID from SharedPreferences
          await SharedPreferencesHelper.clearSelectedAddress();
        }
      } else {
        print(
          'No valid address ID in SharedPreferences, checking default address',
        );
      }

      // Step 2: If no valid selected address ID, try fetching the default address
      String? storedUser = await SharedPreferencesHelper.getUserData();
      if (storedUser != null && storedUser.isNotEmpty) {
        List<String> userDetails = storedUser.split(', ');
        if (userDetails.isNotEmpty) {
          int userId = int.tryParse(userDetails[0]) ?? 0;
          if (userId > 0) {
            print('Fetching default address for userId: $userId');
            final response = await ApiHelper.getDefaultAddress(userId);
            print('API Response for getDefaultAddress($userId): $response');
            if (response['error'] == false &&
                response['data'] != null &&
                response['data'].isNotEmpty) {
              final data = response['data'][0];

              // Populate address-related controllers with default address
              address1Controller.text = data['address1']?.toString() ?? '';
              address2Controller.text = data['address2']?.toString() ?? '';
              zipController.text = data['pincode']?.toString() ?? '';
              stateController.text = data['state']?.toString() ?? '';
              cityController.text = data['city']?.toString() ?? '';
              addressExists.value = true;
              print(
                'Populated address from default address for userId: $userId',
              );
              return; // Exit after populating with default address
            } else {
              print('No valid default address found for userId: $userId');
            }
          } else {
            print('Invalid userId: $userId');
          }
        } else {
          print('No user details found in storedUser: $storedUser');
        }
      } else {
        print('No stored user data found');
      }

      // Step 3: If no data from SharedPreferences or default address, clear controllers
      print('No address data available, clearing controllers');
      address1Controller.clear();
      address2Controller.clear();
      zipController.clear();
      stateController.clear();
      cityController.clear();
      addressExists.value = false;
    } catch (e) {
      print('Error loading address data: $e');
      // Clear controllers on error
      address1Controller.clear();
      address2Controller.clear();
      zipController.clear();
      stateController.clear();
      cityController.clear();
      addressExists.value = false;
      // Only clear SharedPreferences if the error is related to an invalid address ID
      print('Clearing SharedPreferences due to error');
      await SharedPreferencesHelper.clearSelectedAddress();
    } finally {
      isLoading.value = false;
      print('Finished loading address data');
    }
  }

  Future<void> refreshDefaultAddress() async {
    try {
      isLoading.value = true;
      await loadAddressData(); // Reuse the existing loadAddressData logic
      // Get.snackbar(
      //   'Success',
      //   'Address refreshed successfully',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } catch (e) {
      print('Error refreshing address: $e');
      // Get.snackbar(
      //   'Error',
      //   'Failed to refresh address',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserData() async {
    String? storedUser = await SharedPreferencesHelper.getUserData();
    if (storedUser != null) {
      List<String> userDetails = storedUser.split(', ');
      if (userDetails.length >= 4) {
        List<String> nameParts = userDetails[1].split(' ');
        String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        String lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        String phone = userDetails[2];
        String email = userDetails[3];

        firstNameController.text = firstName;
        lastNameController.text = lastName;
        emailController.text = email;
        mobileController.text = phone;
      }
    }
  }

  Future<bool> handleSignUp(BuildContext context) async {
    print("Signup process started");

    if (!formKey.currentState!.validate()) {
      signupMessage = "Please fill all fields correctly";
      print("Form validation failed: $signupMessage");
      return false;
    }

    final String email = emailController.text.trim();
    final String formattedDate = getFormattedDate();
    print("Collected email: $email");
    print("Formatted date: $formattedDate");

    try {
      print("Calling registerUser API...");
      final response = await ApiHelper.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: email,
        phone: mobileController.text.trim(),
        createdAt: formattedDate,
      );

      print("Signup API response: $response");

      if (response['error'] == true) {
        signupMessage = response['message'] ?? "Signup failed";
        print("Signup failed with message: $signupMessage");
        return false;
      }

      final String apiUrl =
          'https://vedvika.com/v1/apis/common/user_data/get_user_data.php?email=$email';
      print("Fetching user data from: $apiUrl");

      final http.Response apiResponse = await http.get(Uri.parse(apiUrl));
      print("User data fetch status code: ${apiResponse.statusCode}");

      if (apiResponse.statusCode != 200) {
        signupMessage = "Failed to fetch user data";
        print("HTTP error: $signupMessage");
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(apiResponse.body);
      print("Decoded user data response: $responseData");

      if (responseData['error'] == true || responseData['data'].isEmpty) {
        signupMessage = "Failed to fetch user data";
        print(
          "User data API returned error or empty data: ${responseData['message']}",
        );
        return false;
      }

      final userData = responseData['data'][0];
      print("Extracted user data: $userData");

      int userId = userData['id'] ?? -1;
      String firstName = userData['first_name'] ?? 'Unknown';
      String lastName = userData['last_name'] ?? 'Unknown';
      String phone = userData['phone'] ?? 'Unknown';
      String createdAt = userData['createdAt'] ?? formattedDate;

      String userDetails =
          '$userId, $firstName $lastName, $phone, $email, $createdAt';
      print("Formatted user details string: $userDetails");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
      print("User authenticated flag set to true");

      await SharedPreferencesHelper.saveUserData(userDetails);
      print("User details saved to SharedPreferences");

      String? storedUser = await SharedPreferencesHelper.getUserData();
      print("Retrieved user data from SharedPreferences: $storedUser");

      // Call handleAddAddress after successful signup
      print("Calling handleAddAddress...");
      bool addressAdded = await handleAddAddress(context);
      if (!addressAdded) {
        print("Failed to add address after signup");
        signupMessage = "Signup successful, but failed to add address";
        // Optional: return false or proceed
      } else {
        print("Address added successfully after signup");
        signupMessage = "Signup and address addition successful";
      }

      print("Navigating to MyAccount page...");
      // context.go(AppRoutes.myAccount);

      return true;
    } catch (e) {
      print("Exception during signup: $e");
      signupMessage = "An error occurred during signup";
      return false;
    }
  }

  Future<bool> handleAddAddress(
    BuildContext context, {
    bool isEditing = false,
    String? addressId,
  }) async {
    final AddAddressController addAddressController = Get.put(
      AddAddressController(),
    );

    if (formKey.currentState!.validate()) {
      String formattedDate = getFormattedDate();
      String? userId = await SharedPreferencesHelper.getUserId();

      try {
        var response;
        {
          // Add new address
          response = await ApiHelper.registerAddress(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text.trim(),
            phone: mobileController.text.trim(),
            address1: address1Controller.text,
            address2: address2Controller.text,
            state: stateController.text,
            pinCode: zipController.text,
            city: cityController.text,
            updatedAt: 'null',
            defaultAddress: "1",
            createdBy: userId.toString(),
            createdAt: formattedDate,
          );
        }

        print("${isEditing ? 'Update' : 'Add'} address Response: $response");

        if (response['error'] == true) {
          signupMessage =
              response['message'] ??
              "${isEditing ? 'Update' : 'Add'} address failed";
          return false;
        } else {
          // Success case
          signupMessage =
              isEditing
                  ? "Address updated successfully"
                  : "Address added successfully";
          await addAddressController.fetchAddress();
          loadAddressData();

          return true;
        }
      } catch (e) {
        print("${isEditing ? 'Update' : 'Add'} address exception: $e");
        signupMessage =
            "An error occurred while ${isEditing ? 'updating' : 'adding'} the address";
        return false;
      }
    } else {
      signupMessage = "Please fill all fields correctly";
      return false;
    }
  }

  void openRazorpayCheckout(
    BuildContext context,
    double total,
    String orderId,
  ) async {
    print('openRazorpayCheckout called in CheckoutController');

    if (!js.context.hasProperty('openRazorpay')) {
      print('Error: openRazorpay function not found in JavaScript context');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Payment system not initialized')),
      );
      return;
    }

    final options = {
      'key': 'rzp_test_PKUyVj9nF0FvA7',
      'amount': (total * 100).toInt(),
      'currency': 'INR',
      'name': 'Kireimics',
      'description': 'Payment for order',
      'prefill': {
        'name': firstNameController.text,
        'email': emailController.text,
        'contact': mobileController.text,
      },
      'notes': {'address': 'Customer address'},
      'handler': js.allowInterop((response) async {
        final responseJson = js.context['JSON'].callMethod('stringify', [
          response,
        ]);

        final paymentId = response['razorpay_payment_id'] ?? 'N/A';
        final orderIdResponse = response['razorpay_order_id'] ?? orderId;
        final signature = response['razorpay_signature'] ?? 'N/A';
        final amount = total;
        final status = 'success';

        print('=== Payment Successful ===');
        print('Payment ID: $paymentId');
        print('Order ID: $orderIdResponse');
        print('Signature: $signature');
        print('Amount: $amount INR');
        print('Status: $status');
        print('Raw Client-Side Response: $responseJson');
        // Clear product IDs from SharedPreferences after successful payment
        await SharedPreferencesHelper.clearAllProductIds();
        print('Cleared product IDs from SharedPreferences');
        try {
          final serverResponse = await http.get(
            Uri.parse(
              'http://localhost/17000ft/payment_details.php?payment_id=$paymentId',
            ),
          );

          if (serverResponse.statusCode == 200) {
            final paymentDetails = jsonDecode(serverResponse.body);
            print('=== Full Payment Details ===');
            print('Full Raw Response: ${jsonEncode(paymentDetails)}');
            print('Mode of Payment: ${paymentDetails['method'] ?? 'N/A'}');
            print('Payment ID: ${paymentDetails['id'] ?? 'N/A'}');
            print('Order ID: ${paymentDetails['order_id'] ?? 'N/A'}');
            print(
              'Amount: ${(paymentDetails['amount'] / 100).toStringAsFixed(2)} ${paymentDetails['currency'] ?? 'N/A'}',
            );
            print('Status: ${paymentDetails['status'] ?? 'N/A'}');
            print(
              'Created At: ${DateTime.fromMillisecondsSinceEpoch((paymentDetails['created_at'] * 1000) ?? 0)}',
            );
          } else {
            print('Failed to fetch payment details: ${serverResponse.body}');
          }
        } catch (e) {
          print('Error fetching payment details: $e');
        }

        context.go(
          '${AppRoutes.paymentResult}?success=true&orderId=$orderId&amount=$total',
        );
      }),
      'modal': {
        'ondismiss': js.allowInterop(() {
          print('Payment modal dismissed');
          context.go(
            '${AppRoutes.paymentResult}?success=false&orderId=$orderId&amount=$total',
          );
        }),
      },
    };

    print('Razorpay options: $options');

    try {
      print('Calling js.context.callMethod for openRazorpay');
      js.context.callMethod('openRazorpay', [js.JsObject.jsify(options)]);
    } catch (e) {
      print('Error initiating payment: $e');
    }
  }

  void reset() {
    isLoading(false);
    addressExists(false);
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    mobileController.clear();
    address1Controller.clear();
    address2Controller.clear();
    zipController.clear();
    stateController.clear();
    cityController.clear();
    productIds.clear(); // Clear productIds
  }
}
