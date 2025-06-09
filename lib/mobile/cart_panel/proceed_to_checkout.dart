import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';

class ProceedToCheckoutButton extends StatelessWidget {
  final double subtotal;

  const ProceedToCheckoutButton({Key? key, required this.subtotal})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  '${AppRoutes.checkOut}?subtotal=${subtotal.toStringAsFixed(2)}',
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
