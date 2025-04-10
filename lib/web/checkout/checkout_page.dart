import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/routes.dart';
import 'package:kireimics/web/login_signup/login/login_page.dart';

import '../../component/custom_text.dart';

class CheckoutPageWeb extends StatefulWidget {
  const CheckoutPageWeb({super.key});

  @override
  State<CheckoutPageWeb> createState() => _CheckoutPageWebState();
}

class _CheckoutPageWebState extends State<CheckoutPageWeb> {
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 292, right: 44, top: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BarlowText(
                      text: "My Cart",
                      color: Color(0xFF3E5B84),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04, // 4% of 32px
                    ),
                    SizedBox(width: 9.0),

                    SvgPicture.asset(
                      'assets/icons/right_icon.svg',
                      width: 24,
                      height: 24,
                      color: Color(0xFF3E5B84),
                    ),
                    SizedBox(width: 9.0),

                    BarlowText(
                      text: "View Details",
                      color: Color(0xFF3E5B84),
                      fontSize: 16,
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
                SizedBox(height: 32),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CralikaFont(
                              text: "Checkout",
                              fontWeight: FontWeight.w400,
                              fontSize: 32,
                              lineHeight: 36 / 32,
                              letterSpacing: 1.28,
                              color: Color(0xFF414141),
                            ),
                            SizedBox(height: 24),

                            // ▼ ▼ ▼ Conditional Login Box ▼ ▼ ▼
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 56,
                                        width: 56,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFDDEAFF),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/header/IconProfile.svg",
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
                                            text: "Already have an account?",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20,
                                            lineHeight: 1.0,
                                            color: Color(0xFF000000),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                barrierColor:
                                                    Colors.transparent,
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  return LoginPage();
                                                },
                                              );
                                            },
                                            child: BarlowText(
                                              text: "LOG IN NOW",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
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
                                            showLoginBox =
                                                false; // Hide the box
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
                              SizedBox(height: 43),
                            ],

                            SizedBox(
                              width: 444,
                              // color: Colors.red,
                              child: Column(
                                children: [
                                  customTextFormField(hintText: "FIRST NAME"),
                                  customTextFormField(hintText: "LAST NAME"),
                                  customTextFormField(hintText: "EMAIL"),
                                  customTextFormField(
                                    hintText: "ADDRESS LINE 1*",
                                  ),
                                  customTextFormField(
                                    hintText: "ADDRESS LINE 2",
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: customTextFormField(
                                          hintText: "ZIP",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 32,
                                      ), // spacing between fields
                                      Expanded(
                                        child: customTextFormField(
                                          hintText: "STATE",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: customTextFormField(
                                          hintText: "CITY",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 32,
                                      ), // spacing between fields
                                      Expanded(
                                        child: customTextFormField(
                                          hintText: "PHONE",
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      SizedBox(width: 19),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12.0,
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontFamily: 'Barlow',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                height:
                                                    1.5, // Line height: 150%
                                                letterSpacing: 0.0,
                                                color: Color(0xFF414141),
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "By selecting this checkbox, you are agreeing to our ",
                                                ),
                                                TextSpan(
                                                  text: "Privacy Policy",
                                                  style: TextStyle(
                                                    color: Color(0xFF3E5B84),
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          context.go(
                                                            AppRoutes
                                                                .privacyPolicy,
                                                          );
                                                        },
                                                ),
                                                TextSpan(text: " & "),
                                                TextSpan(
                                                  text: "Shipping Policy",
                                                  style: TextStyle(
                                                    color: Color(0xFF3E5B84),
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          context.go(
                                                            AppRoutes
                                                                .shippingPolicy,
                                                          );
                                                        },
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
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              color: Color(0xFF3E5B84),
                              width: 488,

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BarlowText(
                                          text: "Item Total",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
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
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BarlowText(
                                          text: "Shipping & Taxes",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
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
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    Divider(color: Color(0xFFFFFFFF)),
                                    SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CralikaFont(
                                          text: "Subtotal",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                        BarlowText(
                                          text:
                                              "Rs. ${total.toStringAsFixed(2)}",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 32),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                BarlowText(
                                  text: "VIEW CART",

                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  lineHeight: 1.0, // 100% line height
                                  letterSpacing:
                                      0.64, // 4% of 16px = 0.04 * 16 = 0.64
                                ),
                                SizedBox(height: 24),

                                BarlowText(
                                  text: "MAKE PAYMENT",
                                  color: Color(0xFF3E5B84),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  lineHeight: 1.0, // 100% line height
                                  letterSpacing:
                                      0.64, // 4% of 16px = 0.04 * 16 = 0.64
                                  backgroundColor: Color(0xFFb9d6ff),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    TextAlign textAlign = TextAlign.right,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: textAlign,
      cursorColor: const Color(0xFF414141),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.barlow(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.0,
          letterSpacing: 0.0,
          color: const Color(0xFF414141),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF414141)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF414141)),
        ),
      ),
      style: const TextStyle(color: Color(0xFF414141)),
    );
  }
}
