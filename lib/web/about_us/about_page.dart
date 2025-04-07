import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/web/component/above_footer.dart';

class AboutPageWeb extends StatelessWidget {
  const AboutPageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 280, top: 35),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 280,
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
                        top: 40,
                        right: 445,
                        left: 47,
                        bottom: 40,
                      ),
                      child: Text(
                        "/Every piece is 100% handmade, hand-glazed, fired, and packaged by me. My goal is to create fun yet functional pottery that adds flair to everyday decor and supports community animals and shelters/",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: GoogleFonts.barlow().fontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          height: 1.5,
                          letterSpacing: 0.04 * 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(height: 277),
              ],
            ),
            Positioned(
              top: 100,
              right: 112,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 377),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.asset(
                    "assets/about_us/profile_about.jpg",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 250, // Adjust based on your layout
              left: 280, // Position the text to the left of the image
              right: 466,
              child: SizedBox(
                width: 574, // Adjust width as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Cralika',
                        fontWeight: FontWeight.w400,
                        fontSize: 28,
                        height:
                            36 / 32, // Line height (line-height / font-size)
                        letterSpacing: 32 * 0.04, // 4% of font size
                        color: Color(0xFF414141),
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      "Kireimics is a small, homegrown brand inspired by our five adopted cats. Our mission is to support local animal welfare charities and organizations through the proceeds of each sale. Passionate about aiding stray animals through adoption, spaying/neutering, and community initiatives, I envision Kireimics as a gathering place for animal lovers to build a thriving community and raise awareness through artistic expression.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: GoogleFonts.barlow().fontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        height: 1.0, // Line height is 100%
                        letterSpacing: 0.0, // 0% of font size
                        color: Color(0xFF414141),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        AboveFooter(),
      ],
    );
  }
}
