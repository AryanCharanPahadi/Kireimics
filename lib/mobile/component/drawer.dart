import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kireimics/mobile/component/scrolling_header.dart';

import '../../component/custom_text.dart';

class DrawerMobile extends StatefulWidget {
  const DrawerMobile({super.key});

  @override
  State<DrawerMobile> createState() => _DrawerMobileState();
}

class _DrawerMobileState extends State<DrawerMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF46856),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(children: [ScrollingHeaderMobile(color: Color(0xFFF46856))]),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, size: 30, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "MENU",
                        textAlign: TextAlign.right, // Align text to the right
                        style: TextStyle(
                          fontFamily: "Cralika", // Cralika font
                          fontWeight: FontWeight.w400, // Equivalent to 400
                          fontSize: 32, // 32px
                          height: 1.0, // Line height 32px (32/32)
                          letterSpacing: 1.28, // 4% of 32px = 1.28
                          color:
                              Colors.white, // Default color (change if needed)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
              child: SizedBox(
                // color: Colors.yellow,
                height: 164,
                width: MediaQuery.of(context).size.width,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: "HOME",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    CustomText(
                      text: "CATALOG",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    CustomText(
                      text: "SALE",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                    CustomText(
                      text: "ABOUT",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 24),
              child: Divider(color: Colors.black),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
              child: SizedBox(
                height: 164,
                width: MediaQuery.of(context).size.width,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: "MY ACCOUNT",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    CustomText(
                      text: "MY ORDERS",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    CustomText(
                      text: "WISHLIST",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 24),
              child: Divider(color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
              child: SizedBox(
                height: 164,
                width: MediaQuery.of(context).size.width,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: "Shipping Policy",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    CustomText(
                      text: "Privacy Policy",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    CustomText(
                      text: "Contact",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    CustomText(
                      text: "Log In / Sign Up",
                      fontFamily: "Barlow",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 14, // 100%
                      letterSpacing: 0.56, // 4% of 14px
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 24),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      'assets/white_insta.svg', // Ensure the correct path
                      width: 18,
                      height: 18,
                    ),
                    SizedBox(width: 15),
                    SvgPicture.asset(
                      'assets/white_email.svg', // Ensure the correct path
                      width: 14,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
