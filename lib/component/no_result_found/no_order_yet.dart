import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';

import '../app_routes/routes.dart';

class CartEmpty extends StatelessWidget {
  final String cralikaText;
  final String barlowText;
  final bool hideBrowseButton;

  // NEW FONT SIZE PARAMETERS
  final double cralikaFontSize;
  final double barlowFontSize;
  final double browseButtonFontSize;

  const CartEmpty({
    super.key,
    this.cralikaText = "Your cart is empty!",
    this.barlowText =
    "What are you waiting for? Browse our wide range of products and bring home something new to love!",
    this.hideBrowseButton = false,

    // DEFAULT FONT SIZES
    this.cralikaFontSize = 20,
    this.barlowFontSize = 16,
    this.browseButtonFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset("assets/icons/notFound.svg"),
        const SizedBox(height: 20),
        CralikaFont(
          text: cralikaText,
          fontSize: cralikaFontSize,
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(height: 10),
        BarlowText(
          text: barlowText,
          fontSize: barlowFontSize,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        if (!hideBrowseButton)
          GestureDetector(
            onTap: () {
              final router = GoRouter.of(context);
              final currentRoute =
              router.routeInformationProvider.value.uri.toString();

              if (currentRoute.contains(AppRoutes.catalog)) {
                context.pop(); // Already on catalog → pop back
              } else {
                context.go(AppRoutes.catalog); // Not on catalog → navigate
              }
            },
            child: BarlowText(
              text: "BROWSE OUR CATALOG",
              backgroundColor: const Color(0xFFb9d6ff),
              color: const Color(0xFF30578E),
              fontSize: browseButtonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
