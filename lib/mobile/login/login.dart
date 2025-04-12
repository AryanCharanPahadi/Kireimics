import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/routes.dart';
import 'package:kireimics/mobile/sign_in/sign_in.dart';

import '../../component/custom_text.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  bool showLoginBox = true; // initially show the login container
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    "assets/icons/closeIcon.svg",
                    height: 22,
                    width: 32,
                  ),
                ),
                const SizedBox(height: 20),
                CralikaFont(
                  text: "Log In",
                  color: const Color(0xFF414141),
                  fontWeight: FontWeight.w600,
                  fontSize: 24.0,
                  lineHeight: 1.0,
                  letterSpacing: 0.128,
                ),
                const SizedBox(height: 12),
                BarlowText(
                  text:
                      "Log in to your Kireimics account for a quick checkout.",
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.0,
                ),
                const SizedBox(height: 44),
                customTextFormField(hintText: "Enter your email"),
                const SizedBox(height: 20),
                customTextFormField(hintText: "Enter your password"),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                            BarlowText(
                              text: "Remember Me",
                              color: const Color(0xFF414141),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              lineHeight: 1.0,
                              letterSpacing: 0.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        BarlowText(
                          text: "Forgot Password?",
                          color: const Color(0xFF3E5B84),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.64,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        BarlowText(
                          text: "LOG IN",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          lineHeight: 1.0,
                          letterSpacing: 0.64,
                          color: const Color(0xFF3E5B84),
                          backgroundColor: const Color(0xFFb9d6ff),
                        ),
                        const SizedBox(height: 30),
                        BarlowText(
                          text: "Or continue with",
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          lineHeight: 1.0,
                          letterSpacing: 0.0,
                          color: const Color(0xFF414141),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/fb_icon.svg",
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 24),
                            SvgPicture.asset(
                              "assets/icons/google_icon.svg",
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 24),
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
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDDEAFF).withOpacity(0.6),
                        offset: const Offset(20, 20),
                        blurRadius: 20,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFDDEAFF),
                      width: 1,
                    ),
                  ),
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
                            color: const Color(0xFFDDEAFF),
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
                        const SizedBox(width: 24),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BarlowText(
                              text: "Don't have an account?",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              lineHeight: 1.0,
                              color: const Color(0xFF000000),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInMobile(),
                                  ),
                                );
                              },
                              child: BarlowText(
                                text: "SIGN UP NOW",
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                lineHeight: 1.5,
                                color: const Color(0xFF3E5B84),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Added extra space at the bottom
              ],
            ),
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
