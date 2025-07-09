import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kireimics/mobile/component/scrolling_header.dart';
import 'package:kireimics/component/app_routes/routes.dart'; // Import your routes file
import '../../component/cart_length/cart_loader.dart';
import '../../component/google_sign_in/auth.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/utilities/url_launcher.dart';
import '../../web/checkout/checkout_controller.dart';

class DrawerMobile extends StatefulWidget {
  const DrawerMobile({super.key});

  @override
  State<DrawerMobile> createState() => _DrawerMobileState();
}

class _DrawerMobileState extends State<DrawerMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    getSocialMediaLinks();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward(); // Starts at "close"
  }

  String socialMediaLinks = '';
  String emailLink = '';
  String instagramLink = '';

  Future getSocialMediaLinks() async {
    final response = await http.get(
      Uri.parse(
        "https://www.kireimics.com/apis/common/general_links/get_general_links.php",
      ),
    );

    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      setState(() {
        socialMediaLinks = data[0]['social_media_links'];
        instagramLink = jsonDecode(socialMediaLinks)['Instagram'];
        emailLink = jsonDecode(socialMediaLinks)['Email'];
      });
      // print(socialMediaLinks);
      // print(instagramLink);
      // print(emailLink);
    }
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  bool _isCurrentRoute(String routePath) {
    final router = GoRouter.of(context);
    return router.routeInformationProvider.value.location == routePath;
  }

  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF46856),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                ScrollingHeaderMobile(customColor: const Color(0xFFF46856)),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.menu_close,
                          progress: AlwaysStoppedAnimation(1.0),
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // No animation reversal here, already handled in the parent
                        },
                      ),

                      const CralikaFont(
                        text: "MENU",
                        textAlign: TextAlign.right,
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        lineHeight: 1.0,
                        letterSpacing: 1.28,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                // Main Menu Items
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
                  child: SizedBox(
                    height: 162,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildMenuItem(
                          "HOME",
                          isActive: _isCurrentRoute(AppRoutes.home),
                          onTap: () {
                            context.go(AppRoutes.home);
                            Navigator.pop(context);
                          },
                        ),
                        _buildMenuItem(
                          isActive: _isCurrentRoute(AppRoutes.catalog),

                          "CATALOG",
                          onTap: () {
                            // Add your catalog route here if different
                            context.go(AppRoutes.catalog);
                            Navigator.pop(context);
                          },
                        ),
                        _buildMenuItem(
                          "SALE",
                          isActive: _isCurrentRoute(AppRoutes.sale),

                          onTap: () {
                            // Add your sale route here if different
                            context.go(AppRoutes.sale);
                            Navigator.pop(context);
                          },
                        ),
                        _buildMenuItem(
                          isActive: _isCurrentRoute(AppRoutes.about),

                          "ABOUT",
                          onTap: () {
                            context.go(AppRoutes.about);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 24, right: 32, top: 24),
                  child: Divider(color: Color(0xFF414141)),
                ),

                // Account Section
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
                  child: SizedBox(
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildMenuItem(
                          "MY ACCOUNT",
                          isActive: _isCurrentRoute(AppRoutes.myAccount),

                          onTap: () async {
                            bool isLoggedIn =
                                await _isLoggedIn(); // Await the Future<bool>

                            if (isLoggedIn) {
                              context.go(AppRoutes.myAccount);
                            } else {
                              context.go(AppRoutes.logIn);
                            }
                          },
                        ),
                        _buildMenuItem(
                          "MY ORDERS",
                          isActive: _isCurrentRoute(AppRoutes.myOrder),

                          onTap: () async {
                            bool isLoggedIn =
                                await _isLoggedIn(); // Await the Future<bool>

                            if (isLoggedIn) {
                              context.go(AppRoutes.myOrder);
                            } else {
                              context.go(AppRoutes.logIn);
                            }
                          },
                        ),
                        _buildMenuItem(
                          "WISHLIST",

                          isActive: _isCurrentRoute(AppRoutes.wishlist),

                          onTap: () async {
                            bool isLoggedIn =
                                await _isLoggedIn(); // Await the Future<bool>

                            if (isLoggedIn) {
                              context.go(AppRoutes.wishlist);
                            } else {
                              context.go(AppRoutes.logIn);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 24, right: 32, top: 24),
                  child: Divider(color: Color(0xFF414141)),
                ),
                // Policies Section
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
                  child: SizedBox(
                    height: 164,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildMenuItem(
                          isActive: _isCurrentRoute(AppRoutes.shippingPolicy),

                          "Shipping Policy",
                          onTap: () {
                            Navigator.pop(context); // Close drawer
                            context.go(AppRoutes.shippingPolicy);
                          },
                        ),
                        _buildMenuItem(
                          isActive: _isCurrentRoute(AppRoutes.privacyPolicy),

                          "Privacy Policy",
                          onTap: () {
                            Navigator.pop(context); // Close drawer
                            context.go(AppRoutes.privacyPolicy);
                          },
                        ),
                        _buildMenuItem(
                          isActive: _isCurrentRoute(AppRoutes.contactUs),

                          "Contact",
                          onTap: () {
                            Navigator.pop(context); // Close drawer
                            context.go(AppRoutes.contactUs);
                          },
                        ),

                        FutureBuilder<bool>(
                          future: _isLoggedIn(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            } else {
                              bool isLoggedIn = snapshot.data ?? false;
                              return _buildMenuItem(
                                isLoggedIn ? "Log Out" : "Log In / Sign Up",
                                onTap: () async {
                                  Navigator.pop(context); // Close drawer
                                  if (isLoggedIn) {
                                    // Perform logout operations
                                    await signOutGoogle();

                                    // Clear custom shared user data
                                    await SharedPreferencesHelper.clearUserData();
                                    await SharedPreferencesHelper.clearSelectedAddress();
                                    cartNotifier.value = 0;

                                    // Refresh CheckoutController
                                    final checkoutController = Get.put(
                                      CheckoutController(),
                                    );
                                    checkoutController.reset();
                                    context.go(
                                      AppRoutes.home,
                                    ); // Navigate to home
                                  } else {
                                    context.go(
                                      AppRoutes.logIn,
                                    ); // Navigate to login
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Social Icons
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 32,
                    top: 20,
                    bottom: 73,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            UrlLauncherHelper.launchURL(
                              context,
                              instagramLink.toString(),
                            ); // Replace with your email address
                          },
                          child: SvgPicture.asset(
                            'assets/drawer/white_insta.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            UrlLauncherHelper.launchURL(
                              context,
                              emailLink.toString(),
                            ); // Replace with your email address
                          },
                          child: SvgPicture.asset(
                            'assets/drawer/white_email.svg',
                            width: 14,
                            height: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String text, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
        ),
        child: CustomTextDrawer(
          text: text,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          fontSize: 14,
          lineHeight: 14,
          letterSpacing: 0.56,
          color: isActive ? Color(0xFFf68d80) : Colors.white,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
