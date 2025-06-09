import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';

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
  bool showLoginBox = true; // initially show the login container
  bool isChecked = false;
  bool showSuccessBanner = false; // Add this line
  bool showErrorBanner = false;
  String errorMessage = "";
  @override
  void initState() {
    super.initState();
    // Populate form fields if editing
    if (widget.isEditing && widget.address != null) {
      controller.populateFormForEdit(widget.address!);
    } else {
      controller.clearForm();
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

      // Verify the saved address ID
      String? savedAddressId =
      await SharedPreferencesHelper.getSelectedAddress();
      print('Verified Saved Address ID: $savedAddressId');

      // Update CheckoutController with the selected address
      // checkoutController.updateSelectedAddress(address);

      // Show success toast
      // CustomToast.showToast('Address selected successfully');

      // Close the dialog
      Navigator.of(context).pop();

      // Trigger reload of address data to ensure UI reflects the selected address
      await checkoutController.loadAddressData();
    } catch (e) {
      print('Error saving selected address: $e');
      // CustomToast.showToast('Error saving address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    "assets/icons/closeIcon.svg",
                    height: 18,
                    width: 18,
                  ),
                ),

                const SizedBox(height: 20),
                if (showSuccessBanner || showErrorBanner)
                  NotificationBanner(
                    message:
                        showSuccessBanner
                            ? (widget.isEditing
                                ? "Updated successfully!"
                                : "Added successfully!")
                            : errorMessage,
                    bannerColor: showSuccessBanner ? Colors.green : Colors.red,
                    textColor: Colors.black,
                    onClose: () {
                      setState(() {
                        showSuccessBanner = false;
                        showErrorBanner = false;
                      });
                    },
                  ),
                const SizedBox(height: 20),
                CralikaFont(
                  text: "Update Address",
                  color: const Color(0xFF414141),
                  fontWeight: FontWeight.w400,
                  fontSize: 24.0,
                  lineHeight: 1.0,
                  letterSpacing: 0.128,
                ),
                SizedBox(height: 8),

                BarlowText(
                  text: "Select another saved address, or add a new one.",
                  color: Color(0xFF414141),
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  lineHeight: 1.0,
                  letterSpacing: 0.128,
                ),
                SizedBox(height: 32),
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
                              border: Border.all(
                                color: Color(0xFFDDEAFF),
                                width: 1,
                              ),
                            ),

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
                                  print(
                                    'Address Item: $address',
                                  ); // Debug print for each address
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(
                                              0xFFDDEAFF,
                                            ).withOpacity(0.6),
                                            offset: Offset(20, 20),
                                            blurRadius: 20,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Color(0xFFDDEAFF),
                                          width: 1,
                                        ),
                                      ),

                                      child: Padding(
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
                                                    MainAxisAlignment
                                                        .spaceAround,
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
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                        lineHeight: 1.5,
                                                        letterSpacing: 0.0,
                                                        color: Color(
                                                          0xFF30578E,
                                                        ),
                                                        hoverBackgroundColor:
                                                            Color(0xFFb9d6ff),
                                                        enableHoverBackground:
                                                            true,
                                                        onTap: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();

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
                                                                address:
                                                                    address,
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
                                                        letterSpacing: 0.0,
                                                        color: Color(
                                                          0xFF30578E,
                                                        ),
                                                      ),
                                                      BarlowText(
                                                        text:
                                                            "SELECT THIS ADDRESS",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                        lineHeight: 1.5,
                                                        letterSpacing: 0.0,
                                                        color: Color(
                                                          0xFF30578E,
                                                        ),
                                                        hoverBackgroundColor:
                                                            Color(0xFFb9d6ff),
                                                        enableHoverBackground:
                                                            true,
                                                        onTap:
                                                            () =>
                                                                _saveSelectedAddress(
                                                                  address,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                ),

                const SizedBox(height: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
