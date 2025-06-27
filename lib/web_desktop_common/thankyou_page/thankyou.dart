import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:kireimics/component/app_routes/routes.dart';
import '../../component/text_fonts/custom_text.dart';

class PaymentResultPage extends StatelessWidget {
  final bool isSuccess;
  final String orderId;
  final double amount;
  final DateTime orderDate;

  const PaymentResultPage({
    super.key,
    required this.isSuccess,
    required this.orderId,
    required this.amount,
    required this.orderDate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = screenWidth.clamp(800.0, 1400.0);
    final contentWidth = (effectiveWidth - 100).clamp(300.0, double.infinity);
    final fontScale = (contentWidth / 600).clamp(0.8, 1.0);
    const double deliveryCharge = 50.0;
    final double subtotal = amount - deliveryCharge;

    final DateFormat dateFormatter = DateFormat('EEE, dd MMM yyyy / h:mm a');
    final String formattedDate = dateFormatter.format(orderDate);

    return Scaffold(
      backgroundColor: Color(0xFF268FA2),
      body: Stack(
        children: [
          // Background Image
          Positioned(
            left:
                screenWidth < 800
                    ? 33
                    : screenWidth > 1400
                    ? 700
                    : 405,
            top: screenWidth > 1400 ? 250 : 160,
            child: SvgPicture.asset(
              'assets/footer/footerbg.svg',
              height: screenWidth < 800 ? 157 : 290,
              width: screenWidth < 800 ? 154 : 254,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFF3094a7), BlendMode.srcIn),
            ),
          ),

          Positioned(
            left:
                screenWidth < 800
                    ? 284
                    : screenWidth > 1400
                    ? 1200
                    : 850,
            top: screenWidth > 1400 ? 250 : 260,
            child: SvgPicture.asset(
              'assets/footer/diamond.svg',
              height: screenWidth < 800 ? 28 : 60,
              width: screenWidth < 800 ? 28 : 60,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFF3094a7), BlendMode.srcIn),
            ),
          ),

          Positioned(
            left:
                screenWidth < 800
                    ? 252
                    : screenWidth > 1400
                    ? 1200
                    : 750,
            top: 400, // since both conditions use 400
            child: SvgPicture.asset(
              'assets/footer/footerbg.svg',
              height: screenWidth < 800 ? 107 : 150,
              width: screenWidth < 800 ? 105 : 150,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFF3094a7), BlendMode.srcIn),
            ),
          ),

          Positioned(
            left:
                screenWidth < 800
                    ? 98
                    : screenWidth > 1400
                    ? 850
                    : 505,
            top: MediaQuery.of(context).size.width > 1400 ? 600 : 498,
            child: SvgPicture.asset(
              'assets/footer/diamond.svg',
              height: screenWidth < 800 ? 16 : 30,
              width: screenWidth < 800 ? 16 : 30,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFF3094a7), BlendMode.srcIn),
            ),
          ),
          // Foreground Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 50,
                  top: 118,
                  bottom: 164,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Image.asset(
                      "assets/header/white_logo.png",
                      width: 277,
                      height: 45,
                    ),
                    SizedBox(height: 24 * fontScale),
                    SvgPicture.asset("assets/icons/notFound.svg"),
                    // Title
                    SizedBox(height: 18 * fontScale),
                    CralikaFont(
                      text:
                          isSuccess
                              ? 'Order Created!'
                              : 'Sorry, Payment Not Successful',
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      lineHeight: 36 / 32,
                      letterSpacing: 1.28 * fontScale,
                      color: const Color(0xFFFFFFFF),
                    ),
                    SizedBox(height: 8 * fontScale),
                    // Message
                    SizedBox(
                      width: 555,
                      child: BarlowText(
                        text:
                            isSuccess
                                ? 'Yay! We have received your order and payment. You will receive an email update when your order has been shipped, along with the tracking link.'
                                : 'Something went wrong with your payment. Please try again or contact support.',
                        fontWeight: FontWeight.w400,
                        fontSize: (16 * fontScale).clamp(14, 16),
                        lineHeight: 1.5,
                        color: const Color(0xFFFFFFFF),
                        textAlign: TextAlign.center,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 24 * fontScale),
                    // Order Details (for success)
                    if (isSuccess) ...[
                      Column(
                        children: [
                          BarlowText(
                            text: orderId,
                            fontWeight: FontWeight.w400,
                            fontSize: (20 * fontScale).clamp(14, 16),
                            lineHeight: 1.5,
                            color: const Color(0xFFFFFFFF),
                            textAlign: TextAlign.center,
                            letterSpacing: 0,
                          ),
                          SizedBox(height: 10 * fontScale),
                          BarlowText(
                            text: "Total Amount Paid: Rs. $amount",
                            fontWeight: FontWeight.w400,
                            fontSize: (20 * fontScale).clamp(14, 16),
                            lineHeight: 1.5,
                            color: const Color(0xFFFFFFFF),
                            textAlign: TextAlign.center,
                            letterSpacing: 0,
                          ),
                          SizedBox(height: 37 * fontScale),
                          BarlowText(
                            text: 'Placed On: $formattedDate',
                            fontWeight: FontWeight.w400,
                            fontSize: (14 * fontScale).clamp(14, 16),
                            lineHeight: 1.5,
                            color: const Color(0xFFFFFFFF),
                            textAlign: TextAlign.center,
                            letterSpacing: 0,
                          ),
                          SizedBox(height: 40 * fontScale),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 99.0,
                            ),
                            child: Divider(),
                          ),
                          SizedBox(height: 35 * fontScale),
                          BarlowText(
                            text: "VIEW MY ORDERS",
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            lineHeight: 1.0,
                            letterSpacing: 0.64 * fontScale,
                            backgroundColor: Color(0xFF67a8cf),
                            hoverTextColor: Color(0xFF2876E4),
                            enableHoverBackground: true,
                            hoverBackgroundColor: Colors.white,
                            onTap: () {
                              context.go(AppRoutes.myOrder);
                            },
                          ),
                        ],
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
                            child: BarlowText(
                              text: "RETRY PAYMENT",
                              color: const Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              lineHeight: 1.0,
                              letterSpacing: 0.64 * fontScale,
                              backgroundColor: Color(0xFF67a8cf),
                              hoverTextColor: Color(0xFF2876E4),
                              enableHoverBackground: true,
                              hoverBackgroundColor: Colors.white,
                              onTap: () {
                                context.go(AppRoutes.contactUs);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
