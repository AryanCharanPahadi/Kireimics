import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../../../component/text_fonts/custom_text.dart';

class NoFoundPage extends StatefulWidget {
  const NoFoundPage({super.key});

  @override
  State<NoFoundPage> createState() => _NoFoundPageState();
}

class _NoFoundPageState extends State<NoFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width > 1400 ? 700 : 405,
            top: MediaQuery.of(context).size.width > 1400 ? 250 : 164,
            child: SvgPicture.asset(
              'assets/footer/footerbg.svg',
              height: 290,
              width: 254,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width > 1400 ? 1100 : 850,
            top: MediaQuery.of(context).size.width > 1400 ? 350 : 280,
            child: SvgPicture.asset(
              'assets/footer/diamond.svg',
              height: 60,
              width: 60,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width > 1400 ? 1000 : 750,
            top: MediaQuery.of(context).size.width > 1400 ? 650 : 500,
            child: SvgPicture.asset(
              'assets/footer/footerbg.svg',
              height: 150,
              width: 150,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width > 1400 ? 850 : 505,
            top: MediaQuery.of(context).size.width > 1400 ? 750 : 570,
            child: SvgPicture.asset(
              'assets/footer/diamond.svg',
              height: 30,
              width: 30,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width > 1400 ? 800 : 501.0,
              top: MediaQuery.of(context).size.width > 1400 ? 150 : 76,
            ),
            child: SizedBox(
              width: 428,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/header/fullLogoNew.png",
                    width: 277,
                    height: 45,
                  ),
                  const SizedBox(height: 84),
                  CralikaFont(
                    text: "404",
                    color: const Color(0xFF414141),
                    fontWeight: FontWeight.w600,
                    fontSize: 32.0,
                    lineHeight: 1.0,
                    letterSpacing: 0.128,
                  ),
                  const SizedBox(height: 8),
                  CralikaFont(
                    text: "Page Not Found!",
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    lineHeight: 1.0,
                    letterSpacing: 0.0,
                  ),
                  const SizedBox(height: 16),
                  BarlowText(
                    text:
                        "Looks like this page does not exist. Go back to our catalog and continue shopping.",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    lineHeight: 1.0,
                    letterSpacing: 0.0,
                  ),
                  const SizedBox(height: 32),
                  BarlowText(
                    text: "BROWSE OUR CATALOG",
                    backgroundColor: const Color(0xFFb9d6ff),
                    color: const Color(0xFF30578E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    onTap: () {
                      context.go(AppRoutes.catalog);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
