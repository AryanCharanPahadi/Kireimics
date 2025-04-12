import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/routes.dart';
import 'package:kireimics/web/address_page/add_address_ui/add_address_ui.dart';
import 'package:kireimics/web/login_signup/login/login_page.dart';

import '../../../component/custom_text.dart';

class MyAccountUiWeb extends StatefulWidget {
  const MyAccountUiWeb({super.key});

  @override
  State<MyAccountUiWeb> createState() => _MyAccountUiWebState();
}

class _MyAccountUiWebState extends State<MyAccountUiWeb> {
  // Sample JSON data for addresses
  final List<Map<String, dynamic>> addresses = [
    {
      "city": "Gurgaon",
      "name": "John Doe",
      "address": "123 Main Street, Jayanagar, Bangalore, Karnataka",
      "postalCode": "56004",
      "country": "India",
    },
    {
      "city": "Delhi",
      "name": "Jane Smith",
      "address": "456 Central Avenue, Connaught Place",
      "postalCode": "110001",
      "country": "India",
    },
    {
      "city": "Mumbai",
      "name": "Robert Johnson",
      "address": "789 Beach Road, Marine Drive",
      "postalCode": "400002",
      "country": "India",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side
          Padding(
            padding: const EdgeInsets.only(left: 292, top: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CralikaFont(
                  text: "My Account",
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  lineHeight: 36 / 32,
                  letterSpacing: 1.28,
                  color: Color(0xFF414141),
                ),
                SizedBox(height: 13),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BarlowText(
                      text: "My Account",
                      color: Color(0xFF3E5B84),
                      fontSize: 16,
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
                      fontSize: 16,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      onTap: () {
                        context.go(AppRoutes.wishlist);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: 357,
                  child: Row(
                    children: [
                      CralikaFont(
                        text: "My Details",
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        lineHeight: 27 / 20, // dynamic line-height
                        letterSpacing: 0.04 * 20, // 4% letter-spacing
                        color: Color(0xFF414141),
                      ),
                      SizedBox(width: 150),
                      BarlowText(
                        text: "EDIT DETAILS",
                        fontWeight: FontWeight.w600, // corresponds to 600
                        fontSize: 16, // 16px
                        lineHeight: 1.0, // 100%
                        letterSpacing: 0.04 * 16, // 4% of font size
                        color: Color(0xFF414141),
                        backgroundColor: Color(0xFFb9d6ff),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                SizedBox(
                  width: 344,
                  child: Column(
                    children: [
                      customTextFormField(hintText: "FIRST NAME"),
                      customTextFormField(hintText: "LAST NAME"),
                      customTextFormField(hintText: "EMAIL"),
                      customTextFormField(hintText: "MOBILE"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right Side
          Padding(
            padding: const EdgeInsets.only(right: 140, top: 124),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CralikaFont(
                      text: "My Addresses",
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      lineHeight: 27 / 20, // dynamic line-height
                      letterSpacing: 0.04 * 20, // 4% letter-spacing
                      color: Color(0xFF414141),
                    ),
                    SizedBox(width: 180),
                    GestureDetector(
                      onTap: () {
                        print("Cart icon tapped");
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return AddAddressUiWeb();
                          },
                        );
                      },
                      child: BarlowText(
                        text: "ADD NEW ADDRESS",
                        fontWeight: FontWeight.w600, // corresponds to 600
                        fontSize: 16, // 16px
                        lineHeight: 1.0, // 100%
                        letterSpacing: 0.04 * 16, // 4% of font size
                        color: Color(0xFF414141),
                        backgroundColor: Color(0xFFb9d6ff),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),
                // Dynamic list of address containers
                Column(
                  children:
                      addresses.map((address) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
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
                            width: 468,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                top: 13,
                                bottom: 13,
                                right: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                        "assets/icons/location.svg",
                                        height: 27,
                                        width: 25,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BarlowText(
                                          text: address["city"],
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                          lineHeight: 1.0,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF414141),
                                        ),
                                        SizedBox(height: 3),
                                        BarlowText(
                                          text: address["name"],
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          lineHeight: 1.4,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF636363),
                                        ),
                                        SizedBox(height: 3),
                                        BarlowText(
                                          text: address["address"],
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          lineHeight: 1.4,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF636363),
                                        ),
                                        SizedBox(height: 3),
                                        BarlowText(
                                          text:
                                              "${address["postalCode"]} - ${address["country"]}",
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          lineHeight: 1.4,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF636363),
                                        ),
                                        SizedBox(height: 3),
                                        Row(
                                          children: [
                                            BarlowText(
                                              text: "EDIT",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              lineHeight: 1.5,
                                              letterSpacing: 0.0,
                                              color: Color(0xFF3E5B84),
                                            ),
                                            BarlowText(
                                              text: " / ",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              lineHeight: 1.5,
                                              letterSpacing: 0.0,
                                              color: Color(0xFF3E5B84),
                                            ),
                                            BarlowText(
                                              text: "DELETE",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              lineHeight: 1.5,
                                              letterSpacing: 0.0,
                                              color: Color(0xFF3E5B84),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
              fontSize: 14,
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
