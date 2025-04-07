import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final TextDecoration? decoration;
  final bool softWrap; // Added softWrap field

  const CustomText({
    super.key,
    required this.text,
    this.fontFamily = "Barlow",
    this.fontWeight = FontWeight.w600,
    this.fontSize = 14,
    this.lineHeight = 1.0,
    this.letterSpacing = 0.56,
    this.color = Colors.white,
    this.textAlign = TextAlign.left,
    this.decoration,
    this.softWrap = true, // Default value set to true
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      softWrap: softWrap, // Applied softWrap
      style: TextStyle(
        fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: lineHeight / fontSize,
        letterSpacing: letterSpacing,
        color: color,
        decoration: decoration,
      ),
    );
  }
}

class CralikaFont extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double lineHeight;
  final Color color;
  final TextAlign textAlign;
  final TextDecoration? decoration;
  final bool softWrap; // Added softWrap field

  const CralikaFont({
    Key? key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 0.96,
    this.lineHeight = 36 / 24,
    this.color = const Color(0xFF414141),
    this.textAlign = TextAlign.start,
    this.decoration,
    this.softWrap = true, // Default value set to true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      softWrap: softWrap, // Applied softWrap
      style: TextStyle(
        fontFamily: "Cralika",
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
        decoration: decoration,
      ),
    );
  }
}
class BarlowText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double lineHeight;
  final double letterSpacing;
  final Color color;
  final Color? backgroundColor; // Independent background color for text only
  final TextAlign textAlign;
  final bool softWrap;
  final VoidCallback? onTap;

  // Decoration properties
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final Color? decorationColor;

  // Route-based styling properties
  final String? route;
  final bool enableUnderlineForActiveRoute;
  final bool enableBackgroundForActiveRoute;
  final Color? activeBackgroundColor;
  final TextDecoration? activeUnderlineDecoration;

  static final String fontFamily = GoogleFonts.barlow().fontFamily ?? 'Barlow';

  const BarlowText({
    super.key,
    required this.text,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w500,
    this.lineHeight = 1.3,
    this.letterSpacing = 0.0,
    this.color = const Color(0xFF414141),
    this.backgroundColor, // Background applied only to text
    this.textAlign = TextAlign.start,
    this.softWrap = true,
    this.onTap,
    this.decoration,
    this.decorationStyle,
    this.decorationThickness,
    this.decorationColor,
    this.route,
    this.enableUnderlineForActiveRoute = false,
    this.enableBackgroundForActiveRoute = false,
    this.activeBackgroundColor,
    this.activeUnderlineDecoration,
  });

  bool _isCurrentRoute(BuildContext context) {
    if (route == null) return false;
    final currentLocation = GoRouterState.of(context).uri.path;
    return currentLocation == route;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isCurrentRoute(context);

    return GestureDetector(
      onTap: onTap ?? (route != null ? () => context.go(route!) : null),
      child: Text(
        text,
        textAlign: textAlign,
        softWrap: softWrap,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: lineHeight,
          letterSpacing: letterSpacing,
          color: color,
          backgroundColor: isActive && enableBackgroundForActiveRoute
              ? (activeBackgroundColor ?? backgroundColor)
              : backgroundColor, // Background applied only to text
          decoration: isActive && enableUnderlineForActiveRoute
              ? (activeUnderlineDecoration ?? TextDecoration.underline)
              : decoration,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
          decorationColor: decorationColor,
        ),
      ),
    );
  }
}
