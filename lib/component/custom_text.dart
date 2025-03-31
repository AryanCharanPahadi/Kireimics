import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final String fontFamily;
  final FontWeight fontWeight;
  final double fontSize;
  final double lineHeight;
  final double letterSpacing;
  final Color color;
  final TextAlign textAlign;

  const CustomText({
    super.key,
    required this.text,
    this.fontFamily = "Barlow", // Default font family
    this.fontWeight = FontWeight.w600, // Default weight 600
    this.fontSize = 14, // Default size 14px
    this.lineHeight = 1.0, // Default line height 100%
    this.letterSpacing = 0.56, // Default 4% of 14px
    this.color = Colors.white, // Default color white
    this.textAlign = TextAlign.left, // Default alignment
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: GoogleFonts.getFont(fontFamily).fontFamily, // Dynamic font
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: lineHeight / fontSize, // Convert px to Flutter's height ratio
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}
