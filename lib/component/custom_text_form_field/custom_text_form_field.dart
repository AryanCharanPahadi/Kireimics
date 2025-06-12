import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final int? maxLength;
  final bool isEmail;
  final bool isMessageField;
  final bool isContinuationField;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextEditingController? nextController; // Add this
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
    this.nextController, // Add this
    this.maxLines,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  String? trailingWord;

  void _onChanged(String value) {
    if (widget.isMessageField && value.length == 25) {
      final lastSpaceIndex = value.lastIndexOf(' ');

      // If there is a space, extract the last word
      if (lastSpaceIndex != -1 && lastSpaceIndex < value.length - 1) {
        final wordToMove = value.substring(lastSpaceIndex + 1);
        final newText = value.substring(0, lastSpaceIndex);

        // Update current field
        widget.controller?.text = newText;
        widget.controller?.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );

        // Move to next field
        if (widget.nextController != null) {
          final nextText = widget.nextController!.text;
          final updatedNextText =
              nextText.isEmpty ? wordToMove : '$nextText ${wordToMove}';
          widget.nextController!.text = updatedNextText;
          widget.nextController!.selection = TextSelection.fromPosition(
            TextPosition(offset: updatedNextText.length),
          );
        }

        // Move focus
        if (widget.nextFocusNode != null) {
          widget.nextFocusNode!.requestFocus();
        }

        trailingWord = wordToMove;
      } else {
        // No space found, just move focus
        widget.nextFocusNode?.requestFocus();
        trailingWord = null;
      }
      setState(() {});
    } else if (widget.isMessageField) {
      final parts = value.split(' ');
      trailingWord = value.endsWith(' ') ? '' : parts.last;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            if (widget.hintText.isNotEmpty)
              Positioned(
                left: 0,
                top: 16,
                child: Text(
                  widget.hintText,
                  style: GoogleFonts.barlow(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              cursorColor: Colors.white,
              textAlign: TextAlign.right,
              maxLength: widget.isMessageField ? 25 : widget.maxLength,
              maxLines: widget.maxLines,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              onChanged: _onChanged,
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
        ),
      ],
    );
  }
}
