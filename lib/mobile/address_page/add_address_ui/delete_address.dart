import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../web/checkout/checkout_controller.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';

class DeleteAddressMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final Function(String)? onErrorWishlistChanged; // Callback to notify parent
  const DeleteAddressMobile({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });

  @override
  State<DeleteAddressMobile> createState() => _DeleteAddressMobileState();
}

class _DeleteAddressMobileState extends State<DeleteAddressMobile> {
  final CheckoutController checkoutController = Get.put(CheckoutController());
  final AddAddressController addAddressController = Get.put(
    AddAddressController(),
  );

  late int addressId;

  bool showSuccessBanner = false;
  bool showErrorBanner = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    addressId = int.tryParse(uri.queryParameters['addressId'] ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                context.go(AppRoutes.myAccount);
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
                iconPath:
                    showSuccessBanner
                        ? "assets/icons/success.svg"
                        : "assets/icons/error.svg",

                message:
                    showSuccessBanner ? "Deleted successfully!" : errorMessage,
                bannerColor:
                    showSuccessBanner ? Color(0xFF268FA2) : Color(0xFFF46856),
                textColor: Color(0xFF28292A),
                onClose: () {
                  setState(() {
                    showSuccessBanner = false;
                    showErrorBanner = false;
                  });
                },
              ),

            const SizedBox(height: 20),

            CralikaFont(
              text: "Delete Address?",
              color: const Color(0xFF414141),
              fontWeight: FontWeight.w400,
              fontSize: 24.0,
              lineHeight: 1.0,
              letterSpacing: 0.128,
            ),
            const SizedBox(height: 8),

            BarlowText(
              text: "Are you sure you would like to delete this address?",
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
                fontSize: 14,
                lineHeight: 1.0,
                letterSpacing: 0.64,
                backgroundColor: const Color(0xFFb9d6ff),
                hoverTextColor: const Color(0xFF2876E4),
                onTap: () async {
                  bool success = await addAddressController.deleteAddress(
                    addressId.toString(),
                  );
                  if (mounted) {
                    setState(() {
                      showSuccessBanner = success;
                      showErrorBanner = !success;
                    });
                    if (success) {
                      final prefs = await SharedPreferences.getInstance();
                      final selectedAddress = prefs.getString(
                        'selectedAddress',
                      );
                      if (selectedAddress == addressId) {
                        await prefs.remove('selectedAddress');
                      }

                      // Reload address data
                      checkoutController.loadAddressData();
                      checkoutController.refreshDefaultAddress();

                      // Close the dialog after 2 seconds
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          context.go(AppRoutes.myAccount);
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
                fontSize: 14,
                lineHeight: 1.0,
                letterSpacing: 0.64,
                backgroundColor: const Color(0xFFb9d6ff),
                hoverTextColor: const Color(0xFF2876E4),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),

            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}
