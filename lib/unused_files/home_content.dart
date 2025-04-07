import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../web/component/auto_scroll.dart';

class HomeContentWeb extends StatefulWidget {
  const HomeContentWeb({super.key});

  @override
  State<HomeContentWeb> createState() => _HomeContentWebState();
}

class _HomeContentWebState extends State<HomeContentWeb> {
  final List<String> imagePaths = [
    "assets/dot.svg",

    "assets/@.svg",
    "assets/k.svg",
    "assets/i.svg",
    "assets/r.svg",
    "assets/e.svg",
    "assets/i.svg",

    "assets/m.svg",
    "assets/i.svg",

    "assets/c.svg",
    "assets/s.svg",
  ];
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  List<double> imageHeights = [
    16.0,
    70.0,
    90.0,
    67.0,
    70.0,
    72.0,
    67.0,
    70.0,
    67.0,
    72.0,
    72.0,
    16.0,
  ]; // match this list length to imagePaths

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 90),
                child: Transform.translate(
                  offset: const Offset(490, 0),
                  child: Stack(
                    children: [
                      Container(
                        height: 373,
                        width: 699,
                        decoration: const BoxDecoration(),
                        child: Image.asset(
                          'assets/aquaCollection.png',
                          height: 373,
                          width: 699,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          width: 282,
                          height: 120,
                          padding: const EdgeInsets.all(12),
                          color: Colors.white,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aqua Collection',
                                style: TextStyle(
                                  fontFamily: 'Cralika',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  height:
                                      36 /
                                      20, // line-height divided by font-size
                                  letterSpacing: 0.04 * 20, // 4% of font-size
                                  color: Color(0xFF0D2C54),
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text(
                                '4 Pieces',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.barlow().fontFamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.0, // 100% of font size
                                  letterSpacing: 0.0, // 0%
                                  color: Color(0xFF3E5B84),
                                ),
                              ),

                              const SizedBox(height: 14),
                              Text(
                                'VIEW',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.barlow().fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 1.0, // 100% of font size
                                  letterSpacing: 0.04 * 16, // 4% of 16px = 0.64
                                  color: Color(0xFF0D2C54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 42, left: 370),
                child: Container(
                  color: Colors.transparent,

                  height: 214,
                  width: 261,
                  child: SvgPicture.asset(
                    'assets/PanelTitle.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            child: Transform.translate(
              offset: const Offset(0, 680),

              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color(0xFF2472e3).withOpacity(0.9), // Adjust opacity here
                      BlendMode
                          .srcATop, // Try different modes like overlay, multiply, etc.
                    ),
                  ),
                ),
                height: 313,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 253, top: 100),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 302,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "YOUR NAME",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily:
                                          GoogleFonts.barlow()
                                              .fontFamily, // Make sure to include this font in pubspec.yaml
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),

                              SizedBox(
                                // height: 78,
                                width: 302,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "YOUR EMAIL",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily:
                                          GoogleFonts.barlow()
                                              .fontFamily, // Make sure to include this font in pubspec.yaml
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   width: 31,
                          // ),
                          SizedBox(width: 25),

                          Column(
                            // crossAxisAlignment:
                            //     CrossAxisAlignment
                            //         .center, // Align other children to the center
                            children: [
                              SizedBox(
                                height: 60,

                                width: 302,

                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "YOUR MESSAGE",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily:
                                          GoogleFonts.barlow()
                                              .fontFamily, // Make sure to include this font in pubspec.yaml
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),

                              SizedBox(
                                width: 302,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              // SizedBox(height: 20), // Add spacing before aligning the image
                              Container(
                                padding: EdgeInsets.only(left: 250, top: 20),
                                // width: 302, // Adjust width if needed
                                child: SvgPicture.asset(
                                  "assets/submit.svg",
                                  height: 19,
                                  width: 58,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 40),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start, // Aligns text to start

                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 10),

                                // width: 270,
                                child: Text(
                                  "LET'S CONNECT!",
                                  style: TextStyle(
                                    fontFamily: 'Cralika',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 32,
                                    letterSpacing: 0.04 * 32,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // SizedBox(height: 4.0),
                              SizedBox(
                                width: 250,
                                child: Text(
                                  "Looking for gifting options, or want to get a piece commissioned?\nLet's connect and create something wonderful!",
                                  // textAlign:
                                  //     TextAlign.left, // Aligns to start
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w200,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -290),

                  child: Padding(
                    padding: const EdgeInsets.only(left: 252),
                    child: Container(
                      // color: Colors.black,
                      height: 707,
                      width: 938,
                      child: SingleChildScrollView(
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
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Image.asset(
                                  'assets/gridview_img.jpeg',
                                  height: 342,
                                  width: 297,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 14,
                                  left: 14,
                                  right: 14,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SvgPicture.asset(
                                        index == 1
                                            ? 'assets/off.svg'
                                            : 'assets/fewPiecesLeft.svg',
                                        width: 149,
                                        height: 32,
                                      ),
                                      SvgPicture.asset(
                                        index == 1
                                            ? 'assets/IconWishlist.svg'
                                            : 'assets/IconWishlistEmpty.svg',
                                        width: 33.99,
                                        height: 19.33,
                                      ),
                                    ],
                                  ),
                                ),
                                if (index == 1)
                                  Positioned(
                                    bottom: 2,
                                    left: 8,
                                    // right: 12,
                                    child: SvgPicture.asset(
                                      'assets/quickDetail.svg',
                                      width: 282,
                                      height: 120,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 166,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Follow The Journey",
                      style: TextStyle(
                        fontFamily: 'Cralika',
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        height: 36 / 32,
                        letterSpacing: 0.04 * 32,
                        color: Color(0xFF3E5B84),
                      ),
                    ),
                    SizedBox(width: 8),
                    Image.asset("assets/instag.png", height: 31, width: 31),
                  ],
                ),
                SizedBox(height: 25), // spacing between rows
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: AutoScrollImagesWeb(
                          imagePaths: imagePaths,
                          imageHeights: imageHeights,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
