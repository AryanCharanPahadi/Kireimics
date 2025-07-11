import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/cart_length/cart_loader.dart';
import '../../component/google_sign_in/auth.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart' show AppRoutes;
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web/checkout/checkout_controller.dart';
import '../../web_desktop_common/login_signup/login/login_page.dart';
import '../../web_desktop_common/login_signup/signup/signup.dart';

class ProfileDropdown extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const ProfileDropdown({
    super.key,
    required this.isVisible,
    required this.onClose,
  });

  @override
  State<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();

  // Check if the user is logged in by looking for user data in SharedPreferences
  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
    if (!widget.isVisible) return const SizedBox.shrink();

    return FutureBuilder<bool>(
      future: _isLoggedIn(), // Check if the user is logged in
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Show nothing while checking login state
        }

        bool isLoggedIn = snapshot.data ?? false;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final RenderBox? dropdownBox =
                      _dropdownKey.currentContext?.findRenderObject()
                          as RenderBox?;
                  if (dropdownBox != null) {
                    final dropdownPosition = dropdownBox.localToGlobal(
                      Offset.zero,
                    );
                    final dropdownSize = dropdownBox.size;
                    final tapPosition = details.globalPosition;
                    final isInDropdown =
                        tapPosition.dx >= dropdownPosition.dx &&
                        tapPosition.dx <=
                            dropdownPosition.dx + dropdownSize.width &&
                        tapPosition.dy >= dropdownPosition.dy &&
                        tapPosition.dy <=
                            dropdownPosition.dy + dropdownSize.height;
                    if (isInDropdown) {
                      return;
                    }
                  }
                  widget.onClose();
                },
              ),
            ),
            Positioned(
              top: 99,
              right: isLargeScreen ? 75 : 32,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Material(
                  elevation: 4,
                  child: Container(
                    key: _dropdownKey,
                    width: 180,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          isLoggedIn
                              ? _buildLoggedInMenu() // Show logged-in menu if user is logged in
                              : _buildLoggedOutMenu(), // Show logged-out menu if user is not logged in
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Logged in menu items
  List<Widget> _buildLoggedInMenu() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // print("My Account tapped (external)");
            widget.onClose();
            context.go(AppRoutes.myAccount);
          },
          child: const BarlowText(
            text: "My Account",
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF30578E),
            hoverTextColor: Color(0xFF2876E4),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // print("My Orders tapped (external)");
            widget.onClose();
            context.go(AppRoutes.myOrder); // Placeholder route
          },
          child: const BarlowText(
            text: "My Orders",
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF30578E),
            hoverTextColor: Color(0xFF2876E4),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // print("My Wishlist tapped (external)");
            widget.onClose();
            context.go(AppRoutes.wishlist); // Placeholder route
          },
          child: const BarlowText(
            text: "My Wishlist",
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF30578E),
            hoverTextColor: Color(0xFF2876E4),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(color: Color(0xFF30578E)),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          widget.onClose();

          // Sign out from Google (and Firebase)
          await signOutGoogle();

          // Clear custom shared user data
          await SharedPreferencesHelper.clearUserData();
          await SharedPreferencesHelper.clearSelectedAddress();
          await SharedPreferencesHelper.clearAllProductIds();
          cartNotifier.value = 0;

          // Refresh CheckoutController
          final CheckoutController checkoutController = Get.put(
            CheckoutController(),
          );
          await checkoutController.showLoginBox == true;
          checkoutController.reset();

          // Navigate to home
          context.go(AppRoutes.home);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const BarlowText(
            text: 'LOGOUT',

            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFFAEAEAE),
            hoverBackgroundColor: Color(0xFFb9d6ff),
            enableHoverBackground: true,
            decorationColor: const Color(0xFF30578E),
            hoverTextColor: const Color(0xFF2876E4),
            hoverDecorationColor: Color(0xFF2876E4),
          ),
        ),
      ),
    ];
  }

  // Logged out menu items
  List<Widget> _buildLoggedOutMenu() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onClose();

                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return LoginPage();
                    },
                  );
                },
                child: const BarlowText(
                  text: 'LOG IN',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF30578E),
                  hoverBackgroundColor: Color(0xFFb9d6ff),
                  enableHoverBackground: true,
                  decorationColor: const Color(0xFF30578E),
                  hoverTextColor: const Color(0xFF2876E4),
                  hoverDecorationColor: Color(0xFF2876E4),
                ),
              ),
              const SizedBox(width: 8), // spacing between Log In and Sign Up
              Text(
                '/',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF30578E),
                ),
              ),
              const SizedBox(width: 8), // spacing between Log In and Sign Up

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onClose();

                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Signup();
                    },
                  );
                },
                child: BarlowText(
                  text: 'SIGN UP',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF30578E),
                  hoverBackgroundColor: Color(0xFFb9d6ff),
                  enableHoverBackground: true,
                  decorationColor: const Color(0xFF30578E),
                  hoverTextColor: const Color(0xFF2876E4),
                  hoverDecorationColor: Color(0xFF2876E4),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Color(0xFF30578E)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // print("My Account tapped (external)");
                widget.onClose();

                if (_isLoggedIn == true) {
                  context.go(AppRoutes.myAccount);
                } else {
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) => const LoginPage(),
                  );
                }
              },
              child: const BarlowText(
                text: "My Account",
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF30578E),
                hoverTextColor: Color(0xFF2876E4),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // print("My Account tapped (external)");
                widget.onClose();

                if (_isLoggedIn == true) {
                  context.go(AppRoutes.myOrder);
                } else {
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) => const LoginPage(),
                  );
                }
              },
              child: const BarlowText(
                text: "My Orders",
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF30578E),
                hoverTextColor: Color(0xFF2876E4),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // print("My Account tapped (external)");
                widget.onClose();

                if (_isLoggedIn == true) {
                  context.go(AppRoutes.wishlist);
                } else {
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) => const LoginPage(),
                  );
                }
              },
              child: const BarlowText(
                text: "My Wishlist",
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF30578E),
                hoverTextColor: Color(0xFF2876E4),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
