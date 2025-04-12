import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/above_footer.dart';
import 'gridview/grideview.dart';

class HomePageWeb extends StatefulWidget {
  const HomePageWeb({super.key});

  @override
  State<HomePageWeb> createState() => _HomePageWebState();
}

class _HomePageWebState extends State<HomePageWeb>
    with SingleTickerProviderStateMixin {
  // Track wishlist state
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Smooth transition over 3 seconds
    );

    _animation = Tween<double>(
      begin: 1.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(); // Start animation when page is loaded
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 313,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(
                        "assets/home_page/background.png",
                      ),
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
                          right: screenWidth * 0.06, // Responsive right padding
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // width: screenWidth * 0.20,
                                      child: customTextFormField(
                                        hintText: "YOUR NAME",
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      // width: screenWidth * 0.20,
                                      child: customTextFormField(
                                        hintText: "YOUR EMAIL",
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // width: screenWidth * 0.20,
                                      child: customTextFormField(
                                        hintText: "MESSAGE",
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      // width: screenWidth * 0.20,
                                      child: customTextFormField(hintText: ""),
                                    ),
                                    const SizedBox(height: 24),
                                    Align(
                                      alignment:
                                          Alignment
                                              .centerRight, // Aligns it to the left within the column
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left:
                                              screenWidth *
                                              0.0, // Adjust as needed for fine-tuning
                                          top:
                                              10, // Ensures spacing below the empty TextFormField
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/home_page/submit.svg",
                                          height: 20,
                                          width: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 30),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "LET'S CONNECT!",
                                      style: TextStyle(
                                        fontFamily: 'Cralika',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 28,
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
                              ClipRRect(
                                child: Container(
                                  width:
                                      screenWidth *
                                      0.8, // Set a fixed container size
                                  height: screenWidth * 0.27,
                                  clipBehavior:
                                      Clip.hardEdge, // Prevents overflow
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _animation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _animation.value,
                                        child: Image.asset(
                                          'assets/home_page/aquaCollection.png',
                                          width: screenWidth * 0.8,
                                          height: screenWidth * 0.27,
                                          fit:
                                              BoxFit
                                                  .cover, // Ensures image fills the container
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  width: screenWidth * 0.2,
                                  constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.2,
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
                            'assets/home_page/PanelTitle.svg',
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
              GridViewWeb(),
              const SizedBox(
                height: 313 + 200,
              ), // Reserve space for sticky container + AboveFooter
            ],
          ),
        ],
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
