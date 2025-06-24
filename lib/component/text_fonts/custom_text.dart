import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextDrawer extends StatelessWidget {
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

  const CustomTextDrawer({
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
  final bool softWrap;
  final int? maxLines; // Optional maxLines parameter

  const CralikaFont({
    Key? key,
    required this.text,
    this.fontSize = 25,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 0.96,
    this.lineHeight = 36 / 24,
    this.color = const Color(0xFF414141),
    this.textAlign = TextAlign.start,
    this.decoration,
    this.softWrap = true,
    this.maxLines, // Accept from constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontFamily: "Cralika",
        fontWeight: fontWeight,
        fontSize: fontSize + 1,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
        decoration: decoration,
      ),
    );
  }
}

class BarlowText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double lineHeight;
  final double letterSpacing;
  final Color color;
  final Color? backgroundColor;
  final TextAlign textAlign;
  final bool softWrap;
  final VoidCallback? onTap;
  final int? maxLines;

  // Decoration properties
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final Color? decorationColor;

  // Route-based styling properties
  final String? route;
  final bool enableUnderlineForActiveRoute;
  final bool enableUnderlineForCurrentFilter;
  final bool enableBackgroundForActiveRoute;
  final Color? activeBackgroundColor;
  final TextDecoration? activeUnderlineDecoration;

  // Filter properties
  final String? currentFilterValue; // New property for filter comparison

  // Hover properties
  final Color? hoverBackgroundColor;
  final bool enableHoverBackground;
  final Color? hoverTextColor;
  final bool enableHoverUnderline;
  final TextDecoration? hoverDecoration;
  final Color? hoverDecorationColor;

  static final String fontFamily = GoogleFonts.barlow().fontFamily ?? 'Barlow';

  const BarlowText({
    super.key,
    required this.text,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w500,
    this.lineHeight = 1.3,
    this.letterSpacing = 0.0,
    this.color = const Color(0xFF414141),
    this.backgroundColor,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
    this.onTap,
    this.maxLines,
    this.decoration,
    this.decorationStyle,
    this.decorationThickness,
    this.decorationColor,
    this.route,
    this.enableUnderlineForActiveRoute = false,
    this.enableUnderlineForCurrentFilter = false,
    this.enableBackgroundForActiveRoute = false,
    this.activeBackgroundColor,
    this.activeUnderlineDecoration,
    this.currentFilterValue, // Added to constructor
    this.hoverBackgroundColor,
    this.enableHoverBackground = false,
    this.hoverTextColor,
    this.enableHoverUnderline = false,
    this.hoverDecoration,
    this.hoverDecorationColor,
  });

  @override
  _BarlowTextState createState() => _BarlowTextState();
}

class _BarlowTextState extends State<BarlowText> {
  bool _isHovering = false;

  bool _isCurrentRoute(BuildContext context) {
    if (widget.route == null) return false;
    final currentLocation = GoRouterState.of(context).uri.path;
    return currentLocation == widget.route;
  }

  bool _isCurrentFilter() {
    // Compare the widget's text with the current filter value
    if (widget.currentFilterValue == null) return false;
    return widget.text == widget.currentFilterValue;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isCurrentRoute(context);
    final isCurrentFilter =
        widget.enableUnderlineForCurrentFilter ? _isCurrentFilter() : false;

    TextDecoration? decoration;
    Color? decorationColor;

    // Priority order: Active Route > Current Filter > Hover > Default
    if (isActive && widget.enableUnderlineForActiveRoute) {
      decoration = widget.activeUnderlineDecoration ?? TextDecoration.underline;
      decorationColor = widget.decorationColor;
    } else if (isCurrentFilter) {
      decoration = widget.activeUnderlineDecoration ?? TextDecoration.underline;
      decorationColor = widget.decorationColor;
    } else if (_isHovering && widget.enableHoverUnderline) {
      decoration = widget.hoverDecoration ?? TextDecoration.underline;
      decorationColor = widget.hoverDecorationColor;
    } else {
      decoration = widget.decoration;
      decorationColor = widget.decorationColor;
    }

    return GestureDetector(
      onTap:
          widget.onTap ??
          (widget.route != null ? () => context.go(widget.route!) : null),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Text(
          widget.text,
          textAlign: widget.textAlign,
          softWrap: widget.softWrap,
          maxLines: widget.maxLines,
          overflow: widget.maxLines != null ? TextOverflow.ellipsis : null,
          style: TextStyle(
            fontFamily: BarlowText.fontFamily,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            height: widget.lineHeight,
            letterSpacing: widget.letterSpacing,
            color:
                _isHovering && widget.hoverTextColor != null
                    ? widget.hoverTextColor
                    : widget.color,
            backgroundColor: _getBackgroundColor(isActive),
            decoration: decoration,
            decorationStyle: widget.decorationStyle,
            decorationThickness: widget.decorationThickness,
            decorationColor: decorationColor,
          ),
        ),
      ),
    );
  }

  Color? _getBackgroundColor(bool isActive) {
    if (_isHovering && widget.enableHoverBackground) {
      return widget.hoverBackgroundColor;
    }
    if (isActive && widget.enableBackgroundForActiveRoute) {
      return widget.activeBackgroundColor ?? widget.backgroundColor;
    }
    return widget.backgroundColor;
  }
}
