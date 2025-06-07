import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../component/notification_toast/custom_toast.dart';
import '../../component/utilities/utility.dart';
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
        return;
      }

      // Print the selected address ID
      print('Selected Address ID: ${address['id']}');

      // Save only the address ID to SharedPreferences
      await SharedPreferencesHelper.saveSelectedAddress(
        address['id'].toString(),
      );

      // Update CheckoutController with address details (still needed for UI)
      checkoutController.address1Controller.text =
          address['address']?.toString() ?? '';
      checkoutController.address2Controller.text =
          address['address2']?.toString() ?? '';
      checkoutController.zipController.text =
          address['postalCode']?.toString() ?? '';
      checkoutController.stateController.text =
          address['state']?.toString() ?? '';
      checkoutController.cityController.text =
          address['city']?.toString() ?? '';
      checkoutController.addressExists(true);

      // Show success toast (uncomment if needed)
      // CustomToast.showSuccess(context, 'Address selected successfully');

      // Close the dialog
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving selected address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Stack(
      children: [
        BlurredBackdrop(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isLargeScreen ? 600 : 550,
            child: Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: BarlowText(
                              text: "Close",
                              color: Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              hoverTextColor: const Color(0xFF2876E4),

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 33),
                      CralikaFont(
                        text: "Update Address",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                        fontSize: 32.0,
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: BarlowText(
                                      text:
                                          "No addresses found. Add a new address.",
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
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.35,
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
                                                          BorderRadius.circular(
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
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        BarlowText(
                                                          text:
                                                              address["city"]
                                                                  ?.toString() ??
                                                              '',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 20,
                                                          lineHeight: 1.0,
                                                          letterSpacing: 0.0,
                                                          color: Color(
                                                            0xFF414141,
                                                          ),
                                                        ),
                                                        SizedBox(height: 3),
                                                        BarlowText(
                                                          text:
                                                              address["name"]
                                                                  ?.toString() ??
                                                              '',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          lineHeight: 1.4,
                                                          letterSpacing: 0.0,
                                                          color: Color(
                                                            0xFF636363,
                                                          ),
                                                        ),
                                                        SizedBox(height: 3),
                                                        BarlowText(
                                                          text:
                                                              address["address"]
                                                                  ?.toString() ??
                                                              '',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          lineHeight: 1.4,
                                                          letterSpacing: 0.0,
                                                          color: Color(
                                                            0xFF636363,
                                                          ),
                                                        ),
                                                        SizedBox(height: 3),
                                                        BarlowText(
                                                          text:
                                                              "${address["postalCode"]?.toString() ?? ''} - ${address["state"]?.toString() ?? ''}",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          lineHeight: 1.4,
                                                          letterSpacing: 0.0,
                                                          color: Color(
                                                            0xFF636363,
                                                          ),
                                                        ),
                                                        SizedBox(height: 3),
                                                        Row(
                                                          children: [
                                                            BarlowText(
                                                              text: "EDIT",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              lineHeight: 1.5,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color(
                                                                0xFF30578E,
                                                              ),
                                                              hoverBackgroundColor:
                                                                  Color(
                                                                    0xFFb9d6ff,
                                                                  ),
                                                              enableHoverBackground:
                                                                  true,
                                                              onTap: () {
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();

                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  barrierColor:
                                                                      Colors
                                                                          .transparent,
                                                                  builder: (
                                                                    BuildContext
                                                                    context,
                                                                  ) {
                                                                    return AddAddressUi(
                                                                      address:
                                                                          address,
                                                                      isEditing:
                                                                          true,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                            BarlowText(
                                                              text: " / ",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              lineHeight: 1.5,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color(
                                                                0xFF30578E,
                                                              ),
                                                            ),
                                                            BarlowText(
                                                              text:
                                                                  "SELECT THIS ADDRESS",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              lineHeight: 1.5,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color(
                                                                0xFF30578E,
                                                              ),
                                                              hoverBackgroundColor:
                                                                  Color(
                                                                    0xFFb9d6ff,
                                                                  ),
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
                      SizedBox(height: 32),
                      Center(
                        child: BarlowText(
                          text: "ADD NEW ADDRESS",
                          color: const Color(0xFF30578E),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          lineHeight: 1.0,
                          letterSpacing: 0.64,
                          backgroundColor: Color(0xFFb9d6ff),
                          hoverTextColor: Color(0xFF2876E4),
                          onTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return AddAddressUi();
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    bool enabled = true,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 13,
          child: Text(
            hintText,
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF414141),
            ),
          ),
        ),
        TextFormField(
          validator: validator,
          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: Color(0xFF414141),
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            errorStyle: TextStyle(color: Colors.red),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            hintText: '',
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: Color(0xFF414141),
            ),
            contentPadding: EdgeInsets.only(top: 16),
          ),
          style: TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
