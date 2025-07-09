import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../web/checkout/checkout_controller.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';

class SelectAddressMobile extends StatefulWidget {
  final Map<String, dynamic>? address;
  final bool isEditing;

  const SelectAddressMobile({super.key, this.address, this.isEditing = false});

  @override
  State<SelectAddressMobile> createState() => _SelectAddressMobileState();
}

class _SelectAddressMobileState extends State<SelectAddressMobile> {
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
        // print('Error: Address ID is missing');
        // CustomToast.showToast('Error: Address ID is missing');
        return;
      }

      // Print the selected address ID for debugging
      // print('Saving Selected Address ID: ${address['id']}');

      // Save the address ID to SharedPreferences
      await SharedPreferencesHelper.saveSelectedAddress(
        address['id'].toString(),
      );
      selectedAddressId.value =
          address['id'].toString(); // Update local observable

      // Verify the saved address ID
      String? savedAddressId =
          await SharedPreferencesHelper.getSelectedAddress();
      // print('Verified Saved Address ID: $savedAddressId');

      // Trigger reload of address data to ensure UI reflects the selected address
      await checkoutController.loadAddressData();
    } catch (e) {
      // print('Error saving selected address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          CralikaFont(
            text: "Select Delivery Address",
            color: const Color(0xFF414141),
            fontWeight: FontWeight.w400,
            fontSize: 24.0,
            lineHeight: 1.0,
            letterSpacing: 0.128,
          ),
          SizedBox(height: 24),

          Obx(
            () =>
                controller.addressList.isEmpty
                    ? Container(
                      // ... No addresses found UI ...
                    )
                    : Column(
                      children:
                          controller.addressList.map((address) {
                            // print(
                            //   "Default Address Field: ${address['default_address']}",
                            // );
                            // print(
                            //   "Is Default? ${address['default_address'] == true}",
                            // );

                            // print('=== Address in List ===');
                            // print('Address Item: $address');
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                  color: Color(0xFF636363),
                                                ),
                                                SizedBox(height: 3),
                                                BarlowText(
                                                  text:
                                                      "${address["postalCode"]?.toString() ?? ''} - ${address["state"]?.toString() ?? ''}",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  lineHeight: 1.4,
                                                  color: Color(0xFF636363),
                                                ),
                                                SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    BarlowText(
                                                      text: "EDIT",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      lineHeight: 1.5,
                                                      color: Color(0xFF30578E),
                                                      hoverBackgroundColor:
                                                          Color(0xFFb9d6ff),
                                                      enableHoverBackground:
                                                          true,
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierColor:
                                                              Colors
                                                                  .transparent,
                                                          builder: (
                                                            BuildContext
                                                            context,
                                                          ) {
                                                            return AddAddressUiMobile(
                                                              address: address,
                                                              isEditing: true,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    BarlowText(
                                                      text: " / ",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      lineHeight: 1.5,
                                                      color: Color(0xFF30578E),
                                                    ),
                                                    // Wrap the selection UI in its own Obx
                                                    Obx(() {
                                                      final isSelected =
                                                          selectedAddressId
                                                              .value ==
                                                          address['id']
                                                              .toString();
                                                      // print(
                                                      //   'Address ID: ${address['id']}',
                                                      // );
                                                      // print(
                                                      //   'Selected Address ID: ${selectedAddressId.value}',
                                                      // );
                                                      // print(
                                                      //   'Is Selected: $isSelected',
                                                      // );
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
                                                              SizedBox(
                                                                width: 2,
                                                              ),
                                                            ],
                                                            BarlowText(
                                                              text:
                                                                  isSelected
                                                                      ? "SELECTED!"
                                                                      : "SELECT THIS ADDRESS",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              lineHeight: 1.5,
                                                              hoverTextColor:
                                                                  Color(
                                                                    0xFF2876E4,
                                                                  ),
                                                              letterSpacing:
                                                                  0.0,
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
                                    if (address['default_address'] == true ||
                                        address['default_address'] == true)
                                      Positioned(
                                        top: 14,
                                        right: 38,
                                        child: BarlowText(
                                          text: "DEFAULT",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          lineHeight: 1.4,
                                          color: Color(0xFFB9D6FF),
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
                      return AddAddressUiMobile();
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
