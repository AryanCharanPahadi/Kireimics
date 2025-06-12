import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';

class ProceedToCheckoutButton extends StatelessWidget {
  final double subtotal;
  final Map<int, int> productQuantities; // Product IDs and quantities
  final Map<int, double> productPrices; // Product IDs and prices
  final Map<int, double?> productHeights; // Product IDs and heights
  final Map<int, double?> productWidths; // Product IDs and widths
  final Map<int, double?> productLengths; // Product IDs and lengths
  final Map<int, double?> productWeights; // Product IDs and weights

  const ProceedToCheckoutButton({
    Key? key,
    required this.subtotal,
    required this.productQuantities,
    required this.productPrices,
    required this.productHeights,
    required this.productWidths,
    required this.productLengths,
    required this.productWeights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert product IDs, quantities, prices, heights, widths, lengths, and weights to comma-separated strings for URL
    final productIds = productQuantities.keys.join(',');
    final quantities = productQuantities.values.join(',');
    final prices = productPrices.values
        .map((price) => price.toStringAsFixed(2))
        .join(',');
    final heights = productHeights.values
        .map((height) => height?.toStringAsFixed(2) ?? 'null')
        .join(',');
    final widths = productWidths.values
        .map((width) => width?.toStringAsFixed(2) ?? 'null')
        .join(',');
    final lengths = productLengths.values
        .map((length) => length?.toStringAsFixed(2) ?? 'null')
        .join(',');
    final weights = productWeights.values
        .map((weight) => weight?.toStringAsFixed(2) ?? 'null')
        .join(',');

    return Container(
      height: 100,
      color: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.only(left: 22.0, top: 21, bottom: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
              onTap: () {
                context.go(
                  '${AppRoutes.checkOut}?subtotal=${subtotal.toStringAsFixed(2)}'
                      '&productIds=$productIds'
                      '&productPrices=$prices'
                      '&quantities=$quantities'
                      '&heights=$heights'
                      '&widths=$widths'
                      '&lengths=$lengths'
                      '&weights=$weights',
                );
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
    );
  }
}