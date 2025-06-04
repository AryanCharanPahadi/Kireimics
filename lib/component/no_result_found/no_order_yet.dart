import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';

import '../app_routes/routes.dart';

class CartEmpty extends StatelessWidget {
  final String cralikaText;
  final String barlowText;
  final bool hideBrowseButton; // NEW PARAMETER

  const CartEmpty({
    super.key,
    this.cralikaText = "Your cart is empty!",
    this.barlowText =
    "What are you waiting for? Browse our wide range of products and bring home something new to love!",
    this.hideBrowseButton = false, // DEFAULT: SHOW BUTTON
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset("assets/icons/notFound.svg"),
        const SizedBox(height: 20),
        CralikaFont(
          text: cralikaText,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(height: 10),
        BarlowText(
          text: barlowText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),

        // CONDITIONAL BROWSE BUTTON
        if (!hideBrowseButton)
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.catalog);
            },
            child: BarlowText(
              text: "BROWSE OUR CATALOG",
              backgroundColor: const Color(0xFFb9d6ff),
              color: const Color(0xFF30578E),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
