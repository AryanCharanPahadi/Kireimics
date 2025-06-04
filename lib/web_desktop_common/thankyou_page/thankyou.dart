import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../../component/text_fonts/custom_text.dart';

class PaymentResultPage extends StatelessWidget {
  final bool isSuccess;
  final String orderId;
  final double amount;

  const PaymentResultPage({
    super.key,
    required this.isSuccess,
    required this.orderId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = screenWidth.clamp(800.0, 1400.0);
    final contentWidth = (effectiveWidth - 100).clamp(300.0, double.infinity);
    final fontScale = (contentWidth / 600).clamp(0.8, 1.0);
    // Calculate subtotal (amount is total, which includes deliveryCharge)
    const double deliveryCharge = 50.0; // Same as in CheckoutPageWeb
    final double subtotal = amount - deliveryCharge;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                SvgPicture.asset(
                  isSuccess
                      ? 'assets/icons/success_icon.svg'
                      : 'assets/icons/error_icon.svg',
                  width: 80 * fontScale,
                  height: 80 * fontScale,
                ),
                SizedBox(height: 24 * fontScale),
                // Title
                CralikaFont(
                  text:
                      isSuccess
                          ? 'Thank You for Your Purchase!'
                          : 'Sorry, Payment Not Successful',
                  fontWeight: FontWeight.w400,
                  fontSize: (32 * fontScale).clamp(24, 32),
                  lineHeight: 36 / 32,
                  letterSpacing: 1.28 * fontScale,
                  color: const Color(0xFF414141),
                ),
                SizedBox(height: 16 * fontScale),
                // Message
                BarlowText(
                  text:
                      isSuccess
                          ? 'Your order has been successfully placed. You will receive a confirmation email soon.'
                          : 'Something went wrong with your payment. Please try again or contact support.',
                  fontWeight: FontWeight.w400,
                  fontSize: (16 * fontScale).clamp(14, 16),
                  lineHeight: 1.5,
                  color: const Color(0xFF414141),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24 * fontScale),
                // Order Details (for success)
                if (isSuccess) ...[
                  Container(
                    padding: EdgeInsets.all(16 * fontScale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDDEAFF).withOpacity(0.6),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    width: contentWidth * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BarlowText(
                          text: 'Order Details',
                          fontWeight: FontWeight.w600,
                          fontSize: (18 * fontScale).clamp(16, 18),
                          color: const Color(0xFF30578E),
                        ),
                        SizedBox(height: 8 * fontScale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BarlowText(
                              text: 'Order ID:',
                              fontWeight: FontWeight.w400,
                              fontSize: (16 * fontScale).clamp(14, 16),
                              color: const Color(0xFF414141),
                            ),
                            BarlowText(
                              text: orderId,
                              fontWeight: FontWeight.w400,
                              fontSize: (16 * fontScale).clamp(14, 16),
                              color: const Color(0xFF414141),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * fontScale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BarlowText(
                              text: 'Total Amount:',
                              fontWeight: FontWeight.w400,
                              fontSize: (16 * fontScale).clamp(14, 16),
                              color: const Color(0xFF414141),
                            ),
                            BarlowText(
                              text: 'Rs. ${amount.toStringAsFixed(2)}',
                              fontWeight: FontWeight.w400,
                              fontSize: (16 * fontScale).clamp(14, 16),
                              color: const Color(0xFF414141),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * fontScale),
                ],
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isSuccess) ...[
                      GestureDetector(
                        onTap: () {
                          context.go(
                            '${AppRoutes.checkOut}?subtotal=$subtotal',
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * fontScale,
                            vertical: 8 * fontScale,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFb9d6ff),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: BarlowText(
                            text: "Retry Payment",
                            color: const Color(0xFF30578E),
                            fontWeight: FontWeight.w600,
                            fontSize: (16 * fontScale).clamp(12, 16),
                            lineHeight: 1.0,
                            letterSpacing: 0.64 * fontScale,
                          ),
                        ),
                      ),
                      SizedBox(width: 16 * fontScale),
                    ],
                    GestureDetector(
                      onTap: () {
                        context.go('/'); // Adjust to your home route
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * fontScale,
                          vertical: 8 * fontScale,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF30578E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: BarlowText(
                          text: "Back to Home",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: (16 * fontScale).clamp(12, 16),
                          lineHeight: 1.0,
                          letterSpacing: 0.64 * fontScale,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
