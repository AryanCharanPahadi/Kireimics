import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/utilities/utility.dart';
import '../../web/checkout/checkout_controller.dart';

class AddAddressController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var isChecked = false.obs;
  final TextEditingController zipController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Observable list to store address data
  var _addressList = <Map<String, dynamic>>[].obs;

  // Getter to access address list
  List<Map<String, dynamic>> get addressList => _addressList;
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

  void deleteAddress(String addressId) async {
    String? userId = await SharedPreferencesHelper.getUserId();

    final result = await ApiHelper.deleteUserAddress(
      addressId: addressId,
      userId: userId.toString(),
    );

    if (result['error'] == false) {
      print('Server Message: ${result['message']}');
      await fetchAddress(); // Refresh address list after deletion
    } else {
      print('Failed: ${result['message']}');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAddress(); // Fetch addresses when controller is initialized
  }

  // Fetch address data from API
  Future<void> fetchAddress() async {
    String? userId = await SharedPreferencesHelper.getUserId();

    var result = await ApiHelper.getUserAddress(userId.toString());

    if (result['error'] == false) {
      _addressList.value =
          (result['data'] as List<dynamic>).map((address) {
            return {
              "id": address['id'],
              "city": address['city'],
              "name": "${address['first_name']} ${address['last_name']}",
              "address": "${address['address1']}, ${address['address2']}",
              "postalCode": address['pincode'],
              "country": address['state'],
              "first_name": address['first_name'],
              "last_name": address['last_name'],
              "email": address['email'],
              "phone": address['phone'],
              "address1": address['address1'],
              "address2": address['address2'],
              "default_address": address['default_address'] == '1',
            };
          }).toList();
      print('Address Data: ${_addressList}');
    } else {
      print('Error: ${result['message']}');
      _addressList.clear(); // Clear list on error
    }
  }

  // Toggle checkbox state
  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
  }

  String addressMessage = "";

  // Populate form fields for editing
  void populateFormForEdit(Map<String, dynamic> address) {
    firstNameController.text = address['first_name'] ?? '';
    lastNameController.text = address['last_name'] ?? '';
    emailController.text = address['email'] ?? '';
    phoneController.text = address['phone'] ?? '';
    addressLine1Controller.text = address['address1'] ?? '';
    addressLine2Controller.text = address['address2'] ?? '';
    zipController.text = address['postalCode'] ?? '';
    stateController.text = address['country'] ?? '';
    cityController.text = address['city'] ?? '';
    isChecked.value = address['default_address'] ?? 0;
  }

  // Clear form fields
  void clearForm() {
    zipController.clear();
    stateController.clear();
    cityController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    phoneController.clear();
    isChecked.value = false;
  }

  final CheckoutController checkoutController = Get.put(CheckoutController());

  Future<bool> handleAddAddress(
    BuildContext context, {
    bool isEditing = false,
    String? addressId,
  }) async {
    if (formKey.currentState!.validate()) {
      String formattedDate = getFormattedDate();
      String? userId = await SharedPreferencesHelper.getUserId();

      try {
        var response;
        if (isEditing && addressId != null) {
          // Update existing address
          response = await ApiHelper.editUserAddress(
            addressId: addressId,
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            address1: addressLine1Controller.text,
            address2: addressLine2Controller.text,
            state: stateController.text,
            pinCode: zipController.text,
            city: cityController.text,
            updatedAt: formattedDate,
            defaultAddress: isChecked.value ? "1" : "0",
            createdBy: userId.toString(),
          );
        } else {
          // Add new address
          response = await ApiHelper.registerAddress(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            address1: addressLine1Controller.text,
            address2: addressLine2Controller.text,
            state: stateController.text,
            pinCode: zipController.text,
            city: cityController.text,
            updatedAt: 'null',
            defaultAddress: isChecked.value ? "1" : "0",
            createdBy: userId.toString(),
            createdAt: formattedDate,
          );
        }

        print("${isEditing ? 'Update' : 'Add'} address Response: $response");

        if (response['error'] == true) {
          addressMessage =
              response['message'] ??
              "${isEditing ? 'Update' : 'Add'} address failed";
          return false;
        } else {
          // Success case
          addressMessage =
              isEditing
                  ? "Address updated successfully"
                  : "Address added successfully";
          await fetchAddress();
          checkoutController.loadAddressData();
          clearForm();

          return true;
        }
      } catch (e) {
        print("${isEditing ? 'Update' : 'Add'} address exception: $e");
        addressMessage =
            "An error occurred while ${isEditing ? 'updating' : 'adding'} the address";
        return false;
      }
    } else {
      addressMessage = "Please fill all fields correctly";
      return false;
    }
  }

  @override
  void onClose() {
    zipController.dispose();
    stateController.dispose();
    cityController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    phoneController.dispose();
    super.onClose();
  }

  static Future<void> saveUserAddressData({
    required int addressId,
    required String address1,
    required String address2,
    required String pincode,
    required String state,
    required String city,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('addressId', addressId);
    await prefs.setString('address1', address1);
    await prefs.setString('address2', address2);
    await prefs.setString('pincode', pincode);
    await prefs.setString('state', state);
    await prefs.setString('city', city);
  }
}
