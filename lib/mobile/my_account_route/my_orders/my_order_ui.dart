import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/view_details/view_details_ui.dart';
import '../../../component/text_fonts/custom_text.dart';

class MyOrderUiMobile extends StatefulWidget {
  const MyOrderUiMobile({super.key});

  @override
  State<MyOrderUiMobile> createState() => _MyOrderUiMobileState();
}

class _MyOrderUiMobileState extends State<MyOrderUiMobile> {
  // Sample JSON data for addresses
  final List<Map<String, dynamic>> orders = [
    {
      "orderNumber": "382083",
      "placedDate": "Sun, 16 Mar 2025",
      "deliveredDate": "Sun, 16 Mar 2025",
      "status": "Delivered",
    },
    {
      "orderNumber": "382084",
      "placedDate": "Mon, 17 Mar 2025",
      "deliveredDate": "Tue, 18 Mar 2025",
      "status": "Delivered",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          // Left Side
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CralikaFont(
                  text: "My Order",
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  lineHeight: 36 / 32,
                  letterSpacing: 1.28,
                  color: Color(0xFF414141),
                ),
                SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BarlowText(
                      text: "My Account",
                      color: Color(0xFF3E5B84),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04, // 4% of 32px
                      route: AppRoutes.myAccount,
                      enableUnderlineForActiveRoute:
                          true, // Enable underline when active
                      decorationColor: Color(
                        0xFF3E5B84,
                      ), // Color of the underline
                      onTap: () {
                        context.go(AppRoutes.myAccount);
                      },
                    ),
                    SizedBox(width: 32),

                    BarlowText(
                      text: "My Orders",
                      color: Color(0xFF3E5B84),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.myOrder,
                      enableUnderlineForActiveRoute:
                          true, // Enable underline when active
                      decorationColor: Color(
                        0xFF3E5B84,
                      ), // Color of the underline
                      onTap: () {
                        context.go(AppRoutes.myOrder);
                      },
                    ),
                    SizedBox(width: 32),

                    BarlowText(
                      text: "Wishlist",
                      color: Color(0xFF3E5B84),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      onTap: () {
                        context.go(AppRoutes.wishlist);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right Side
          SizedBox(height: 44),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic list of address containers
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CralikaFont(
                      text: "${orders.length} Orders",
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      lineHeight: 36 / 32,
                      letterSpacing: 1.28,
                      color: const Color(0xFF414141),
                    ),
                    const SizedBox(height: 24),

                    // Orders list
                    Column(
                      children:
                          orders
                              .map((order) => _buildOrderItem(order))
                              .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDDEAFF).withOpacity(0.6),
              offset: const Offset(20, 20),
              blurRadius: 20,
            ),
          ],
          border: Border.all(color: const Color(0xFFDDEAFF), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            top: 13,
            bottom: 36,
            right: 16,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BarlowText(
                      text:
                          "Placed On: ${order['placedDate']} / Delivered On: ${order['deliveredDate']}",
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 1.4,
                      letterSpacing: 0,
                      color: const Color(0xFF636363),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: BarlowText(
                      text: order['status'],
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 1.4,
                      letterSpacing: 0,
                      color: const Color(0xFF268FA2),
                      // Optional: Add maxLines if you want to restrict height
                      // maxLines: 2,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDEAFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/icons/shopping_bag.svg",
                        height: 27,
                        width: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarlowText(
                        text: "Order# ${order['orderNumber']}",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        lineHeight: 1.0,
                        letterSpacing: 0,
                        color: const Color(0xFF414141),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                       context.go(AppRoutes.viewDetails);
                        },
                        child: BarlowText(
                          text: "VIEW DETAILS",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.5,
                          letterSpacing: 0,
                          color: const Color(0xFF3E5B84),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
  }) {
    return Stack(
      children: [
        // Hint text positioned on the left
        Positioned(
          left: 0,
          top: 16, // Adjust this value to align vertically
          child: Text(
            hintText,
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        // Text field with right-aligned input
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: const Color(0xFF414141),
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            hintText: '',
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.0,
              letterSpacing: 0.0,
              color: const Color(0xFF414141),
            ),
            contentPadding: const EdgeInsets.only(top: 16),
          ),
          style: const TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
