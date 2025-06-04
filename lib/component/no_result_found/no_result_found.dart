import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';

import '../app_routes/routes.dart';

class BrowseOurCatalog extends StatelessWidget {
  final String? browserText;

  const BrowseOurCatalog({super.key, this.browserText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset("assets/icons/notFound.svg"),
        SizedBox(height: 20),
        CralikaFont(
          text: "No results found!",
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 10),
        BarlowText(
          text: browserText!,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            context.go(AppRoutes.catalog);
          },
          child: BarlowText(
            text: "BROWSE OUR CATALOG",
            backgroundColor: Color(0xFFb9d6ff),
            color: Color(0xFF30578E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
