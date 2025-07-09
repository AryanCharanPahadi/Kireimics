import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../component/text_fonts/custom_text.dart';
import '../../component/notification_toast/custom_toast.dart';
import '../../component/utilities/utility.dart';
import '../../web/checkout/checkout_controller.dart';
import 'add_address_controller.dart';

class DeleteAddress extends StatefulWidget {
  final String addressId;

  const DeleteAddress({super.key, required this.addressId});

  @override
  State<DeleteAddress> createState() => _DeleteAddressState();
}

class _DeleteAddressState extends State<DeleteAddress> {
  bool showSuccessBanner = false;
  bool showErrorBanner = false;

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutController = Get.put(CheckoutController());

    final AddAddressController addAddressController = Get.put(
      AddAddressController(),
    );
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: BarlowText(
                              text: "Close",
                              color: const Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              hoverTextColor: const Color(0xFF2876E4),
                            ),
                          ),
                          if (showSuccessBanner || showErrorBanner)
                            NotificationBanner(
                              iconPath:
                                  showSuccessBanner
                                      ? "assets/icons/success.svg"
                                      : "assets/icons/error.svg",
                              message:
                                  showSuccessBanner
                                      ? "Address deleted successfully!"
                                      : "Failed to delete address!",
                              bannerColor:
                                  showSuccessBanner
                                      ? Color(0xFF268FA2)
                                      : Color(0xFFF46856),
                              textColor: Color(0xFF28292A),
                              onClose: () {
                                setState(() {
                                  showSuccessBanner = false;
                                  showErrorBanner = false;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 33),
                      CralikaFont(
                        text: "Delete Address?",
                        color: const Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                        fontSize: 32.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      const SizedBox(height: 8),
                      BarlowText(
                        text:
                            "Are you sure you would like to delete this address?",
                        color: const Color(0xFF414141),
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: BarlowText(
                          text: "DELETE NOW",
                          color: const Color(0xFF30578E),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          lineHeight: 1.0,
                          letterSpacing: 0.64,
                          backgroundColor: const Color(0xFFb9d6ff),
                          hoverTextColor: const Color(0xFF2876E4),
                          onTap: () async {
                            bool success = await addAddressController
                                .deleteAddress(widget.addressId);
                            if (mounted) {
                              setState(() {
                                showSuccessBanner = success;
                                showErrorBanner = !success;
                              });
                              if (success) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final selectedAddress = prefs.getString(
                                  'selectedAddress',
                                );
                                if (selectedAddress == widget.addressId) {
                                  await prefs.remove('selectedAddress');
                                }

                                // Reload address data
                                checkoutController.loadAddressData();
                                checkoutController.refreshDefaultAddress();

                                // Close the dialog after 2 seconds
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                });
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: BarlowText(
                          text: "CANCEL",
                          color: const Color(0xFF30578E),
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          lineHeight: 1.0,
                          letterSpacing: 0.64,
                          hoverTextColor: const Color(0xFF2876E4),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
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
}
