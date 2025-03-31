import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Gridview extends StatefulWidget {
  const Gridview({super.key});

  @override
  State<Gridview> createState() => _GridviewState();
}

class _GridviewState extends State<Gridview> {
  final List<bool> _wishlistStates = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 24,
              childAspectRatio: 0.62,
            ),
            itemCount: 6,
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
                            'assets/plate.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 6,
                          right: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(79),
                                  border: Border.all(
                                    color: const Color(0xFFF46856),
                                  ),
                                ),
                                child: Text(
                                  "Few Pieces Left",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.48,
                                    color: const Color(0xFFF46856),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _wishlistStates[index] =
                                        !_wishlistStates[index];
                                  });
                                },
                                child: SvgPicture.asset(
                                  _wishlistStates[index]
                                      ? 'assets/IconWishlist.svg'
                                      : 'assets/IconWishlistEmpty.svg',
                                  width: 33.99,
                                  height: 19.33,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Checkered Trinket Dish",
                            style: TextStyle(
                              fontFamily: "Cralika",
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 1.2,
                              letterSpacing: 0.64,
                              color: Color(0xFF3E5B84),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Rs. 500.00",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: GoogleFonts.barlow().fontFamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 1.2,
                              color: Color(0xFF3E5B84),
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "ADD TO CART",
                              style: TextStyle(
                                fontFamily: GoogleFonts.barlow().fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.2,
                                letterSpacing: 0.56,
                                color: Color(0xFF3E5B84),
                              ),
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
    );
  }
}
