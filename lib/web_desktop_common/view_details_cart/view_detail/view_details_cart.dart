import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/utilities/utility.dart';
import '../../../web_desktop_common/login_signup/login/login_page.dart';

class ViewDetailsCart extends StatefulWidget {
  const ViewDetailsCart({super.key});

  @override
  State<ViewDetailsCart> createState() => _ViewDetailsCartState();
}

class _ViewDetailsCartState extends State<ViewDetailsCart> {
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
            width: isLargeScreen ? 550 : 504,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          hoverBackgroundColor: Color(0xFFb9d6ff),

                          enableHoverBackground: true,
                        ),
                      ),
                      SizedBox(height: 33),
                      CralikaFont(
                        text: "View Details",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w400,
                        fontSize: 32.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BarlowText(
                            text: "Order# 382083",
                            color: Color(0xFF414141),
                            fontWeight: FontWeight.w400, // 400 = normal
                            fontSize: 20,
                            lineHeight:
                                1.0, // line-height: 100% → height = 1.0 in Flutter
                            letterSpacing: 0.0,
                          ),

                          BarlowText(
                            text: "TRACK ORDER",
                            color: Color(0xFF414141),
                            fontWeight: FontWeight.w600, // 600 = semi-bold
                            fontSize: 16,
                            lineHeight: 1.0, // 100% line height
                            letterSpacing:
                                0.64, // 4% of 16px = 0.04 * 16 = 0.64
                            backgroundColor: Color(0xFFb9d6ff),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      BarlowText(
                        text:
                            "Placed On: Sun, 16 Mar 2025  /  Expected Delivery: Sun, 16 Mar 2025",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w400, // 400 = normal
                        fontSize: 14,
                        lineHeight: 1.4, // 140% line height → height = 1.4
                        letterSpacing: 0.0,
                      ),

                      SizedBox(height: 12),
                      BarlowText(
                        text: "On The Way",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600, // 600 = semi-bold
                        fontSize: 14,
                        lineHeight: 1.4, // 140% line height
                        letterSpacing: 0.0,
                      ),

                      SizedBox(height: 28),
                      // Replace ListView.builder with a Column wrapped in a SizedBox
                      SizedBox(
                        height:
                            300, // Set an appropriate height or use a flexible solution
                        child: ListView.builder(
                          physics:
                              NeverScrollableScrollPhysics(), // Disable scrolling
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/home_page/gridview_img.jpeg",
                                        height: 123,
                                        width: 107,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: BarlowText(
                                                    text: "Set of 2 Plate",
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    lineHeight: 1.0,
                                                    letterSpacing: 0.0,
                                                    color: Color(0xFF414141),
                                                    softWrap: true,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                BarlowText(
                                                  text: "Rs 122",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  lineHeight: 1.0,
                                                  letterSpacing: 0.0,
                                                  color: Color(0xFF414141),
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 30),
                                            BarlowText(
                                              text: "x 1",
                                              color: Color(0xFF414141),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                            ),
                                            SizedBox(height: 35),
                                            BarlowText(
                                              text: "VIEW DETAILS",
                                              color: Color(0xFF30578E),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Color(0xFF30578E)),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ),
                      // Subtotal Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CralikaFont(
                                  text: "Total Paid",
                                  color: Color(0xFF414141),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  lineHeight: 1.8, // 36px / 20px = 1.8
                                  letterSpacing:
                                      0.8, // 4% of 20px = 0.04 * 20 = 0.8
                                ),

                                BarlowText(
                                  text: "Rs. 900.00",
                                  color: Color(0xFF414141),
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  fontSize: 24,
                                  lineHeight: 1.0, // 100% line height
                                  letterSpacing: 0.0,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            SizedBox(height: 11),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BarlowText(
                                  text: "Item Total",
                                  color: Color(0xFF414141),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  lineHeight: 1.8, // 36px / 20px = 1.8
                                  letterSpacing:
                                      0.8, // 4% of 20px = 0.04 * 20 = 0.8
                                ),
                                BarlowText(
                                  text: "Rs Rs. 850",
                                  color: Color(0xFF414141),
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  fontSize: 16,
                                  lineHeight: 1.0, // 100% line height
                                  letterSpacing: 0.0,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            SizedBox(height: 11),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BarlowText(
                                  text: "Shipping & Taxes",
                                  color: Color(0xFF414141),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  lineHeight: 1.8, // 36px / 20px = 1.8
                                  letterSpacing:
                                      0.8, // 4% of 20px = 0.04 * 20 = 0.8
                                ),
                                BarlowText(
                                  text: "Rs Rs. 850",
                                  color: Color(0xFF414141),
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  fontSize: 16,
                                  lineHeight: 1.0, // 100% line height
                                  letterSpacing: 0.0,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            SizedBox(height: 11),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BarlowText(
                                  text: "Payment Method",
                                  color: Color(0xFF414141),
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  fontSize: 16,
                                  lineHeight: 1.0, // 100% line height
                                  letterSpacing: 0.0,
                                  textAlign: TextAlign.right,
                                ),
                                BarlowText(
                                  text: "Credit Card",
                                  color: Color(0xFF414141),
                                  fontWeight: FontWeight.w400, // 400 = normal
                                  fontSize: 16,
                                  lineHeight: 1.0, // 100% line height
                                  letterSpacing: 0.0,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            SizedBox(height: 27),
                            Container(
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
                              height: 83,
                              width: 444,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  top: 13,
                                  bottom: 13,
                                  right: 10,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 56,
                                      width: 56,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFDDEAFF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          "assets/icons/question.svg",
                                          height: 27,
                                          width: 25,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 24),

                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BarlowText(
                                          text: "Need help with this order?",
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                          lineHeight: 1.0,
                                          color: Color(0xFF000000),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierColor: Colors.transparent,
                                              builder: (BuildContext context) {
                                                return LoginPage();
                                              },
                                            );
                                          },
                                          child: BarlowText(
                                            text: "CONTACT US",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            lineHeight: 1.5,
                                            color: Color(0xFF30578E),
                                            hoverBackgroundColor: Color(
                                              0xFFb9d6ff,
                                            ),
                                            enableHoverBackground: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
