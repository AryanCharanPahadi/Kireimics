import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/mobile/component/footer/footer_controller.dart';

import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';

class Footer extends StatelessWidget {
  final Function(String) onItemSelected;

  Footer({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final FooterController footerController = Get.put(FooterController());

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
    return Padding(
      padding: EdgeInsets.only(
        left: isLargeScreen ? 140 : 29,
        right: isLargeScreen ? 172 : 24,
      ),
      child: SizedBox(
        height: 320,
        child: Stack(
          children: [
            // Background Image on the Left
            Positioned(
              left: 57,
              bottom: 22,
              top: 60,

              child: SvgPicture.asset(
                'assets/footer/footerbg.svg',
                height: 258,
                width: 254,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  Color(0xFFDDEAFF),
                  BlendMode.srcIn,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 50),
                  child: Divider(color: Color(0xFF30578E), thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => onItemSelected('Shipping Policy'),
                              child: BarlowText(
                                text: "Shipping Policy",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.64,
                                color: Color(0xFF30578E),
                                route: AppRoutes.shippingPolicy,
                                enableUnderlineForActiveRoute: true,
                                decorationColor: Color(0xFF30578E),
                                hoverTextColor: const Color(0xFF2876E4),

                              ),
                            ),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => onItemSelected('Privacy Policy'),

                              child: BarlowText(
                                text: "Privacy Policy",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.64,
                                color: Color(0xFF30578E),
                                route: AppRoutes.privacyPolicy,
                                enableUnderlineForActiveRoute: true,
                                decorationColor: Color(0xFF30578E),
                                hoverTextColor: const Color(0xFF2876E4),

                              ),
                            ),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => onItemSelected('Contact'),

                              child: BarlowText(
                                text: "Contact",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.64,
                                color: Color(0xFF30578E),
                                route: AppRoutes.contactUs,
                                enableUnderlineForActiveRoute: true,
                                decorationColor: Color(0xFF30578E),
                                hoverTextColor: const Color(0xFF2876E4),

                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Obx(
                        () =>
                            footerController.isLoading.value
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : footerController.errorMessage.value.isNotEmpty
                                ? Center(
                                  child: Text(
                                    footerController.errorMessage.value,
                                  ),
                                )
                                : footerController.footerData == null
                                ? const Center(
                                  child: Text('No Footer Details Found'),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: 460,
                                      child: Text(
                                        footerController.footerData.isNotEmpty
                                            ? footerController.footerData
                                            : "Kireimics\" began as a passion project combining handmade pottery with a deep love for animals. Each piece we create carries dedication, creativity, and soul. Our mission extends beyond crafting beautiful pottery—we\\'re committed to helping community strays. A majority of proceeds from every sale goes directly to animal organizations and charities.",

                                        style: GoogleFonts.barlow(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Color(0xFF414141),
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: null, // Disables the button
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[50],
                            elevation: 0,
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45),
                            ),
                            disabledForegroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.grey[50],
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Handmade",
                                  style: TextStyle(
                                    fontFamily: 'Cralika',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    letterSpacing: 0.04,
                                    color: Color(0xFF30578E),
                                  ),
                                ),
                                TextSpan(
                                  text: "with",
                                  style: TextStyle(
                                    fontFamily: 'Cralika',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    letterSpacing: 0.04,
                                    color: Color(0xFF5a8acf),
                                  ),
                                ),
                                TextSpan(
                                  text: "love",
                                  style: TextStyle(
                                    fontFamily: 'Cralika',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    letterSpacing: 0.04,
                                    color: Color(0xFF94c0ff),
                                  ),
                                ),
                                TextSpan(
                                  text: "🩵",
                                  style: TextStyle(
                                    fontFamily: 'Cralika',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    letterSpacing: 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 473,
                          height: 14,
                          child: Text(
                            "Copyright Kireimics ${DateTime.now().year}",
                            style: TextStyle(
                              fontFamily: GoogleFonts.barlow().fontFamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0,
                              height: 1.0,
                              letterSpacing: 0.0,
                              color: Color(0xFF979797),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
