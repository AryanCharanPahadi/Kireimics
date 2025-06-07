import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http show get;
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/shared_preferences/shared_preferences.dart';

import '../../component/app_routes/routes.dart';

class CheckoutController extends GetxController {
  var isLoading = false.obs;
  bool isChecked = false;

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
    isLoading(true);
    try {
      String? selectedAddress =
      await SharedPreferencesHelper.getSelectedAddress();
      if (selectedAddress != null) {
        final addressData = jsonDecode(selectedAddress);

        address1Controller.text = addressData['address1']?.toString() ?? '';
        address2Controller.text = addressData['address2']?.toString() ?? '';
        zipController.text = addressData['pincode']?.toString() ?? '';
        stateController.text = addressData['state']?.toString() ?? '';
        cityController.text = addressData['city']?.toString() ?? '';

        addressExists(true);
      } else {
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

                address1Controller.text =
                    addressData['address1']?.toString() ?? '';
                address2Controller.text =
                    addressData['address2']?.toString() ?? '';
                zipController.text = addressData['pincode']?.toString() ?? '';
                stateController.text = addressData['state']?.toString() ?? '';
                cityController.text = addressData['city']?.toString() ?? '';

                addressExists(true);
              }
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
  }
}