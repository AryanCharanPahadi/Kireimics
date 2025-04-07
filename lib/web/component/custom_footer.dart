import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomWebFooter extends StatelessWidget {
  final Function(String) onItemSelected;

  const CustomWebFooter({super.key, required this.onItemSelected});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 29, right: 29, bottom: 24),
      child: Container(
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
                  child: Divider(color: Color(0xFF3E5B84), thickness: 1),
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
                              child: Text(
                                "Shipping Policy",
                                style: GoogleFonts.barlow(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.64,
                                  color: Color(0xFF3E5B84),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => onItemSelected('Privacy Policy'),

                              child: Text(
                                "Privacy Policy",
                                style: GoogleFonts.barlow(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.64,
                                  color: Color(0xFF3E5B84),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => onItemSelected('Contact'),

                              child: Text(
                                "Contact",
                                style: GoogleFonts.barlow(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.64,
                                  color: Color(0xFF3E5B84),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 460,
                            child: Text(
                              '"Kireimics" began as a passion project combining handmade pottery with a deep love for animals. Each piece we create carries dedication, creativity, and soul. Our mission extends beyond crafting beautiful pottery—we\'re committed to helping community strays. A majority of proceeds from every sale goes directly to animal organizations and charities.',
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
                                    color: Color(0xFF3e5b84),
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
                            "Copyright Kireimics 2025",
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
