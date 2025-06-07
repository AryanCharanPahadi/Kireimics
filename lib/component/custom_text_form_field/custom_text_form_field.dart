import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final int? maxLength;
  final bool isEmail;
  final bool isMessageField;
  final bool isContinuationField;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    Key? key,
    required this.hintText,
    this.controller,
    this.maxLength,
    this.isEmail = false,
    this.isMessageField = false,
    this.isContinuationField = false,
    this.validator,
    this.focusNode,
    this.nextFocusNode,
    this.maxLines,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (hintText.isNotEmpty)
          Positioned(
            left: 0,
            top: 16,
            child: Text(
              hintText,
              style: GoogleFonts.barlow(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          cursorColor: Colors.white,
          textAlign: TextAlign.right,
          maxLength: isMessageField ? 25 : maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: (value) {
            if (isMessageField && value.length == 25 && nextFocusNode != null) {
              nextFocusNode!.requestFocus();
            }
          },
          decoration: InputDecoration(
            counterText: '',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontFamily: GoogleFonts.barlow().fontFamily,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.barlow().fontFamily,
          ),
        ),
      ],
    );
  }
}
