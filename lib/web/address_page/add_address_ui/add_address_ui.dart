import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/routes.dart';
import 'package:kireimics/web/login_signup/login/login_page.dart';

import '../../../component/custom_text.dart';

class AddAddressUiWeb extends StatefulWidget {
  const AddAddressUiWeb({super.key});

  @override
  State<AddAddressUiWeb> createState() => _AddAddressUiWebState();
}

class _AddAddressUiWebState extends State<AddAddressUiWeb> {
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
                        text: "Add New Address",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                        fontSize: 32.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),

                      SizedBox(height: 32),
                      Column(
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
                              SizedBox(width: 19),
                             BarlowText(text: "Save as my default shipping address.")
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              BarlowText(
                                text: "SAVE NEW ADDRESS",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                lineHeight: 1.0, // 100% line height
                                letterSpacing: 0.64, // 4% of 16px = 0.64
                                color: Color(0xFF3E5B84),
                                backgroundColor: Color(0xFFb9d6ff),
                              ),
                            ],
                          ),
                        ],
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
