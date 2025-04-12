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
      height: 550,
      margin: const EdgeInsets.only(top: 27),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/home_page/background.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF2472e3).withOpacity(0.9),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Center(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Ensures left alignment
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 300,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Ensures left alignment
                  children: [
                    Text(
                      "Let's Connect!",
                      style: TextStyle(
                        fontFamily: "Cralika",
                        fontWeight: FontWeight.w400,
                        fontSize: 26,
                        height: 1.5,
                        letterSpacing: 0.96,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 7.0),
                    Text(
                      "Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: GoogleFonts.barlow().fontFamily,
                        fontWeight: FontWeight.w200,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Ensures left alignment
                children: [
                  SizedBox(
                    width: 300,
                    child: customTextFormField(hintText: "YOUR NAME"),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: customTextFormField(hintText: "YOUR EMAIL"),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: customTextFormField(hintText: "MESSAGE"),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: customTextFormField(hintText: ""),
                  ),
                ],
              ),
              SizedBox(
                width: 300,

                child: Align(
                  alignment:
                      Alignment
                          .centerRight, // Aligns the submit button to the left
                  child: SvgPicture.asset(
                    "assets/home_page/submit.svg",
                    height: 19,
                    width: 58,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
  }) {
    return Stack(
      children: [
        // Hint text positioned on the left
        Positioned(
          left: 0,
          top: 16, // Adjust this value to align vertically
          child: Text(
            hintText,
            style: GoogleFonts.barlow(fontSize: 14, color: Colors.white),
          ),
        ),
        // Text field with right-aligned input
        TextFormField(
          controller: controller,
          cursorColor: Colors.white,
          textAlign: TextAlign.right, // Align user input to the right
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
            contentPadding: const EdgeInsets.only(top: 16),
          ),
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.barlow().fontFamily,
          ),
        ),
      ],
    );
  }
}
