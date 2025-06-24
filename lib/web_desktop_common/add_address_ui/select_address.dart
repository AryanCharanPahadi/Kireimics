import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web/checkout/checkout_controller.dart';
import 'add_address_controller.dart';
import 'add_address_ui.dart';

class SelectAddress extends StatefulWidget {
  final Map<String, dynamic>? address;
  final bool isEditing;

  const SelectAddress({super.key, this.address, this.isEditing = false});

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  final AddAddressController controller = Get.put(AddAddressController());
  final CheckoutController checkoutController = Get.put(CheckoutController());
  final RxString selectedAddressId = ''.obs;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.address != null) {
      controller.populateFormForEdit(widget.address!);
    } else {
      controller.clearForm();
    }

    _loadSelectedAddressId();
  }

  Future<void> _loadSelectedAddressId() async {
    final savedId = await SharedPreferencesHelper.getSelectedAddress();
    if (savedId != null) {
      selectedAddressId.value = savedId;
    } else {
      // Check for default address if no selected address is found
      String? userId = await SharedPreferencesHelper.getUserId();
      if (userId != null && int.tryParse(userId) != null) {
        final response = await ApiHelper.getDefaultAddress(int.parse(userId));
        if (response['error'] == false &&
            response['data'] != null &&
            response['data'].isNotEmpty) {
          final defaultAddressId = response['data'][0]['id']?.toString();
          if (defaultAddressId != null) {
            await SharedPreferencesHelper.saveSelectedAddress(defaultAddressId);
            selectedAddressId.value = defaultAddressId;
            await checkoutController.loadAddressData();
          }
        }
      }
    }
  }

  // Method to save selected address to SharedPreferences and update CheckoutController
  Future<void> _saveSelectedAddress(Map<String, dynamic> address) async {
    try {
      // Ensure the address has an ID
      if (address['id'] == null) {
        print('Error: Address ID is missing');
        // CustomToast.showToast('Error: Address ID is missing');
        return;
      }

      // Print the selected address ID for debugging
      print('Saving Selected Address ID: ${address['id']}');

      // Save the address ID to SharedPreferences
      await SharedPreferencesHelper.saveSelectedAddress(
        address['id'].toString(),
      );
      selectedAddressId.value =
          address['id'].toString(); // Update local observable

      // Verify the saved address ID
      String? savedAddressId =
          await SharedPreferencesHelper.getSelectedAddress();
      print('Verified Saved Address ID: $savedAddressId');

      // Trigger reload of address data to ensure UI reflects the selected address
      await checkoutController.loadAddressData();
    } catch (e) {
      print('Error saving selected address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        CralikaFont(
          text: "Select Delivery Address",
          color: Color(0xFF414141),
          fontWeight: FontWeight.w600,
          fontSize: 20.0,
          lineHeight: 1.0,
          letterSpacing: 0.128,
        ),

        SizedBox(height: 24),
        Obx(
          () =>
              controller.addressList.isEmpty
                  ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFDDEAFF).withOpacity(0.6),
                          offset: Offset(20, 20),
                          blurRadius: 20,
                        ),
                      ],
                      border: Border.all(color: Color(0xFFDDEAFF), width: 1),
                    ),
                    width: MediaQuery.of(context).size.width * 0.35,
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: BarlowText(
                        text: "No addresses found. Add a new address.",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        lineHeight: 1.4,
                        letterSpacing: 0.0,
                        color: Color(0xFF636363),
                      ),
                    ),
                  )
                  : Column(
                    children:
                        controller.addressList.map((address) {
                          print('=== Address in List ===');
                          print('Address Item: $address');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFDDEAFF).withOpacity(0.6),
                                    offset: Offset(20, 20),
                                    blurRadius: 20,
                                  ),
                                ],
                                border: Border.all(
                                  color: Color(0xFFDDEAFF),
                                  width: 1,
                                ),
                              ),
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      top: 13,
                                      bottom: 13,
                                      right: 10,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 56,
                                          width: 56,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFDDEAFF),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/icons/location.svg",
                                              height: 27,
                                              width: 25,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 24),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              BarlowText(
                                                text:
                                                    address["city"]
                                                        ?.toString() ??
                                                    '',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20,
                                                lineHeight: 1.0,
                                                letterSpacing: 0.0,
                                                color: Color(0xFF414141),
                                              ),
                                              SizedBox(height: 3),
                                              BarlowText(
                                                text:
                                                    address["name"]
                                                        ?.toString() ??
                                                    '',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                lineHeight: 1.4,
                                                letterSpacing: 0.0,
                                                color: Color(0xFF636363),
                                              ),
                                              SizedBox(height: 3),
                                              BarlowText(
                                                text:
                                                    address["address"]
                                                        ?.toString() ??
                                                    '',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                lineHeight: 1.4,
                                                letterSpacing: 0.0,
                                                color: Color(0xFF636363),
                                              ),
                                              SizedBox(height: 3),
                                              BarlowText(
                                                text:
                                                    "${address["postalCode"]?.toString() ?? ''} - ${address["state"]?.toString() ?? ''}",
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                lineHeight: 1.4,
                                                letterSpacing: 0.0,
                                                color: Color(0xFF636363),
                                              ),
                                              SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  BarlowText(
                                                    text: "EDIT",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    lineHeight: 1.5,
                                                    letterSpacing: 0.0,
                                                    color: Color(0xFF30578E),
                                                    hoverBackgroundColor: Color(
                                                      0xFFb9d6ff,
                                                    ),
                                                    hoverTextColor: Color(
                                                      0xFF2876E4,
                                                    ),

                                                    enableHoverBackground: true,
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        barrierColor:
                                                            Colors.transparent,
                                                        builder: (
                                                          BuildContext context,
                                                        ) {
                                                          return AddAddressUi(
                                                            address: address,
                                                            isEditing: true,
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  BarlowText(
                                                    text: " / ",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    lineHeight: 1.5,
                                                    letterSpacing: 0.0,
                                                    color: Color(0xFF30578E),
                                                  ),
                                                  Obx(() {
                                                    final isSelected =
                                                        selectedAddressId
                                                            .value ==
                                                        address['id']
                                                            .toString();
                                                    return InkWell(
                                                      onTap:
                                                          () =>
                                                              _saveSelectedAddress(
                                                                address,
                                                              ),
                                                      hoverColor: Color(
                                                        0xFFb9d6ff,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (isSelected) ...[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: Color(
                                                                0xFF2876E4,
                                                              ),
                                                              size: 20,
                                                            ),
                                                            SizedBox(width: 2),
                                                          ],
                                                          BarlowText(
                                                            text:
                                                                isSelected
                                                                    ? "SELECTED!"
                                                                    : "SELECT THIS ADDRESS",
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            lineHeight: 1.5,
                                                            hoverBackgroundColor:
                                                                Color(
                                                                  0xFFb9d6ff,
                                                                ),
                                                            enableHoverBackground:
                                                                true,
                                                            hoverTextColor:
                                                                Color(
                                                                  0xFF2876E4,
                                                                ),
                                                            letterSpacing: 0.0,
                                                            color:
                                                                isSelected
                                                                    ? Color(
                                                                      0xFF2876E4,
                                                                    )
                                                                    : Color(
                                                                      0xFF30578E,
                                                                    ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Add DEFAULT badge if this is the default address
                                  if (address['default_address'] == true ||
                                      address['default_address'] == true)
                                    Positioned(
                                      top: 14,
                                      right: 38,
                                      child: BarlowText(
                                        text: "DEFAULT",
                                        fontWeight:
                                            FontWeight
                                                .w500, // font-weight: 500;
                                        fontSize: 14, // font-size: 14px;
                                        lineHeight: 1.4, // line-height: 140%;
                                        letterSpacing: 0.0,
                                        color: Color(
                                          0xFFB9D6FF,
                                        ), // letter-spacing: 0%;
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BarlowText(
              text: "ADD NEW ADDRESS",
              color: const Color(0xFF30578E),
              fontWeight: FontWeight.w600,
              fontSize: 16,
              lineHeight: 1.0,
              letterSpacing: 0.64,
              hoverBackgroundColor: Color(0xFFb9d6ff),
              enableHoverBackground: true,
              hoverTextColor: Color(0xFF2876E4),
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return AddAddressUi();
                  },
                );
              },
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
