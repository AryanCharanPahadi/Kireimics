import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/component/shared_preferences/shared_preferences.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/component/utilities/utility.dart';
import '../login_signup/login/login_page.dart';
class NotifyMeButton extends StatefulWidget {
  final void Function(String)? onWishlistChanged;
  final void Function(String)? onErrorWishlistChanged;
  final int? productId;
  final Color? backgroundColor; // <-- add this
  final bool? enableHoverBackground; // <-- Add this


  // Optional text style parameters
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? lineHeight;
  final Color? hoverBackgroundColor;
  final Color? hoverTextColor;

  const NotifyMeButton({
    Key? key,
    this.enableHoverBackground, // <-- Add here

    this.onWishlistChanged,
    this.onErrorWishlistChanged,
    this.productId,
    this.textColor,
    this.fontWeight,
    this.fontSize,
    this.lineHeight,
    this.hoverBackgroundColor,
    this.hoverTextColor,
    this.backgroundColor, // <-- include here

  }) : super(key: key);

  @override
  State<NotifyMeButton> createState() => _NotifyMeButtonState();
}

class _NotifyMeButtonState extends State<NotifyMeButton> {
  String email = "";

  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  Future<void> _loadUserData() async {
    String? storedUser = await SharedPreferencesHelper.getUserData();
    if (storedUser != null) {
      List<String> userDetails = storedUser.split(', ');
      if (userDetails.length >= 4) {
        setState(() {
          email = userDetails[3];
        });
      } else {
        // print('Invalid user data format: $storedUser');
      }
    } else {
      // print('No user data found in SharedPreferences');
    }
  }

  Future<void> _callNotifyQuery() async {
    if (widget.productId == null || email.isEmpty) {
      widget.onErrorWishlistChanged?.call("Product ID or email is missing");
      return;
    }

    String formattedDate = getFormattedDate();
    final response = await ApiHelper.notifyQuery(
      pId: widget.productId.toString(),
      email: email,
      createdAt: formattedDate,
    );

    if (response['error'] == true) {
      widget.onErrorWishlistChanged?.call("Error: ${response['message']}");
    } else {
      widget.onWishlistChanged?.call("We'll notify you when this product is back in stock.");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return GestureDetector(
      onTap: () async {
        bool isLoggedIn = await _isLoggedIn();
        final screenWidth = MediaQuery.of(context).size.width;

        if (isLoggedIn) {
          await _loadUserData();
          await _callNotifyQuery();
        } else if (screenWidth < 800) {
          final result = await context.push(
            "${AppRoutes.logIn}?source=notify_me&productId=${widget.productId}",
          );
          if (result == true && await _isLoggedIn()) {
            await _loadUserData();
            await _callNotifyQuery();
          } else {
            widget.onErrorWishlistChanged?.call("Login was not completed");
          }
        } else {
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (BuildContext context) => LoginPage(
              onLoginSuccess: () async {
                await _loadUserData();
                Navigator.of(context).pop();
                await _callNotifyQuery();
              },
            ),
          );
        }
      },
      child: Container(
        decoration: widget.backgroundColor != null
            ? BoxDecoration(color: widget.backgroundColor)
            : null,
        child: BarlowText(
          text: "NOTIFY ME",
          color: widget.textColor ??
              (isMobile ? const Color(0xFF30578E) : Colors.white),
          fontWeight: widget.fontWeight ?? FontWeight.w600,
          fontSize: widget.fontSize ?? (isMobile ? 14 : 16),
          lineHeight: widget.lineHeight ?? 1.0,
          enableHoverBackground: widget.enableHoverBackground ?? true, // <-- respect user flag
          hoverBackgroundColor: widget.hoverBackgroundColor ?? Colors.white,
          hoverTextColor: widget.hoverTextColor ?? const Color(0xFF30578E),
        ),
      ),
    );
  }
}