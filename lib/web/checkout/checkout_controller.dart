import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http show Response, get;
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/shared_preferences/shared_preferences.dart';
import 'package:kireimics/web_desktop_common/add_address_ui/add_address_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../component/app_routes/routes.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/utilities/delivery_charge.dart';
import '../../component/utilities/utility.dart';
import 'encription.dart';

class CheckoutController extends GetxController {
  // Centralized API URL
  static const String _userDataApiUrl =
      'https://www.kireimics.com/apis/common/user_data/get_user_data.php';
  static const String _productDetailsApiUrl =
      'https://www.kireimics.com/apis/common/product_details/get_checkout_product_details.php';
  RxBool showLoginBox = true.obs;
  bool isPrivacyPolicyChecked = false;

  var isLoading = false.obs;
  RxBool isChecked = false.obs;
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
  final RxBool isSignupProcessing = false.obs;
  var productIds = <String>[].obs;
  var productName = <String>[].obs;
  var productPrices = <String>[].obs;
  var quantities = <String>[].obs;
  var heights = <String>[].obs;
  var weights = <String>[].obs;
  var breadths = <String>[].obs;
  var lengths = <String>[].obs;
  Function(String)? onWishlistChanged;
  Function(String)? onErrorWishlistChanged;
  var isPincodeLoading = false.obs;
  var totalDeliveryCharge = 0.0.obs;
  String? lastProcessedPincode;
  var isPaymentProcessing = false.obs;
  var totalLength = 0.0.obs;
  var totalHeight = 0.0.obs;
  var totalBreadth = 0.0.obs;
  var totalWeight = 0.0.obs;
  var totalQuantity = 0.0.obs;
  final RxBool isLoggedIn = false.obs;
  var subtotal = 0.0.obs;

  GoRouter? _router;

  Function(bool)? onPaymentProcessing;
  var isShippingTaxLoaded = false.obs;
  Timer? _debounce;

  Future<bool> isUserLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  void updateFromRoute(BuildContext context) {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());

    // Load product IDs and quantities from URL
    loadProductIds(context);
    // Fetch product details (including names, prices, and dimensions) from API
    getData();
  }

  void initializeRouter(BuildContext context) {
    _router = GoRouter.of(context);
    _router!.routeInformationProvider.addListener(() {
      updateFromRoute(context);
    });
  }

  void disposeRouter() {
    _router?.routeInformationProvider.removeListener(() {
      updateFromRoute(Get.context!);
    });
    _router = null;
  }

  Future<void> checkLoginStatus() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    isLoggedIn.value = userData != null && userData.isNotEmpty;
    showLoginBox.value = !isLoggedIn.value;
  }

  void setCallbacks({
    Function(String)? onWishlistChanged,
    Function(String)? onErrorWishlistChanged,
    Function(bool)? onPaymentProcessing,
  }) {
    this.onWishlistChanged = onWishlistChanged;
    this.onErrorWishlistChanged = onErrorWishlistChanged;
    this.onPaymentProcessing = onPaymentProcessing;
  }

  Future<void> getData() async {
    try {
      final ids = productIds.value;
      final quantitiesList = quantities.value;

      if (ids.isEmpty ||
          quantitiesList.isEmpty ||
          ids.length != quantitiesList.length) {
        throw Exception("Missing or mismatched product ID(s) and quantities.");
      }

      final idString = ids.join(',');
      final url = Uri.parse("$_productDetailsApiUrl?id=$idString");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody['error'] == false && jsonBody['data'] != null) {
          final List data = jsonBody['data'];
          double tempSubtotal = 0.0;
          productName.clear();
          productPrices.clear();
          lengths.clear();
          breadths.clear();
          heights.clear();
          weights.clear();

          for (int i = 0; i < data.length; i++) {
            final item = data[i];

            final double price =
                double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
            final double discount =
                double.tryParse(item['discount']?.toString() ?? '0.0') ?? 0.0;
            final double discountedPrice =
                discount > 0 ? price * (1 - discount / 100) : price;

            final int quantity =
                int.tryParse(quantitiesList[i].toString()) ?? 1;
            final double totalForItem = discountedPrice * quantity;

            tempSubtotal += totalForItem;

            // Store product details from API
            productName.add(item['name']?.toString() ?? '');
            productPrices.add(discountedPrice.toStringAsFixed(2));
            lengths.add(item['length']?.toString() ?? '0.0');
            breadths.add(item['breadth']?.toString() ?? '0.0');
            heights.add(item['height']?.toString() ?? '0.0');
            weights.add(item['weight']?.toString() ?? '0.0');

            // print('Name: ${item['name']}');
            // print('Price: $price');
            // print('Discount: $discount');
            // print('Discounted Price: $discountedPrice');
            // print('Quantity: $quantity');
            // print('Total for this item: $totalForItem');
            // print('Length: ${item['length']}');
            // print('Breadth: ${item['breadth']}');
            // print('Height: ${item['height']}');
            // print('Weight: ${item['weight']}');
            // print('---');
          }

          subtotal.value = tempSubtotal;
          calculateDimensions(); // Calculate dimensions after fetching
          update();
        } else {
          throw Exception(jsonBody['message'] ?? "Unknown error");
        }
      } else {
        throw Exception("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      // print('Error fetching product details: $e');
      subtotal.value = 0.0;
      productName.clear();
      productPrices.clear();
      lengths.clear();
      breadths.clear();
      heights.clear();
      weights.clear();
      update();
    }
  }

  Future<void> getShippingTax() async {
    final deliveryPostcode = zipController.text;
    if (deliveryPostcode.isEmpty || deliveryPostcode.length != 6) {
      // print(
      //   'Skipping shipping tax request: Invalid or empty delivery_postcode',
      // );
      totalDeliveryCharge.value = 0.0;
      isShippingTaxLoaded.value = true;
      return;
    }

    final params = {
      'length': totalLength.value.toString(),
      'breadth': totalBreadth.value.toString(),
      'height': totalHeight.value.toString(),
      'weight': totalWeight.value.toString(),
      'cod': '0',
      'pickup_postcode': '122003',
      'delivery_postcode': deliveryPostcode,
    };

    // print('Shipping tax request params: $params');
    isShippingTaxLoaded.value = false;
    isPincodeLoading.value = true;

    final result = await ApiHelper.getShippingTax(params);
    // print('Shipping tax response: $result');

    isPincodeLoading.value = false;
    if (result['error'] == true) {
      // print('Error: ${result['message']}');
      totalDeliveryCharge.value = 0.0;
      isShippingTaxLoaded.value = true;
      return;
    }

    if (result['data'] != null &&
        result['data'] is List &&
        result['data'].isNotEmpty) {
      double lowestTotalCost = double.infinity;
      Map<String, dynamic>? lowestCostCourier;

      for (var courier in result['data']) {
        double freightCharge =
            double.tryParse(courier['freight_charge'].toString()) ?? 0.0;
        double gst = freightCharge * 0.18;
        double totalCost = freightCharge + gst;

        if (totalCost < lowestTotalCost) {
          lowestTotalCost = totalCost;
          lowestCostCourier = courier;
        }
      }

      if (lowestCostCourier != null) {
        totalDeliveryCharge.value = lowestTotalCost;

        // print(
        //   'Lowest Freight Charge + 18% GST: ₹${lowestTotalCost.toStringAsFixed(2)}',
        // );
        // print('Courier Details:');
        // print('  Courier Name: ${lowestCostCourier['courier_name']}');
        // print(
        //   '  Courier Company ID: ${lowestCostCourier['courier_company_id']}',
        // );
        // print(
        //   '  Estimated Delivery Days: ${lowestCostCourier['estimated_delivery_days']}',
        // );
        // print('  Max Weight: ${lowestCostCourier['max_weight']} kg');
        // print('  COD Available: ${lowestCostCourier['cod_available']}');
      } else {
        // print('No valid courier options found.');
        totalDeliveryCharge.value = 0.0;
      }
    } else {
      // print('No courier data available in response.');
      totalDeliveryCharge.value = 0.0;
    }
    isShippingTaxLoaded.value = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    zipController.addListener(() {
      final pincode = zipController.text.trim();
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (pincode.length == 6 && RegExp(r'^\d{6}$').hasMatch(pincode)) {
          if (pincode != lastProcessedPincode) {
            fetchPincodeData(pincode);
            getShippingTax();
          }
        } else {
          isShippingTaxLoaded.value = true;
          totalDeliveryCharge.value = 0;

          stateController.text = '';
          cityController.text = '';
        }
      });
    });
  }

  @override
  void onClose() {
    zipController.removeListener(() {});
    _debounce?.cancel();
    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    stateController.dispose();
    cityController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    productIds.clear();
    quantities.clear();
    heights.clear();
    weights.clear();
    breadths.clear();
    lengths.clear();
    productName.clear();
    productPrices.clear();
    isLoading.value = false;
    addressExists.value = false;
    isPincodeLoading.value = false;
    totalDeliveryCharge.value = 0.0;
    totalLength.value = 0.0;
    totalHeight.value = 0.0;
    totalBreadth.value = 0.0;
    totalWeight.value = 0.0;
    totalQuantity.value = 0.0;
    lastProcessedPincode = null;
    signupMessage = "";
    isChecked = false.obs;
    onWishlistChanged = null;
    onErrorWishlistChanged = null;
    isShippingTaxLoaded.value = false;
    disposeRouter();
    Get.delete<AddAddressController>(force: true);
    super.onClose();
  }

  void calculateDimensions() {
    List<double> parseAndSum(List<String> param) {
      if (param.isEmpty) return [0.0];
      return param.map((e) => double.tryParse(e) ?? 0.0).toList();
    }

    final lengthsList = parseAndSum(lengths);
    final heightsList = parseAndSum(heights);
    final breadthsList = parseAndSum(breadths);
    final weightsList = parseAndSum(weights);
    final quantitiesList = parseAndSum(quantities);

    totalLength.value = lengthsList.fold(0.0, (a, b) => a + b);
    totalHeight.value = heightsList.fold(0.0, (a, b) => a + b);
    totalBreadth.value = breadthsList.fold(0.0, (a, b) => a + b);
    totalQuantity.value = quantitiesList.fold(0.0, (a, b) => a + b);

    totalWeight.value = 0.0;
    for (int i = 0; i < weightsList.length && i < quantitiesList.length; i++) {
      totalWeight.value += weightsList[i] * quantitiesList[i];
    }

    // printAllDimensionsAndLargest();
  }

  void printAllDimensionsAndLargest() {
    final int minLength = [
      productIds.length,
      lengths.length,
      breadths.length,
      heights.length,
      weights.length,
      productName.length,
      quantities.length,
      productPrices.length,
    ].reduce((a, b) => a < b ? a : b);

    if (minLength == 0) {
      return;
    }

    double maxLength = 0.0;
    double maxBreadth = 0.0;
    double maxHeight = 0.0;
    double maxWeight = 0.0;

    final random = Random();

    for (int i = 0; i < minLength; i++) {
      final name = productName[i].replaceAll(RegExp(r'\s+'), '').toUpperCase();
      final uniqueId = '${name}_${random.nextInt(9000) + 1000}';

      final productQuantity = quantities[i];
      final length = double.tryParse(lengths[i]) ?? 0.0;
      final breadth = double.tryParse(breadths[i]) ?? 0.0;
      final height = double.tryParse(heights[i]) ?? 0.0;
      final weight = double.tryParse(weights[i]) ?? 0.0;

      if (length > maxLength) {
        maxLength = length;
      }
      if (breadth > maxBreadth) {
        maxBreadth = breadth;
      }
      if (height > maxHeight) {
        maxHeight = height;
      }
      if (weight > maxWeight) {
        maxWeight = weight;
      }
    }
  }

  Future<void> loadProductIds(BuildContext context) async {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());

    productIds.value = uri.queryParameters['productIds']?.split(',') ?? [];
    quantities.value = uri.queryParameters['quantities']?.split(',') ?? [];

    // Dimensions and product details are fetched from API in getData()
  }

  Future<void> fetchPincodeData(String pincode) async {
    if (productIds.isEmpty) {
      totalDeliveryCharge.value = 0.0;
      isShippingTaxLoaded.value = true;
      return;
    }

    try {
      isPincodeLoading.value = true;
      lastProcessedPincode = pincode;
      totalDeliveryCharge.value = 0.0;
      isShippingTaxLoaded.value = false;
      stateController.text = '';
      cityController.text = '';

      final data = await ApiHelper().fetchPincodeData(pincode);
      stateController.text = data['state'] ?? '';
      cityController.text = data['city'] ?? '';
      await getShippingTax();
    } catch (e) {
      stateController.text = '';
      cityController.text = '';
      totalDeliveryCharge.value = 0.0;
      isShippingTaxLoaded.value = true;
    } finally {
      isPincodeLoading.value = false;
      update();
    }
  }

  void _setAddressData(Map<String, dynamic> data) {
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
      fetchPincodeData(pincode);
    }
  }

  void _clearAddressData() {
    address1Controller.clear();
    address2Controller.clear();
    zipController.clear();
    stateController.clear();
    cityController.clear();
    addressExists.value = false;
  }

  Future<void> loadAddressData() async {
    try {
      isLoading.value = true;

      String? selectedAddressId =
          await SharedPreferencesHelper.getSelectedAddress();

      if (selectedAddressId != null && selectedAddressId.isNotEmpty) {
        final response = await ApiHelper.getUserAddressById(selectedAddressId);
        if (response['error'] == false && response['data'] != null) {
          _setAddressData(response['data'][0]);
          return;
        } else {
          _clearAddressData();
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
              _setAddressData(response['data'][0]);
              return;
            }
          }
        }
      }

      _clearAddressData();
    } catch (e) {
      _clearAddressData();
      await SharedPreferencesHelper.clearSelectedAddress();
      // print('Error loading address data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDefaultAddress() async {
    try {
      isLoading.value = true;
      await loadAddressData();
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
      isSignupProcessing.value = true;
      final response = await ApiHelper.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: email,
        phone: mobileController.text.trim(),
        createdAt: formattedDate,
      );

      if (response['error'] == true) {
        signupMessage = response['message'] ?? "Signup failed";
        isSignupProcessing.value = false;
        return false;
      }

      final mailResponse = await ApiHelper.registerMail(email: email);
      // print("Register Mail Response: $mailResponse");

      if (mailResponse['error'] == true) {
        signupMessage = mailResponse['message'] ?? "Failed to send email";
        isSignupProcessing.value = false;
        return false;
      }

      final http.Response apiResponse = await http.get(
        Uri.parse('$_userDataApiUrl?email=$email'),
      );

      if (apiResponse.statusCode != 200) {
        signupMessage = "Failed to fetch user data";
        isSignupProcessing.value = false;
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(apiResponse.body);

      if (responseData['error'] == true || responseData['data'].isEmpty) {
        signupMessage = "Failed to fetch user data";
        isSignupProcessing.value = false;
        return false;
      }

      final userData = responseData['data'][0];
      int userId = userData['id'] ?? -1;
      String firstName = userData['first_name'] ?? 'Unknown';
      String lastName = userData['last38_name'] ?? 'Unknown';
      String phone = userData['phone'] ?? 'Unknown';
      String createdAt = userData['createdAt'] ?? formattedDate;

      String userDetails =
          '$userId, $firstName $lastName, $phone, $email, $createdAt';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
      await SharedPreferencesHelper.saveUserData(userDetails);

      bool addressAdded = await handleAddAddress(context);
      signupMessage =
          addressAdded
              ? "Signup and address addition successful"
              : "Signup successful, but failed to add address";

      isSignupProcessing.value = false;
      return true;
    } catch (e) {
      signupMessage = "An error occurred during signup";
      isSignupProcessing.value = false;
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
        final response = await ApiHelper.registerAddress(
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
        }

        signupMessage =
            isEditing
                ? "Address updated successfully"
                : "Address added successfully";
        await addAddressController.fetchAddress();
        await loadAddressData();
        return true;
      } catch (e) {
        signupMessage =
            "An error occurred while ${isEditing ? 'updating' : 'adding'} the address";
        return false;
      }
    }

    signupMessage = "Please fill all fields correctly";
    return false;
  }

  Future<String> _getSelectedAddressId(String? userId) async {
    String? selectedAddressId =
        await SharedPreferencesHelper.getSelectedAddress();
    if (selectedAddressId == null || selectedAddressId.isEmpty) {
      if (userId != null && int.tryParse(userId) != null) {
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
    }
    return selectedAddressId;
  }

  openRazorpayCheckout(
    BuildContext context,
    double total,
    String orderId,
  ) async {
    if (!js.context.hasProperty('openRazorpay')) {
      onErrorWishlistChanged?.call("'Error: Payment system not initialized");

      return;
    }

    String? userId = await SharedPreferencesHelper.getUserId();
    String selectedAddressId = await _getSelectedAddressId(userId);
    String formattedDate = getFormattedDate();

    final finalAmount =
        subtotal.value > AppConstants.deliveryCharge
            ? subtotal.value
            : subtotal.value + totalDeliveryCharge.value;

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

    final options = {
      'key': 'rzp_live_cuFo6uTCGdpJ6Z',
      'amount': (finalAmount * 100).toInt(),
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
        isPaymentProcessing.value = true;
        onPaymentProcessing?.call(true);

        final paymentId = response['razorpay_payment_id'] ?? 'N/A';
        final orderIdResponse = response['razorpay_order_id'] ?? orderId;

        Map<String, dynamic>? paymentDetails;
        try {
          final serverResponse = await http.get(
            Uri.parse(
              'https://www.kireimics.com/apis/backend/order_payments_details/payment_details.php?payment_id=$paymentId',
            ),
          );
          if (serverResponse.statusCode == 200) {
            paymentDetails = jsonDecode(serverResponse.body);
            // print("paymentDetails: $paymentDetails");
          }
        } catch (e) {
          // print('Error fetching payment details: $e');
        }

        Map<String, dynamic>? addressData;
        if (selectedAddressId != 'N/A') {
          final addressResponse = await ApiHelper.getUserAddressById(
            selectedAddressId,
          );
          if (addressResponse['error'] == false &&
              addressResponse['data'] != null) {
            addressData = addressResponse['data'][0];
          }
        }

        double maxLength = 0.0;
        double maxBreadth = 0.0;
        double maxHeight = 0.0;
        double maxWeight = 0.0;
        List<Map<String, dynamic>> orderItems = [];

        for (int i = 0; i < productIds.length && i < quantities.length; i++) {
          final quantity = double.tryParse(quantities[i]) ?? 1.0;
          final length = double.tryParse(lengths[i]) ?? 0.0;
          final breadth = double.tryParse(breadths[i]) ?? 0.0;
          final height = double.tryParse(heights[i]) ?? 0.0;
          final weight = double.tryParse(weights[i]) ?? 0.0;
          final price =
              (i < productPrices.length)
                  ? double.tryParse(productPrices[i]) ?? 0.0
                  : 0.0;

          final productNameCleaned =
              productName[i].replaceAll(RegExp(r'\s+'), '').toUpperCase();
          final sku = '${productNameCleaned}001';

          if (length > maxLength) maxLength = length;
          if (breadth > maxBreadth) maxBreadth = breadth;
          if (height > maxHeight) maxHeight = height;
          if (weight * quantity > maxWeight) maxWeight = weight * quantity;

          orderItems.add({
            'name': productName[i],
            'sku': sku,
            'units': quantity.toInt(),
            'selling_price': price.toStringAsFixed(0),
          });
        }

        final fields = {
          'order_id': orderIdResponse,
          'order_date': formattedDate,
          'billing_customer_name':
              addressData?['first_name']?.toString() ??
              firstNameController.text,
          'billing_last_name':
              addressData?['last_name']?.toString() ?? lastNameController.text,
          'billing_address':
              '${addressData?['address1'] ?? address1Controller.text}, ${addressData?['address2'] ?? address2Controller.text}',
          'billing_city':
              addressData?['city']?.toString() ?? cityController.text,
          'billing_pincode':
              addressData?['pincode']?.toString() ?? zipController.text,
          'billing_state':
              addressData?['state']?.toString() ?? stateController.text,
          'billing_country': 'India',
          'billing_email':
              addressData?['email']?.toString() ?? emailController.text,
          'billing_phone':
              addressData?['phone']?.toString() ?? mobileController.text,
          'order_items': orderItems,
          'payment_method': 'Prepaid',
          'sub_total': subtotal.value.toStringAsFixed(2),
          'length': maxLength.toStringAsFixed(2),
          'breadth': maxBreadth.toStringAsFixed(2),
          'height': maxHeight.toStringAsFixed(2),
          'weight': maxWeight.toStringAsFixed(2),
        };

        // print('=== Payment Successful - Order Details ===');
        fields.forEach((key, value) {
          if (key == 'order_items') {
            // print('$key: [');
            for (var item in value) {
              // print('  {');
              // print('    "name": "${item['name']}",');
              // print('    "sku": "${item['sku']}",');
              // print('    "units": ${item['units']},');
              // print('    "selling_price": "${item['selling_price']}"');
              // print('  },');
            }
            // print(']');
          } else {
            // print('$key: $value');
          }
        });

        try {
          final orderCreateResponse = await ApiHelper.orderCreate(
            orderId: fields['order_id'],
            orderDate: fields['order_date'],
            billingCustomerName: fields['billing_customer_name'],
            billingLastName: fields['billing_last_name'],
            billingAddress: fields['billing_address'],
            billingCity: fields['billing_city'],
            billingPincode: fields['billing_pincode'],
            billingState: fields['billing_state'],
            billingCountry: fields['billing_country'],
            billingEmail: fields['billing_email'],
            billingPhone: fields['billing_phone'],
            orderItems: fields['order_items'],
            paymentMethod: fields['payment_method'],
            subTotal: fields['sub_total'],
            length: fields['length'],
            breadth: fields['breadth'],
            height: fields['height'],
            weight: fields['weight'],
          );

          if (orderCreateResponse['error'] == true) {
            // print('Order Create Error: ${orderCreateResponse['message']}');

            onErrorWishlistChanged?.call("${orderCreateResponse['message']}");

            isPaymentProcessing.value = false;
            onPaymentProcessing?.call(false);
            return;
          }
          // ⬇️ Update stock for each product
          for (int i = 0; i < productIds.length; i++) {
            final productId = productIds[i];
            final quantity = quantities[i];
            final updatedAt = formattedDate;

            try {
              final stockResponse = await ApiHelper.updateStock(
                productId: productId,
                quantity: quantity,
                updatedAt: updatedAt,
              );

              if (stockResponse['error'] == true) {
                // print(
                //   '⚠️ Stock update error for product $productId: ${stockResponse['message']}',
                // );
                onErrorWishlistChanged?.call(
                  "Stock update failed: ${stockResponse['message']}",
                );
              } else {
                // print('✅ Stock updated for product $productId');
              }
            } catch (e) {
              // print('❌ Error updating stock for product $productId: $e');
              onErrorWishlistChanged?.call("Error updating stock: $e");
            }
          }
        } catch (e) {
          // print('Error calling orderCreate: $e');

          onErrorWishlistChanged?.call("Error creating order: $e");

          isPaymentProcessing.value = false;
          onPaymentProcessing?.call(false);
          return;
        }

        double itemTotal = 0.0;
        for (var product in productDetailsList) {
          final price = double.tryParse(product['price'] ?? '0.0') ?? 0.0;
          final quantity = double.tryParse(product['quantity'] ?? '0') ?? 0.0;
          itemTotal += price * quantity;
        }
        final orderResponse = await ApiHelper.orderPurchaseDetails(
          userId: userId ?? 'N/A',
          productDetails: productDetailsJson,
          orderId: orderIdResponse,
          isSuccess: '1',
          paymentMode: paymentDetails?['method'] ?? 'Razorpay',
          paymentId: paymentId,
          itemTotal: itemTotal.toString(),
          amount: finalAmount.toStringAsFixed(2),
          razorpayAmount:
              paymentDetails != null && paymentDetails['amount'] != null
                  ? (paymentDetails['amount'] / 100).toStringAsFixed(2)
                  : finalAmount.toStringAsFixed(2),
          addressId: selectedAddressId,
          shippingTaxes:
              subtotal.value >AppConstants.deliveryCharge
                  ? '0'
                  : totalDeliveryCharge.value.toString(),
          createdAt: formattedDate,
        );

        if (orderResponse['error'] == true) {
          // print('Order Response Error: ${orderResponse['message']}');

          onErrorWishlistChanged?.call("${orderResponse['message']}");

          isPaymentProcessing.value = false;
          onPaymentProcessing?.call(false);
        }

        try {
          final mailResponse = await ApiHelper.orderCreatedMail(
            email: fields['billing_email'],
            orderId: fields['order_id'],
            name: fields['billing_customer_name'],
            placedOn: formattedDate,
            totalAmount: finalAmount.toStringAsFixed(2),
          );
          if (mailResponse['error'] == true) {
            // print('Order Created Mail Error: ${mailResponse['message']}');

            onErrorWishlistChanged?.call("${mailResponse['message']}");
          }
        } catch (e) {
          // print('Error calling orderCreatedMail: $e');

          onErrorWishlistChanged?.call(
            "Error sending order confirmation email: $e",
          );
        }

        await SharedPreferencesHelper.clearAllProductIds();
        cartNotifier.value = 0;

        isPaymentProcessing.value = false;
        onPaymentProcessing?.call(false);

        await PaymentStateService().setPaymentResult(
          success: true,
          orderId: orderId,
          amount: finalAmount,
          orderDate: DateTime.now(),
        );

        context.go(AppRoutes.paymentResult);
      }),
      'modal': {
        'ondismiss': js.allowInterop(([dynamic _]) async {
          // print('Razorpay modal dismissed');
          isPaymentProcessing.value = false;
          onPaymentProcessing?.call(false);

          double itemTotal = 0.0;
          for (var product in productDetailsList) {
            final price = double.tryParse(product['price'] ?? '0.0') ?? 0.0;
            final quantity = double.tryParse(product['quantity'] ?? '0') ?? 0.0;
            itemTotal += price * quantity;
          }

          try {
            final orderResponse = await ApiHelper.orderPurchaseDetails(
              userId: userId ?? 'N/A',
              productDetails: productDetailsJson,
              orderId: orderId,
              isSuccess: '0',
              paymentMode: 'N/A',
              paymentId: 'N/A',
              amount: finalAmount.toStringAsFixed(2),
              razorpayAmount: (finalAmount * 100).toInt().toString(),
              addressId: selectedAddressId,
              itemTotal: itemTotal.toStringAsFixed(2),
              shippingTaxes:
                  subtotal.value >AppConstants.deliveryCharge
                      ? '0'
                      : totalDeliveryCharge.value.toString(),
              createdAt: formattedDate,
            );

            if (orderResponse['error'] == true) {
              // print(
              //   'Order Response Error (Dismiss): ${orderResponse['message']}',
              // );

              onErrorWishlistChanged?.call("${orderResponse['message']}");
            }
          } catch (e) {
            // print('Error saving order details (Dismiss): $e');

            onErrorWishlistChanged?.call("Error saving order details: $e");
          } finally {
            try {
              await PaymentStateService().setPaymentResult(
                success: false,
                orderId: orderId,
                amount: finalAmount,
                orderDate: DateTime.now(),
              );

              context.go(AppRoutes.paymentResult);

              // print('Navigation to payment failure page successful');
            } catch (e) {
              // print('Navigation error: $e');

              onErrorWishlistChanged?.call("Navigation error: $e");
            }
          }
        }),
      },
    };

    try {
      js.context.callMethod('openRazorpay', [js.JsObject.jsify(options)]);
    } catch (e) {
      // print('Error initiating Razorpay: $e');

      onErrorWishlistChanged?.call("Error initiating payment");
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
    productName.clear();
    productPrices.clear();
    totalDeliveryCharge.value = 0.0;
    isShippingTaxLoaded.value = false;
    showLoginBox.value = true;

    totalLength.value = 0.0;
    totalHeight.value = 0.0;
    totalBreadth.value = 0.0;
    totalWeight.value = 0.0;
    totalQuantity.value = 0.0;
    lastProcessedPincode = null;
    subtotal.value = 0.0;
    update();
  }
}
