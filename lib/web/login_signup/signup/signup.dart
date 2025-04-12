import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/routes.dart';
import 'package:kireimics/web/login_signup/login/login_page.dart';

import '../../../component/custom_text.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.transparent)),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 504,
            child: Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: BarlowText(
                          text: "Close",
                          color: Color(0xFF3E5B84),
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          lineHeight: 1.0,
                          letterSpacing: 0.64,
                        ),
                      ),
                      SizedBox(height: 33),
                      CralikaFont(
                        text: "Sign Up",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                        fontSize: 32.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      SizedBox(height: 8),
                      BarlowText(
                        text:
                            "Create a free Kireimics account for a quick checkout.",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        lineHeight: 1.0,
                        letterSpacing: 0.0,
                      ),
                      SizedBox(height: 32),
                      customTextFormField(hintText: "FIRST NAME"),

                      customTextFormField(hintText: "LAST NAME"),
                      customTextFormField(hintText: "EMAIL"),
                      customTextFormField(hintText: "PHONE"),
                      customTextFormField(hintText: "CREATE PASSWORD"),

                      SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              BarlowText(
                                text: "SIGN UP",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                lineHeight: 1.0, // 100% line height
                                letterSpacing: 0.64, // 4% of 16px = 0.64
                                color: Color(0xFF3E5B84),
                                backgroundColor: Color(0xFFb9d6ff),
                              ),
                              SizedBox(height: 30),

                              Container(
                                width: 320,
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        'By signing up, you are agreeing to our ',
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.barlow().fontFamily,
                                      fontWeight:
                                          FontWeight
                                              .w600, // Matches font-weight: 600;
                                      fontSize: 14, // Matches font-size: 14px;
                                      height: 1.0, // Matches line-height: 100%;
                                      letterSpacing:
                                          0.0, // Matches letter-spacing: 0%;
                                      color: Color(0xFF414141),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: Color(0xFF3E5B84),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                context.go(
                                                  AppRoutes.privacyPolicy,
                                                );
                                              },
                                      ),
                                      TextSpan(text: ' & '),
                                      TextSpan(
                                        text: 'Shipping Policy',
                                        style: TextStyle(
                                          color: Color(0xFF3E5B84),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                context.go(
                                                  AppRoutes.shippingPolicy,
                                                );
                                              },
                                      ),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 30),

                              BarlowText(
                                text: "Or continue with",
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                lineHeight: 1.0, // 100% line height
                                letterSpacing: 0.0, // 0%
                                color: Color(0xFF414141),
                              ),
                              SizedBox(height: 16),

                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/fb_icon.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                  SizedBox(width: 24),

                                  SvgPicture.asset(
                                    "assets/icons/google_icon.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                  SizedBox(width: 24),

                                  SvgPicture.asset(
                                    "assets/icons/apple_icon.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

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
                        width: 428,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Navigator.pop(
                                        context,
                                      ); // Closes the LoginPage
                                      Future.delayed(Duration.zero, () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return LoginPage(); // Opens the Signup dialog
                                          },
                                        );
                                      });
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
                            ],
                          ),
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
