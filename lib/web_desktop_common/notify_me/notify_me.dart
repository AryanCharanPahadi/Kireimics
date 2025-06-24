import 'package:flutter/material.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/utilities/utility.dart';
import '../login_signup/login/login_page.dart';

class NotifyMeButton extends StatefulWidget {
  final void Function(String)? onWishlistChanged;
  final void Function(String)? onErrorWishlistChanged;
  final int? productId;

  const NotifyMeButton({
    Key? key,
    this.onWishlistChanged,
    this.productId,
    this.onErrorWishlistChanged,
  }) : super(key: key);

  @override
  State<NotifyMeButton> createState() => _NotifyMeButtonState();
}

class _NotifyMeButtonState extends State<NotifyMeButton> {
  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String email = "";

  Future<void> _loadUserData() async {
    String? storedUser = await SharedPreferencesHelper.getUserData();

    if (storedUser != null) {
      List<String> userDetails = storedUser.split(', ');

      if (userDetails.length >= 4) {
        email = userDetails[3];
      } else {
        print('Invalid user data format: $storedUser');
      }
    } else {
      print('No user data found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        String formattedDate = getFormattedDate();

        print('NotifyMeButton tapped with productId: ${widget.productId}');
        bool isLoggedIn = await _isLoggedIn();
        print("This is the user email: $email");

        if (isLoggedIn && widget.productId != null && email.isNotEmpty) {
          // Call the notifyQuery API
          final response = await ApiHelper.notifyQuery(
            pId: widget.productId.toString(),
            email: email,
            createdAt: formattedDate,
          );

          // Handle API response
          if (response['error'] == true) {
            widget.onErrorWishlistChanged?.call(
              "Error: ${response['message']}",
            );
          } else {
            // Success: Notify user
            widget.onWishlistChanged?.call(
              "We'll notify you when this product is back in stock.",
            );
          }
        } else if (!isLoggedIn) {
          // Show login dialog if not logged in
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder:
                (BuildContext context) => LoginPage(
                  onLoginSuccess: () async {
                    print("User logged in via Notify Me button.");
                    await _loadUserData(); // Reload user data after login
                    Navigator.of(context).pop(); // Close login dialog

                    // Call API after successful login
                    if (widget.productId != null && email.isNotEmpty) {
                      final response = await ApiHelper.notifyQuery(
                        pId: widget.productId.toString(),
                        email: email,
                        createdAt: formattedDate,
                      );

                      if (response['error'] == true) {
                        widget.onErrorWishlistChanged?.call(
                          "Error: ${response['message']}",
                        );
                      } else {
                        widget.onWishlistChanged?.call(
                          "We'll notify you when this product is back in stock.",
                        );
                      }
                    }
                  },
                ),
          );
        } else {
          // Handle case where productId or email is missing
          widget.onErrorWishlistChanged?.call(
            "Product Id and Email is missing",
          );
        }
      },
      child: BarlowText(
        text: "NOTIFY ME",
        color:
            MediaQuery.of(context).size.width < 800
                ? Color(0xFF30578E)
                : Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: MediaQuery.of(context).size.width < 800 ? 14 : 16,
        lineHeight: 1.0,
        enableHoverBackground: true,
        hoverBackgroundColor: Colors.white,
        hoverTextColor: Color(0xFF30578E),
      ),
    );
  }
}
