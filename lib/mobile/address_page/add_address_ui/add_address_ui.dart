import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/mobile/login/login.dart';

import '../../../component/custom_text.dart';

class AddAddressUiMobile extends StatefulWidget {
  const AddAddressUiMobile({super.key});

  @override
  State<AddAddressUiMobile> createState() => _AddAddressUiMobileState();
}

class _AddAddressUiMobileState extends State<AddAddressUiMobile> {
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
                  text: "Add New Address",
                  color: const Color(0xFF414141),
                  fontWeight: FontWeight.w600,
                  fontSize: 24.0,
                  lineHeight: 1.0,
                  letterSpacing: 0.128,
                ),

                const SizedBox(height: 44),
                Column(
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
                        Expanded(child: customTextFormField(hintText: "ZIP")),
                        SizedBox(width: 32), // spacing between fields
                        Expanded(child: customTextFormField(hintText: "STATE")),
                      ],
                    ),
                    customTextFormField(hintText: "CITY"),
                    SizedBox(width: 32), // spacing between fields
                    customTextFormField(hintText: "PHONE"),
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
                        SizedBox(width: 11),
                        BarlowText(
                          text: "Save as my default shipping address.",
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 44),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          BarlowText(
                            text: "ADD NEW ADDRESS",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            lineHeight: 1.0,
                            letterSpacing: 0.64,
                            color: const Color(0xFF3E5B84),
                            backgroundColor: const Color(0xFFb9d6ff),
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
