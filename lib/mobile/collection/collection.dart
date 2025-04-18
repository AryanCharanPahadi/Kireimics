import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/custom_text.dart';
import '../../component/routes.dart';
import '../../web/contact_us/contact_us_controller.dart';

class CollectionMobile extends StatefulWidget {
  const CollectionMobile({super.key});

  @override
  State<CollectionMobile> createState() => _CollectionMobileState();
}

class _CollectionMobileState extends State<CollectionMobile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/home_page/background.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color(0xFFffb853).withOpacity(0.9),
                  BlendMode.srcATop,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: 342,
                child: Text(
                  "/A wide range of handmade pottery that's designed to be fun & functional. Each piece is unique, original and perfect for adding charm to any space/",
                  style: TextStyle(
                    fontFamily: GoogleFonts.barlow().fontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 30 / 14,
                    letterSpacing: 0.56,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 22),
              child: CralikaFont(
                text: "3 Collections",
                fontWeight: FontWeight.w400,
                fontSize: 21,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Wrap(
              spacing: 16, // Horizontal space between items
              runSpacing: 18, // Vertical space between lines
              children: [
                BarlowText(
                  text: "All",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
                BarlowText(
                  text: "Cups & Mugs",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
                BarlowText(
                  text: "Plate & Bowls",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
                BarlowText(
                  text: "Accessories",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
                BarlowText(
                  text: "Collections",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                  route: AppRoutes.collection,
                  enableUnderlineForActiveRoute:
                      true, // Enable underline when active
                  decorationColor: Color(0xFF3E5B84), // Color of the underline
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: Divider(color: Color(0xFF3E5B84), height: 1),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BarlowText(
                  text: "Sort / New",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
                SizedBox(width: 16),
                BarlowText(
                  text: "Filter / All",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1.17,
                  ),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 196,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/home_page/aquaCollection.png',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Checkered Trinket Dish",
                                  style: const TextStyle(
                                    fontFamily: "Cralika",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 1.2,
                                    letterSpacing: 0.64,
                                    color: Color(0xFF3E5B84),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Rs. 500.00",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.barlow(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.2,
                                    color: const Color(0xFF3E5B84),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  "ADD TO CART",
                                  style: GoogleFonts.barlow(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    height: 1.2,
                                    letterSpacing: 0.56,
                                    color: const Color(0xFF3E5B84),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
