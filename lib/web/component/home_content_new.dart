import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'above_footer.dart';

class HomeContentNew extends StatefulWidget {
  const HomeContentNew({super.key});

  @override
  State<HomeContentNew> createState() => _HomeContentNewState();
}

class _HomeContentNewState extends State<HomeContentNew> {
  final List<bool> _isHoveredList = List.generate(
    6,
    (_) => false,
  ); // Track hover state for each item
  final List<bool> _wishlistStates = List.filled(
    6,
    false,
  ); // Track wishlist state

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // Background sticky container moved first
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 313,
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = constraints.maxWidth;

                        return Padding(
                          padding: EdgeInsets.only(
                            top: 90,
                            right:
                                screenWidth * 0.07, // Responsive right padding
                            left: screenWidth * 0.20, // Responsive left padding
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center, // Align all columns at the top
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.25,
                                        child: TextFormField(
                                          cursorColor: Colors.white,
                                          decoration: InputDecoration(
                                            hintText: "YOUR NAME",
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily:
                                                  GoogleFonts.barlow()
                                                      .fontFamily,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: screenWidth * 0.25,
                                        child: TextFormField(
                                          cursorColor: Colors.white,
                                          decoration: InputDecoration(
                                            hintText: "YOUR EMAIL",
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily:
                                                  GoogleFonts.barlow()
                                                      .fontFamily,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.25,
                                        child: TextFormField(
                                          cursorColor: Colors.white,
                                          decoration: InputDecoration(
                                            hintText: "YOUR MESSAGE",
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily:
                                                  GoogleFonts.barlow()
                                                      .fontFamily,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: screenWidth * 0.25,
                                        child: TextFormField(
                                          cursorColor: Colors.white,
                                          decoration: InputDecoration(
                                            hintText: "",
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily:
                                                  GoogleFonts.barlow()
                                                      .fontFamily,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: screenWidth * 0.20,
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/Buttons.svg",
                                          height: 19,
                                          width: 58,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "LET'S CONNECT!",
                                      style: TextStyle(
                                        fontFamily: 'Cralika',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 32,
                                        letterSpacing: 0.04 * 32,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.25,
                                      child: Text(
                                        "Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily:
                                              GoogleFonts.barlow().fontFamily,
                                          fontWeight: FontWeight.w200,
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  AboveFooter(),
                ],
              ),
            ),
          ),

          // Scrollable content on top
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    return Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.4, // 40% of screen width
                            top: 17,
                            right: screenWidth * 0.07, // 7% of screen width
                          ),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/aquaCollection.png',
                                width:
                                    screenWidth * 0.8, // Adjust width as needed
                                height:
                                    screenWidth * 0.27, // Maintain aspect ratio
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  width: screenWidth * 0.2, // Scale with screen
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        screenWidth * 0.2, // Prevents overflow
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: const Text(
                                          'Aqua Collection',
                                          style: TextStyle(
                                            fontFamily: 'Cralika',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            height: 36 / 20,
                                            letterSpacing: 0.04 * 20,
                                            color: Color(0xFF0D2C54),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '4 Pieces',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.0,
                                            letterSpacing: 0.0,
                                            color: Color(0xFF3E5B84),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'VIEW',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            height: 1.0,
                                            letterSpacing: 0.04 * 16,
                                            color: Color(0xFF0D2C54),
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
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.244, // 24% of screen width
                            top: 42,
                            right: screenWidth * 0.08, // Scale right padding
                          ),
                          child: SvgPicture.asset(
                            'assets/PanelTitle.svg',
                            width: screenWidth * 0.3, // Scale width dynamically
                            height: screenWidth * 0.16, // Maintain aspect ratio
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Container(
              //   width: double.infinity,
              //   child: Stack(
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.only(left: 747, top: 17, right: 90),
              //         child: MouseRegion(
              //           onEnter: (_) => setState(() => _isHovered = true),
              //           onExit: (_) => setState(() => _isHovered = false),
              //           child: Stack(
              //             children: [
              //               Image.asset(
              //                 'assets/aquaCollection.png',
              //                 width: 699,
              //                 height: 373,
              //                 fit: BoxFit.cover,
              //               ),
              //               Positioned(
              //                 bottom: 16,
              //                 right: 16,
              //                 child: AnimatedOpacity(
              //                   duration: Duration(milliseconds: 300),
              //                   opacity: _isHovered ? 1.0 : 0.0,
              //                   child: Container(
              //                     width: 282,
              //                     height: 120,
              //                     padding: const EdgeInsets.all(12),
              //                     color: Colors.white,
              //                     child: Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: [
              //                         const Text(
              //                           'Aqua Collection',
              //                           style: TextStyle(
              //                             fontFamily: 'Cralika',
              //                             fontWeight: FontWeight.w600,
              //                             fontSize: 20,
              //                             height: 36 / 20,
              //                             letterSpacing: 0.04 * 20,
              //                             color: Color(0xFF0D2C54),
              //                           ),
              //                         ),
              //                         const SizedBox(height: 4),
              //                         Text(
              //                           '4 Pieces',
              //                           style: TextStyle(
              //                             fontFamily: GoogleFonts.barlow().fontFamily,
              //                             fontWeight: FontWeight.w400,
              //                             fontSize: 14,
              //                             height: 1.0,
              //                             letterSpacing: 0.0,
              //                             color: Color(0xFF3E5B84),
              //                           ),
              //                         ),
              //                         const SizedBox(height: 14),
              //                         Text(
              //                           'VIEW',
              //                           style: TextStyle(
              //                             fontFamily: GoogleFonts.barlow().fontFamily,
              //                             fontWeight: FontWeight.w600,
              //                             fontSize: 16,
              //                             height: 1.0,
              //                             letterSpacing: 0.04 * 16,
              //                             color: Color(0xFF0D2C54),
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.only(left: 537, top: 42, right: 90),
              //         child: SvgPicture.asset(
              //           'assets/PanelTitle.svg',
              //           width: 261,
              //           height: 214,
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    right:
                        MediaQuery.of(context).size.width *
                        0.07, // 7% of screen width
                    left: 292,
                    top: 30,
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 23,
                          mainAxisSpacing: 23,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return MouseRegion(
                        onEnter:
                            (_) => setState(() => _isHoveredList[index] = true),
                        onExit:
                            (_) =>
                                setState(() => _isHoveredList[index] = false),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double imageWidth = constraints.maxWidth;
                            double imageHeight = constraints.maxHeight;

                            return SizedBox(
                              width: imageWidth,
                              height: imageHeight,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/plate.jpeg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top:
                                        imageHeight *
                                        0.04, // 4% of image height
                                    left:
                                        imageWidth * 0.05, // 5% of image width
                                    right:
                                        imageWidth * 0.05, // 5% of image width
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SvgPicture.asset(
                                          index == 1
                                              ? 'assets/off.svg'
                                              : 'assets/fewPiecesLeft.svg',
                                          width:
                                              imageWidth *
                                              0.5, // 50% of image width
                                          height:
                                              imageHeight *
                                              0.1, // 10% of image height
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
                                            width:
                                                imageWidth *
                                                0.12, // 12% of image width
                                            height:
                                                imageHeight *
                                                0.06, // 6% of image height
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom:
                                        imageHeight *
                                        0.02, // 2% of image height
                                    left:
                                        imageWidth * 0.02, // 2% of image width
                                    right:
                                        imageWidth * 0.02, // 2% of image width
                                    child: AnimatedOpacity(
                                      duration: Duration(milliseconds: 300),
                                      opacity:
                                          _isHoveredList[index] ? 1.0 : 0.0,
                                      child: SvgPicture.asset(
                                        'assets/quickDetail.svg',
                                        width:
                                            imageWidth *
                                            0.95, // 95% of image width
                                        height:
                                            imageHeight *
                                            0.35, // 35% of image height
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 313 + 200,
              ), // Reserve space for sticky container + AboveFooter
            ],
          ),
        ],
      ),
    );
  }
}
