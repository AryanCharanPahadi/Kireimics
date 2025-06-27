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
    this.softWrap = true,
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
  final int? maxLines;

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
    this.maxLines,
  }) : super(key: key);

  FontWeight getIncreasedFontWeight(FontWeight original) {
    // Convert to numeric weight (e.g., w400 → 400), add 200
    int weightValue = _fontWeightToValue(original);
    int increased = (weightValue + 200).clamp(100, 900);
    return _fontWeightFromValue(increased);
  }

  int _fontWeightToValue(FontWeight fw) {
    switch (fw) {
      case FontWeight.w100:
        return 100;
      case FontWeight.w200:
        return 200;
      case FontWeight.w300:
        return 300;
      case FontWeight.w400:
        return 400;
      case FontWeight.w500:
        return 500;
      case FontWeight.w600:
        return 600;
      case FontWeight.w700:
        return 700;
      case FontWeight.w800:
        return 800;
      case FontWeight.w900:
        return 900;
      default:
        return 400;
    }
  }

  FontWeight _fontWeightFromValue(int value) {
    switch (value) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

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
        fontWeight: getIncreasedFontWeight(fontWeight),
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
