import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../component/custom_text.dart';
import '../../../component/product_details/product_details_modal.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap:
                          () =>
                              Navigator.of(
                                context,
                              ).pop(), // OR context.pop() if using GoRouter
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
                      text: "Log In",
                      color: Color(0xFF414141),
                      fontWeight: FontWeight.w600,
                      fontSize: 32.0,
                      lineHeight: 1.0,
                      letterSpacing: 0.128,
                    ),
                    SizedBox(height: 8,),
                    
                    BarlowText(text: "Log in to your Kireimics account for a quick checkout."



                    ,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      lineHeight: 1.0, // Line height: 100%
                      letterSpacing: 0.0, // Letter spacing: 0%

                    )
                    
                  ],
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
