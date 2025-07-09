import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';
import '../../web/checkout/checkout_controller.dart';

class ProceedToCheckoutButton extends StatelessWidget {
  final double subtotal;
  final Map<int, int> productQuantities; // Product IDs and quantities
  final Map<int, double> productPrices; // Product IDs and prices
  final Map<int, String> productNames; // Product IDs and names
  final Map<int, double?> productHeights; // Product IDs and heights
  final Map<int, double?> productBreadths; // Product IDs and breadths
  final Map<int, double?> productLengths; // Product IDs and lengths
  final Map<int, double?> productWeights; // Product IDs and weights

  const ProceedToCheckoutButton({
    Key? key,
    required this.subtotal,
    required this.productQuantities,
    required this.productPrices,
    required this.productNames,
    required this.productHeights,
    required this.productBreadths,
    required this.productLengths,
    required this.productWeights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutController = Get.put(CheckoutController());

    final productIds = productQuantities.keys.join(',');
    final quantities = productQuantities.values.join(',');
    final prices = productPrices.values
        .map((price) => price.toStringAsFixed(2))
        .join(',');
    final names = productNames.values
        .map((name) => Uri.encodeComponent(name))
        .join(',');
    final heights = productHeights.values
        .map((h) => h?.toString() ?? '0')
        .join(',');
    final breadths = productBreadths.values
        .map((b) => b?.toString() ?? '0')
        .join(',');
    final lengths = productLengths.values
        .map((l) => l?.toString() ?? '0')
        .join(',');
    final weights = productWeights.values
        .map((w) => w?.toString() ?? '0')
        .join(',');

    return Container(
      height: 100,
      color: Colors.white.withOpacity(0.94),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal line at the top
          Container(height: 1, color: Color(0xFFB9D6FF)),
          Padding(
            padding: const EdgeInsets.only(left: 22.0, top: 21, bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BarlowText(
                  text: "Rs. ${subtotal.toStringAsFixed(2)}",
                  color: Color(0xFF30578E),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  lineHeight: 1.0,
                  letterSpacing: 1 * 0.04,
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final router = GoRouter.of(context);
                    final currentRoute =
                        router.routeInformationProvider.value.uri.toString();
                    final checkoutUrl =
                        '${AppRoutes.checkOut}?'
                        '&productIds=$productIds'
                        '&quantities=$quantities';
                    if (currentRoute.contains(AppRoutes.checkOut)) {
                      await checkoutController.loadUserData();
                      await checkoutController.loadAddressData();
                      await checkoutController.getShippingTax();

                      Navigator.of(context).pop();
                    }

                    context.go(checkoutUrl);
                  },
                  child: BarlowText(
                    text: "PROCEED TO CHECKOUT",
                    color: Color(0xFF30578E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    backgroundColor: Color(0xFFB9D6FF),
                    lineHeight: 1.0,
                    letterSpacing: 1 * 0.04,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
