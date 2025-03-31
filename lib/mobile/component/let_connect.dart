import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LetConnect extends StatefulWidget {
  const LetConnect({super.key});

  @override
  State<LetConnect> createState() => _LetConnectState();
}

class _LetConnectState extends State<LetConnect> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 476,
      margin: const EdgeInsets.only(top: 27),

      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/bggrid.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF2472e3).withOpacity(0.9),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's Connect!",
                  style: TextStyle(
                    fontFamily: "Cralika", // Cralika font
                    fontWeight: FontWeight.w400, // Equivalent to 400
                    fontSize: 24, // 24px
                    height: 1.5, // Line height 36px (36/24)
                    letterSpacing: 0.96, // 4% of 24px = 0.96
                    color: Color(0xFFFFFFFF), // White color
                  ),
                ),
                SizedBox(height: 7.0),
                Text(
                  "Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: GoogleFonts.barlow().fontFamily,
                    fontWeight: FontWeight.w200,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    cursorColor:
                        Colors.white, // Set the cursor color to white

                    decoration: InputDecoration(
                      hintText: "YOUR NAME",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: GoogleFonts.barlow().fontFamily,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    cursorColor:
                        Colors.white, // Set the cursor color to white

                    decoration: InputDecoration(
                      hintText: "YOUR EMAIL",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: GoogleFonts.barlow().fontFamily,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    cursorColor:
                        Colors.white, // Set the cursor color to white

                    decoration: InputDecoration(
                      hintText: "MESSAGE",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: GoogleFonts.barlow().fontFamily,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    cursorColor:
                        Colors.white, // Set the cursor color to white

                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: GoogleFonts.barlow().fontFamily,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 235),
              child: Column(
                children: [
                  SvgPicture.asset(
                    "assets/Buttons.svg",
                    height: 19,
                    width: 58,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
