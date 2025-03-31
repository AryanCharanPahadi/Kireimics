import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AquaCollectionCard extends StatelessWidget {
  const AquaCollectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left "New In!" Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/PanelTitle.svg',
                    width: 75,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              SizedBox(width: 2),
              // Image and Details
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align content with image
                  children: [
                    Align(
                      alignment:
                          Alignment
                              .centerRight, // Ensure image aligns properly
                      child: Image.asset(
                        'assets/aquaCollection.png',
                        width: 284,
                        height: 179,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween, // Align text and VIEW
                      children: [
                        Text(
                          "Aqua Collection",
                          style: TextStyle(
                            fontFamily: "Cralika", // Cralika font
                            fontWeight: FontWeight.w400, // Equivalent to 400
                            fontSize: 18, // 18px
                            height: 2.0, // Line height 36px (36/18)
                            letterSpacing: 0.72, // 4% of 18px = 0.72
                            color: Color(0xFF3E5B84), // Custom color
                          ),
                        ),

                        Text(
                          "VIEW",
                          style: TextStyle(
                            fontFamily:
                                GoogleFonts.barlow()
                                    .fontFamily, // Barlow font
                            fontWeight: FontWeight.w600, // Equivalent to 600
                            fontSize: 14, // 14px
                            height: 1.0, // Line height 100% (14px / 14px)
                            letterSpacing: 0.56, // 4% of 14px = 0.56
                            color: Color(0xFF3E5B84), // Custom color
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      "4 Pieces",
                      style: TextStyle(
                        fontFamily:
                            GoogleFonts.barlow().fontFamily, // Barlow font
                        fontWeight: FontWeight.w400, // Equivalent to 400
                        fontSize: 14, // 14px
                        height: 1.0, // Line height 100% (14px / 14px)
                        letterSpacing: 0.0, // 0% letter spacing
                        color: Color(0xFF3E5B84), // Custom color
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
