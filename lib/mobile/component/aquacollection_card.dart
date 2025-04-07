import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AquaCollectionCard extends StatelessWidget {
  const AquaCollectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 14.0,right: 14,top: 24),
      // color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/home_page/PanelTitle.svg',
            height: 85,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/home_page/aquaCollection.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 14), // Space between image and text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns both texts at the top
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Aqua Collection",
                          style: TextStyle(
                            fontFamily: "Cralika",
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            height: 1.0,
                            letterSpacing: 0.72,
                            color: Color(0xFF3E5B84),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "VIEW",
                          style: TextStyle(
                            fontFamily: GoogleFonts.barlow().fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.0,
                            letterSpacing: 0.56,
                            color: Color(0xFF3E5B84),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "4 Pieces",
                          style: TextStyle(
                            fontFamily: GoogleFonts.barlow().fontFamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Color(0xFF3E5B84),
                          ),
                        ),
                        SizedBox(height: 24), // Adjusts spacing to match "VIEW"
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
