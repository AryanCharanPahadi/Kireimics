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
  var productIds = <String>[].obs;
  var quantities = <String>[].obs;
  var heights = <String>[].obs;
  var weights = <String>[].obs;
  var breadths = <String>[].obs;
  var lengths = <String>[].obs;
  Function(String)? onWishlistChanged;
  Function(String)? onErrorWishlistChanged;
  var isPincodeLoading = false.obs;
  var totalDeliveryCharge = 0.0.obs; // Reactive delivery charge
  // Track the last processed pincode to avoid duplicate API calls
  String? lastProcessedPincode;

  void setCallbacks({
    Function(String)? onWishlistChanged,
    Function(String)? onErrorWishlistChanged,
  }) {
    this.onWishlistChanged = onWishlistChanged;
    this.onErrorWishlistChanged = onErrorWishlistChanged;
  }

  @override
  void onInit() {
    super.onInit();
    zipController.addListener(() {
      final pincode = zipController.text.trim();
      if (pincode.length == 6 && RegExp(r'^\d{6}$').hasMatch(pincode)) {
        if (pincode != lastProcessedPincode) {
          fetchPincodeData(pincode);
        }
      }
    });
  }

  @override
  void onClose() {
    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    stateController.dispose();
    cityController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  Future<void> loadProductIds(BuildContext context) async {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());

    final ids = uri.queryParameters['productIds']?.split(',') ?? [];
    final qtys = uri.queryParameters['quantities']?.split(',') ?? [];
    final heightList = uri.queryParameters['height']?.split(',') ?? [];
    final weightList = uri.queryParameters['weights']?.split(',') ?? [];
    final breadthList = uri.queryParameters['breadths']?.split(',') ?? [];
    final lengthList = uri.queryParameters['lengths']?.split(',') ?? [];

    productIds.value = ids;
    quantities.value = qtys;
    heights.value = heightList;
    weights.value = weightList;
    breadths.value = breadthList;
    lengths.value = lengthList;
  }

  Future<void> fetchPincodeData(String pincode) async {
    try {
      isPincodeLoading.value = true;
      lastProcessedPincode = pincode;
      final data = await ApiHelper().fetchPincodeData(pincode);
      stateController.text = data['state'] ?? '';
      cityController.text = data['city'] ?? '';

      // Calculate total weight and collect dimensions
      double totalWeight = 0.0;
      double totalLength = 0.0;
      double totalBreadth = 0.0;
      double totalHeight = 0.0;
      final productIdsList = <String>[];
      final productWeightDetails =
          <String, double>{}; // Map to store product weights

      for (int i = 0; i < productIds.length && i < quantities.length; i++) {
        final productId = productIds[i];
        final quantity =
            double.tryParse((i < quantities.length) ? quantities[i] : '1') ??
            1.0;
        final height =
            double.tryParse((i < heights.length) ? heights[i] : '0') ?? 0.0;
        final weight =
            double.tryParse((i < weights.length) ? weights[i] : '0') ?? 0.0;
        final breadth =
            double.tryParse((i < breadths.length) ? breadths[i] : '0') ?? 0.0;
        final length =
            double.tryParse((i < lengths.length) ? lengths[i] : '0') ?? 0.0;

        // Multiply weight by quantity
        final adjustedWeight = weight * quantity;
        totalWeight += adjustedWeight;
        totalLength += length;
        totalBreadth += breadth;
        totalHeight += height;
        productIdsList.add(productId);
        productWeightDetails[productId] = adjustedWeight;

        print(
          'Product ID: $productId with dimensions: '
          'length=$length, breadth=$breadth, height=$height, weight=$adjustedWeight (unit weight=$weight x quantity=$quantity)',
        );
      }

      if (productIdsList.isEmpty) {
        print('No products to calculate shipping for');
        totalDeliveryCharge.value = 0.0;
        return;
      }

      print(
        'Calculating shipping for combined products: ${productIdsList.join(', ')}',
      );
      print('Total Weight: $totalWeight kg');
      print(
        'Total Dimensions: length=$totalLength, breadth=$totalBreadth, height=$totalHeight',
      );

      final params = {
        'length': totalLength.toString(),
        'breadth': totalBreadth.toString(),
        'height': totalHeight.toString(),
        'weight': totalWeight.toString(),
        'cod': '0',
        'pickup_postcode': '122003',
        'delivery_postcode': pincode.trim(),
      };

      final result = await ApiHelper.getShippingTax(params);
      if (result != null && result is Map<String, dynamic>) {
        if (!(result['error'] ?? true)) {
          final couriers = result['data'] as List<dynamic>;
          final eligibleCouriers =
              couriers.where((courier) {
                final maxWeightRaw = courier['max_weight'];
                double maxWeight = 0.0;
                if (maxWeightRaw is String) {
                  maxWeight = double.tryParse(maxWeightRaw) ?? 0.0;
                } else if (maxWeightRaw is num) {
                  maxWeight = maxWeightRaw.toDouble();
                }
                return maxWeight >= totalWeight;
              }).toList();

          if (eligibleCouriers.isEmpty) {
            print('No couriers available for total weight: $totalWeight kg');
            totalDeliveryCharge.value = 0.0;
            return;
          }

          // Find the closest max_weight
          double minWeightDiff = double.infinity;
          for (var courier in eligibleCouriers) {
            final maxWeightRaw = courier['max_weight'];
            double maxWeight = 0.0;
            if (maxWeightRaw is String) {
              maxWeight = double.tryParse(maxWeightRaw) ?? 0.0;
            } else if (maxWeightRaw is num) {
              maxWeight = maxWeightRaw.toDouble();
            }
            final weightDiff = (maxWeight - totalWeight).abs();
            minWeightDiff =
                weightDiff < minWeightDiff ? weightDiff : minWeightDiff;
          }

          // Filter couriers with the closest max_weight
          final closestWeightCouriers =
              eligibleCouriers.where((courier) {
                final maxWeightRaw = courier['max_weight'];
                double maxWeight = 0.0;
                if (maxWeightRaw is String) {
                  maxWeight = double.tryParse(maxWeightRaw) ?? 0.0;
                } else if (maxWeightRaw is num) {
                  maxWeight = maxWeightRaw.toDouble();
                }
                return (maxWeight - totalWeight).abs() == minWeightDiff;
              }).toList();

          // Find the courier with the lowest total charge
          Map<String, dynamic>? cheapestCourier;
          double lowestTotalCharge = double.infinity;
          double freightCharge = 0.0;
          double gst = 0.0;

          for (var courier in closestWeightCouriers) {
            final freightChargeRaw = courier['freight_charge'];
            double currentFreightCharge = 0.0;
            if (freightChargeRaw is String) {
              currentFreightCharge = double.tryParse(freightChargeRaw) ?? 0.0;
            } else if (freightChargeRaw is num) {
              currentFreightCharge = freightChargeRaw.toDouble();
            }
            final currentTotalCharge = currentFreightCharge * 1.18;

            if (currentTotalCharge < lowestTotalCharge) {
              lowestTotalCharge = currentTotalCharge;
              cheapestCourier = courier;
              freightCharge = currentFreightCharge;
              gst = currentFreightCharge * 0.18;
            }
          }

          if (cheapestCourier != null) {
            totalDeliveryCharge.value = lowestTotalCharge;

            // Print individual product weights with courier name
            productWeightDetails.forEach((productId, adjustedWeight) {
              print(
                'Product ID: $productId, Adjusted Weight: ${adjustedWeight.toStringAsFixed(2)} kg, Courier: ${cheapestCourier!['courier_name']}',
              );
            });

            print(
              'Selected Courier for combined products: ${productIdsList.join(', ')}',
            );
            print(
              'Total Adjusted Weight: ${totalWeight.toStringAsFixed(2)} kg',
            );
            print('Courier: ${cheapestCourier['courier_name']}');
            print('Max Weight: ${cheapestCourier['max_weight']}');
            print('Freight Charge: ₹${freightCharge.toStringAsFixed(2)}');
            print('GST (18%): ₹${gst.toStringAsFixed(2)}');
            print('Total Charge: ₹${lowestTotalCharge.toStringAsFixed(2)}');
            print(
              '---------------------------------------------------------------',
            );
          } else {
            print(
              'No suitable courier found for total weight: $totalWeight kg',
            );
            totalDeliveryCharge.value = 0.0;
          }
        } else {
          print('Error fetching shipping tax: ${result['message']}');
          totalDeliveryCharge.value = 0.0;
        }
      } else {
        print('Invalid response from shipping tax API');
        totalDeliveryCharge.value = 0.0;
      }
    } catch (e) {
      stateController.text = '';
      cityController.text = '';
      print('Error fetching pincode data: $e');
      totalDeliveryCharge.value = 0.0;
    } finally {
      isPincodeLoading.value = false;
    }
  }

  Future<void> loadAddressData() async {
    try {
      isLoading.value = true;

      String? selectedAddressId =
          await SharedPreferencesHelper.getSelectedAddress();

      if (selectedAddressId != null && selectedAddressId.isNotEmpty) {
        final response = await ApiHelper.getUserAddressById(selectedAddressId);
        if (response['error'] == false && response['data'] != null) {
          final data = response['data'][0];

          address1Controller.text = data['address1']?.toString() ?? '';
          address2Controller.text = data['address2']?.toString() ?? '';
          zipController.text = data['pincode']?.toString() ?? '';
          stateController.text = data['state']?.toString() ?? '';
          cityController.text = data['city']?.toString() ?? '';
          addressExists.value = true;

          final pincode = zipController.text.trim();
          if (pincode.length == 6 &&
              RegExp(r'^\d{6}$').hasMatch(pincode) &&
              pincode != lastProcessedPincode) {
            await fetchPincodeData(pincode);
          }
          return;
        } else {
          address1Controller.clear();
          address2Controller.clear();
          zipController.clear();
          stateController.clear();
          cityController.clear();
          addressExists.value = false;
          await SharedPreferencesHelper.clearSelectedAddress();
        }
      }

      String? storedUser = await SharedPreferencesHelper.getUserData();
      if (storedUser != null && storedUser.isNotEmpty) {
        List<String> userDetails = storedUser.split(', ');
        if (userDetails.isNotEmpty) {
          int userId = int.tryParse(userDetails[0]) ?? 0;
          if (userId > 0) {
            final response = await ApiHelper.getDefaultAddress(userId);
            if (response['error'] == false &&
                response['data'] != null &&
                response['data'].isNotEmpty) {
              final data = response['data'][0];

              address1Controller.text = data['address1']?.toString() ?? '';
              address2Controller.text = data['address2']?.toString() ?? '';
              zipController.text = data['pincode']?.toString() ?? '';
              stateController.text = data['state']?.toString() ?? '';
              cityController.text = data['city']?.toString() ?? '';
              addressExists.value = true;

              final pincode = zipController.text.trim();
              if (pincode.length == 6 &&
                  RegExp(r'^\d{6}$').hasMatch(pincode) &&
                  pincode != lastProcessedPincode) {
                await fetchPincodeData(pincode);
              }
              return;
            }
          }
        }
      }

      address1Controller.clear();
      address2Controller.clear();
      zipController.clear();
      stateController.clear();
      cityController.clear();
      addressExists.value = false;
    } catch (e) {
      address1Controller.clear();
      address2Controller.clear();
      zipController.clear();
      stateController.clear();
      cityController.clear();
      addressExists.value = false;
      await SharedPreferencesHelper.clearSelectedAddress();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDefaultAddress() async {
    try {
      isLoading.value = true;
      await loadAddressData();
    } catch (e) {
      // Handle error silently
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
    if (!formKey.currentState!.validate()) {
      signupMessage = "Please fill all fields correctly";
      return false;
    }

    final String email = emailController.text.trim();
    final String formattedDate = getFormattedDate();

    try {
      final response = await ApiHelper.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: email,
        phone: mobileController.text.trim(),
        createdAt: formattedDate,
      );

      if (response['error'] == true) {
        signupMessage = response['message'] ?? "Signup failed";
        return false;
      }

      final String apiUrl =
          'https://vedvika.com/v1/apis/common/user_data/get_user_data.php?email=$email';
      final http.Response apiResponse = await http.get(Uri.parse(apiUrl));

      if (apiResponse.statusCode != 200) {
        signupMessage = "Failed to fetch user data";
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(apiResponse.body);

      if (responseData['error'] == true || responseData['data'].isEmpty) {
        signupMessage = "Failed to fetch user data";
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

      bool addressAdded = await handleAddAddress(context);
      if (!addressAdded) {
        signupMessage = "Signup successful, but failed to add address";
      } else {
        signupMessage = "Signup and address addition successful";
      }

      return true;
    } catch (e) {
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

        if (response['error'] == true) {
          signupMessage =
              response['message'] ??
              "${isEditing ? 'Update' : 'Add'} address failed";
          return false;
        } else {
          signupMessage =
              isEditing
                  ? "Address updated successfully"
                  : "Address added successfully";
          await addAddressController.fetchAddress();
          await loadAddressData();
          return true;
        }
      } catch (e) {
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
    if (!js.context.hasProperty('openRazorpay')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Payment system not initialized')),
      );
      return;
    }

    String? userId = await SharedPreferencesHelper.getUserId();
    String? selectedAddressId =
        await SharedPreferencesHelper.getSelectedAddress();
    String formattedDate = getFormattedDate();

    if (selectedAddressId == null || selectedAddressId.isEmpty) {
      try {
        if (userId != null &&
            int.tryParse(userId) != null &&
            int.parse(userId) > 0) {
          final response = await ApiHelper.getDefaultAddress(int.parse(userId));
          if (response['error'] == false &&
              response['data'] != null &&
              response['data'].isNotEmpty) {
            selectedAddressId = response['data'][0]['id']?.toString() ?? 'N/A';
          } else {
            selectedAddressId = 'N/A';
          }
        } else {
          selectedAddressId = 'N/A';
        }
      } catch (e) {
        selectedAddressId = 'N/A';
      }
    }

    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    final productPrices =
        uri.queryParameters['productPrices']?.split(',') ?? [];

    final options = {
      'key': 'rzp_test_PKUyVj9nF0FvA7',
      'amount': ((total + totalDeliveryCharge.value) * 100).toInt(),
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
        final paymentId = response['razorpay_payment_id'] ?? 'N/A';
        final orderIdResponse = response['razorpay_order_id'] ?? orderId;
        final signature = response['razorpay_signature'] ?? 'N/A';
        final amount = total + totalDeliveryCharge.value;
        final status = 'success';

        List<Map<String, String>> productDetailsList = [];
        for (int i = 0; i < productIds.length && i < quantities.length; i++) {
          final price = (i < productPrices.length) ? productPrices[i] : '0.00';
          productDetailsList.add({
            'product_id': productIds[i],
            'quantity': quantities[i],
            'price': price,
          });
        }
        String productDetailsJson = jsonEncode(productDetailsList);

        Map<String, dynamic>? paymentDetails;
        try {
          final serverResponse = await http.get(
            Uri.parse(
              'https://vedvika.com/v1/apis/backend/order_get_details/payment_details.php?payment_id=$paymentId',
            ),
          );

          if (serverResponse.statusCode == 200) {
            paymentDetails = jsonDecode(serverResponse.body);
          }
        } catch (e) {
          // Handle error silently
        }

        try {
          final orderResponse = await ApiHelper.orderPurchaseDetails(
            userId: userId ?? 'N/A',
            productDetails: productDetailsJson,
            orderId: orderIdResponse,
            isSuccess: '1',
            paymentMode: paymentDetails?['method'] ?? 'N/A',
            paymentId: paymentId,
            amount: amount.toString(),
            razorpayAmount: ((paymentDetails!['amount'] / 100) +
                    totalDeliveryCharge.value)
                .toStringAsFixed(2),
            addressId: selectedAddressId.toString(),
            createdAt: formattedDate,
          );
          if (orderResponse['error'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to save order details: ${orderResponse['message']}',
                ),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving order details: $e')),
          );
        }

        for (int i = 0; i < productIds.length && i < quantities.length; i++) {
          String productId = productIds[i];
          String quantity = quantities[i];
          try {
            final stockResponse = await ApiHelper.updateStock(
              productId: productId,
              quantity: quantity,
              updatedAt: formattedDate,
            );
            if (stockResponse['error'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to update stock for Product ID $productId: ${stockResponse['message']}',
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error updating stock for Product ID $productId: $e',
                ),
              ),
            );
          }
        }

        await SharedPreferencesHelper.clearAllProductIds();

        context.go(
          '${AppRoutes.paymentResult}?success=true&orderId=$orderId&amount=$amount',
        );
      }),
      'modal': {
        'ondismiss': js.allowInterop(() async {
          List<Map<String, String>> productDetailsList = [];
          for (int i = 0; i < productIds.length && i < quantities.length; i++) {
            final price =
                (i < productPrices.length) ? productPrices[i] : '0.00';
            productDetailsList.add({
              'product_id': productIds[i],
              'quantity': quantities[i],
              'price': price,
            });
          }
          String productDetailsJson = jsonEncode(productDetailsList);

          try {
            final orderResponse = await ApiHelper.orderPurchaseDetails(
              userId: userId ?? 'N/A',
              productDetails: productDetailsJson,
              orderId: orderId,
              isSuccess: '0',
              paymentMode: 'N/A',
              paymentId: 'N/A',
              amount: (total + totalDeliveryCharge.value).toString(),
              razorpayAmount:
                  ((total + totalDeliveryCharge.value) * 100)
                      .toInt()
                      .toString(),
              addressId: selectedAddressId.toString(),
              createdAt: formattedDate,
            );
            if (orderResponse['error'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to save order details: ${orderResponse['message']}',
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving order details: $e')),
            );
          }

          context.go(
            '${AppRoutes.paymentResult}?success=false&orderId=$orderId&amount=${total + totalDeliveryCharge.value}',
          );
        }),
      },
    };

    try {
      js.context.callMethod('openRazorpay', [js.JsObject.jsify(options)]);
    } catch (e) {
      // Handle error silently
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
    productIds.clear();
    quantities.clear();
    heights.clear();
    weights.clear();
    breadths.clear();
    lengths.clear();
    totalDeliveryCharge.value = 0.0;
    lastProcessedPincode = null;
  }
}
