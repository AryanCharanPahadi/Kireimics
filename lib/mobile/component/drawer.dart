import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/mobile/component/scrolling_header.dart';
import 'package:kireimics/component/routes.dart'; // Import your routes file

import '../../component/custom_text.dart';

class DrawerMobile extends StatefulWidget {
  const DrawerMobile({super.key});

  @override
  State<DrawerMobile> createState() => _DrawerMobileState();
}

class _DrawerMobileState extends State<DrawerMobile> {
  bool _isCurrentRoute(String routePath) {
    final router = GoRouter.of(context);
    return router.routeInformationProvider.value.location == routePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF46856),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [ScrollingHeaderMobile(color: const Color(0xFFF46856))],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        "MENU",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: "Cralika",
                          fontWeight: FontWeight.w400,
                          fontSize: 32,
                          height: 1.0,
                          letterSpacing: 1.28,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Main Menu Items
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
              child: Divider(color: Colors.black),
            ),

            // Account Section
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 20),
              child: SizedBox(
                height: 164,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMenuItem("MY ACCOUNT"),
                    _buildMenuItem("MY ORDERS"),
                    _buildMenuItem("WISHLIST"),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 24, right: 32, top: 24),
              child: Divider(color: Colors.black),
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
                    _buildMenuItem("Log In / Sign Up"),
                  ],
                ),
              ),
            ),

            // Social Icons
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 32, top: 24),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      'assets/drawer/white_insta.svg',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 15),
                    SvgPicture.asset(
                      'assets/drawer/white_email.svg',
                      width: 14,
                      height: 18,
                    ),
                  ],
                ),
              ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            child: CustomText(
              text: text,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              lineHeight: 14,
              letterSpacing: 0.56,
              color: isActive ? Color(0xFFf68d80) : Colors.white,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
