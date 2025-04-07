import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(height: 20),
        Stack(
          children: [
            // Background container (first container)
            Column(
              children: [
                Container(
                  height: 243,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(
                        "assets/home_page/background.png",
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF238ca0).withOpacity(0.9),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 99,
                    ),
                    child: Container(
                      height: 120,
                      width: 342,
                      child: Text(
                        "/Every piece is 100% handmade, hand-glazed, fired, and packaged by me. My goal is to create fun yet functional pottery that adds flair to everyday decor and supports community animals and shelters/",
                        style: TextStyle(
                          fontFamily: GoogleFonts.barlow().fontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 30 / 14,
                          letterSpacing: 0.56,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                // This empty container pushes the image up in the Stack
                Container(
                  height:
                      377 - 100, // Adjust this value to control overlap amount
                ),
              ],
            ),

            // Image container positioned to overlap
            Positioned(
              top: 171,
              left: 24,
              right: 24,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 377, // Maximum height
                ),
                child: AspectRatio(
                  aspectRatio:
                      3 / 4, // Adjust this to match your image's aspect ratio
                  child: Image.asset(
                    "assets/about_us/profile_about.jpg",
                    fit: BoxFit.contain, // Changed from cover to contain
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22, right: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Text(
                "About",
                style: TextStyle(
                  fontFamily: "Cralika",
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  height: 36 / 24, // Equivalent to line-height: 36px
                  letterSpacing: 4, // Use a valid unit (e.g., pixels)
                  color: Color(0xFF414141),
                ),
              ),
              SizedBox(height: 15),

              Container(
                child: Text(
                  "Kireimics is a small, homegrown brand inspired by our five adopted cats. Our mission is to support local animal welfare charities and organizations through the proceeds of each sale. Passionate about aiding stray animals through adoption, spaying/neutering, and community initiatives, I envision Kireimics as a gathering place for animal lovers to build a thriving community and raise awareness through artistic expression.",
                  style: TextStyle(
                    fontFamily: GoogleFonts.barlow().fontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.2, // Equivalent to 100% line-height
                    letterSpacing: 0.0, // No extra spacing
                    color: Color(0xFF414141),
                  ),
                ),
              ),
              SizedBox(height: 44),

              Container(
                child: Row(
                  children: [
                    Text(
                      "LinkedIn",
                      style: TextStyle(
                        fontFamily: GoogleFonts.barlow().fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.0, // Equivalent to 100% line-height
                        letterSpacing: 0.56, // 4% of 14px
                        color: Color(0xFF3E5B84),
                      ),
                    ),
                    SizedBox(width: 32),

                    Text(
                      "Instagram",
                      style: TextStyle(
                        fontFamily: GoogleFonts.barlow().fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.0, // Equivalent to 100% line-height
                        letterSpacing: 0.56, // 4% of 14px
                        color: Color(0xFF3E5B84),
                      ),
                    ),
                    SizedBox(width: 32),

                    Text(
                      "Email",
                      style: TextStyle(
                        fontFamily: GoogleFonts.barlow().fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.0, // Equivalent to 100% line-height
                        letterSpacing: 0.56, // 4% of 14px
                        color: Color(0xFF3E5B84),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 44),

              Container(
                child: Text(
                  "Giving",
                  style: TextStyle(
                    fontFamily: "Cralika",
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                    height: 1.7, // 36px / 24px
                    letterSpacing: 0.96, // 4% of 24px
                    color: Color(0xFF414141),
                  ),
                ),
              ),
              SizedBox(height: 14),

              Container(
                child: Text(
                  "We donate a majority of the sales to local animal welfare charities and organisations via collaborations, direct money transfers & fundraisers. If you know of any animal causes who want to collaborate, let us know!",
                  style: TextStyle(
                    fontFamily: GoogleFonts.barlow().fontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.0, // 100% line-height
                    letterSpacing: 0.0, // 0% letter-spacing
                    color: Color(0xFF414141),
                  ),
                ),
              ),
              SizedBox(height: 24,)
            ],
          ),
        ),
      ],
    );
  }
}
