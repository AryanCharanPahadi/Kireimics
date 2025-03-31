import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 63,
          left: 64,
          child: SvgPicture.asset(
            'assets/footerbg.svg',
            height: 239,
            width: 235,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),
        SizedBox(
          height: 550,
          width: MediaQuery.of(context).size.width,

          // color: Colors.green,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 18),
            child: Column(
              children: [
                SizedBox(height: 45),
                Divider(color: Color(0xFF3E5B84)),
                SizedBox(height: 30),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Shipping Policy",
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.64,
                        color: Color(0xFF3E5B84),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Privacy Policy",
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.64,
                        color: Color(0xFF3E5B84),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Contact",
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.64,
                        color: Color(0xFF3E5B84),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: 400,
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
                    ),
                  ],
                ),
                SizedBox(height: 20),

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
                SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: SvgPicture.asset(
                            'assets/Subtract.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                        const SizedBox(width: 28),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: SvgPicture.asset(
                            'assets/Icon.svg',
                            width: 18,
                            height: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
