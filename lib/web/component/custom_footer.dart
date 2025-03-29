import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomWebFooter extends StatelessWidget {
  const CustomWebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        height: 320,
        child: Stack(
          children: [
            Positioned(
              left: 57,
              bottom: 40,
              child: SvgPicture.asset(
                'assets/footerbg.svg',
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
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80, left: 21, right: 18),
                  child: Divider(color: Color(0xFF3E5B84), thickness: 1),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 21, top: 50),
                              child: Container(
                                height: 101,
                                width: 150,
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Shipping Policy",
                                      style: TextStyle(
                                        fontFamily:
                                        GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 1.0,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        fontFamily:
                                        GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 1.0,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Contact",
                                      style: TextStyle(
                                        fontFamily:
                                        GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 1.0,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 35,
                              width: 217,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.grey[50], // Light background
                                  elevation: 0, // No shadow
                                  side: BorderSide(
                                    color: Colors.grey[300]!,
                                  ), // Lighter border color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // Optional rounded corners
                                  ),
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
                                          // color: Color(0xFF94c0ff),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 21),
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 114,
                                width: 460,
                                child: Text(
                                  '"Kireimics" began as a passion project combining handmade pottery with a deep love for animals. Each piece we create carries dedication, creativity, and soul. Our mission extends beyond crafting beautiful pottery—we\'re committed to helping community strays. A majority of proceeds from every sale goes directly to animal organizations and charities.',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                    color: Color(0xFF414141),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 35,
                                width: 217,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 8),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
