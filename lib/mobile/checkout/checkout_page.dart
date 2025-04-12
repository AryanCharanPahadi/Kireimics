import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/routes.dart';
import 'package:kireimics/mobile/login/login.dart';

import '../../component/custom_text.dart';

class CheckoutPageMobile extends StatefulWidget {
  const CheckoutPageMobile({super.key});

  @override
  State<CheckoutPageMobile> createState() => _CheckoutPageMobileState();
}

class _CheckoutPageMobileState extends State<CheckoutPageMobile> {
  bool showLoginBox = true; // initially show the login container
  bool isChecked = false;
  late double subtotal;
  final double deliveryCharge = 50.0; // Static delivery charge
  late double total;

  @override
  void initState() {
    super.initState();
    // Get subtotal from URL parameters
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());

    subtotal = double.tryParse(uri.queryParameters['subtotal'] ?? '') ?? 0.0;
    total = subtotal + deliveryCharge; // Calculate total with static delivery
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BarlowText(
                          text: "My Cart",
                          color: Color(0xFF3E5B84),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          letterSpacing: 1 * 0.04, // 4% of 32px
                        ),

                        SizedBox(width: 9.0),

                        SvgPicture.asset(
                          'assets/icons/right_icon.svg',
                          width: 20,
                          height: 20,
                          color: Color(0xFF3E5B84),
                        ),
                        SizedBox(width: 9.0),

                        BarlowText(
                          text: "View Details",
                          color: Color(0xFF3E5B84),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          route: AppRoutes.checkOut,
                          enableUnderlineForActiveRoute:
                              true, // Enable underline when active
                          decorationColor: Color(
                            0xFF3E5B84,
                          ), // Color of the underline
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        CralikaFont(
                          text: "Checkout",
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          lineHeight: 36 / 32,
                          letterSpacing: 1.28,
                          color: Color(0xFF414141),
                        ),

                        SizedBox(height: 10),

                        if (showLoginBox) ...[
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
                            // height: 83,
                            // width: 362,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                top: 13,
                                bottom: 13,
                                right: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDDEAFF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/header/IconProfile.svg",
                                        height: 21,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 24),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BarlowText(
                                        text: "Already have an account?",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        lineHeight: 1.0,
                                        color: Color(0xFF000000),
                                      ),
                                      SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => LoginMobile(),
                                            ),
                                          );
                                        },
                                        child: BarlowText(
                                          text: "LOG IN NOW",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          lineHeight: 1.5,
                                          color: Color(0xFF3E5B84),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        showLoginBox = false; // Hide the box
                                      });
                                    },
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Color(0xFFE5E5E5),
                                      child: SvgPicture.asset(
                                        "assets/icons/closeIcon.svg",
                                        color: Color(0xFF4F4F4F),
                                        height: 10,
                                        width: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 44),
                        ],
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Container(
                      // width: 346,
                      // color: Colo
                      // rs.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customTextFormField(hintText: "FIRST NAME"),
                          customTextFormField(hintText: "LAST NAME"),
                          customTextFormField(hintText: "EMAIL"),
                          customTextFormField(hintText: "ADDRESS LINE 1*"),
                          customTextFormField(hintText: "ADDRESS LINE 2"),
                          Row(
                            children: [
                              Expanded(
                                child: customTextFormField(hintText: "ZIP"),
                              ),
                              SizedBox(width: 32), // spacing between fields
                              Expanded(
                                child: customTextFormField(hintText: "STATE"),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: customTextFormField(hintText: "CITY"),
                              ),
                              SizedBox(width: 32), // spacing between fields
                              Expanded(
                                child: customTextFormField(hintText: "PHONE"),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value ?? false;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.5, // Line height: 150%
                                        letterSpacing: 0.0,
                                        color: Color(0xFF414141),
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              "By selecting this checkbox, you are agreeing to our ",
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: TextStyle(
                                            color: Color(0xFF3E5B84),
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                          ),
                                        ),
                                        TextSpan(text: " & "),
                                        TextSpan(
                                          text: "Shipping Policy",
                                          style: TextStyle(
                                            color: Color(0xFF3E5B84),
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                          ),
                                        ),
                                        TextSpan(text: "."),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 42),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: Color(0xFF3E5B84),
                          // width: 346,

                          // height: 243,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 46,
                              top: 18,
                              right: 44,
                              bottom: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CralikaFont(
                                  text: "Order Details",
                                  color: Color(0xFFFFFFFF),

                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  lineHeight:
                                      36 / 20, // line-height / font-size
                                  letterSpacing: 0.8, // 4% of 20px is 0.8
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BarlowText(
                                      text: "Item Total",
                                      color: Color(0xFFFFFFFF),

                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight:
                                          36 /
                                          16, // line-height / font-size = 2.25
                                      letterSpacing: 0.64, // 4% of 16 = 0.64
                                    ),
                                    BarlowText(
                                      text:
                                          "Rs. ${subtotal.toStringAsFixed(2)}",
                                      color: Color(0xFFFFFFFF),

                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight:
                                          36 /
                                          16, // line-height / font-size = 2.25
                                      letterSpacing: 0.64, // 4% of 16 = 0.64
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BarlowText(
                                      text: "Shipping & Taxes",
                                      color: Color(0xFFFFFFFF),

                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight:
                                          36 /
                                          16, // line-height / font-size = 2.25
                                      letterSpacing: 0.64, // 4% of 16 = 0.64
                                    ),
                                    BarlowText(
                                      text:
                                          "Rs. ${deliveryCharge.toStringAsFixed(2)}",
                                      color: Color(0xFFFFFFFF),

                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight:
                                          36 /
                                          16, // line-height / font-size = 2.25
                                      letterSpacing: 0.64, // 4% of 16 = 0.64
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                Divider(color: Color(0xFFFFFFFF)),
                                SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CralikaFont(
                                      text: "Subtotal",
                                      color: Color(0xFFFFFFFF),

                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight:
                                          36 /
                                          16, // line-height / font-size = 2.25
                                      letterSpacing: 0.64, // 4% of 16 = 0.64
                                    ),
                                    BarlowText(
                                      text: "Rs. ${total.toStringAsFixed(2)}",
                                      color: Color(0xFFFFFFFF),

                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight:
                                          36 /
                                          16, // line-height / font-size = 2.25
                                      letterSpacing: 0.64, // 4% of 16 = 0.64
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 32),

                        Column(
                          children: [
                            BarlowText(
                              text: "VIEW CART",

                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              lineHeight: 1.0, // 100% line height
                              letterSpacing:
                                  0.64, // 4% of 16px = 0.04 * 16 = 0.64
                              backgroundColor: Color(0xFFb9d6ff),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 420,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            color: Colors.white,

            child: Padding(
              padding: const EdgeInsets.only(left: 22.0, top: 21, bottom: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarlowText(
                    text: "Rs. ${total.toStringAsFixed(2)}",
                    color: Color(0xFF3E5B84),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                    letterSpacing: 1 * 0.04, // 4% of 32px
                  ),
                  SizedBox(height: 8),
                  BarlowText(
                    text: "MAKE PAYMENT",
                    color: Color(0xFF3E5B84),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    backgroundColor: Color(0xFFB9D6FF),
                    lineHeight: 1.0,
                    letterSpacing: 1 * 0.04, // 4% of 32px
                  ),
                ],
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
              // Add this for the bottom border
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            enabledBorder: UnderlineInputBorder(
              // Add this for enabled state
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            focusedBorder: UnderlineInputBorder(
              // Add this for focused state
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            hintText: '', // Empty hint since we're showing our own
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: const Color(0xFF414141),
            ),
            contentPadding: const EdgeInsets.only(
              top: 16,
            ), // Match the Positioned top value
          ),
          style: const TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
