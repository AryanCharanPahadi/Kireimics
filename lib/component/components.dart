import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

class ScrollingHeader extends StatelessWidget {
  const ScrollingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: const Color(0xFF3E5B84),
      child: Marquee(
        text: '✦ Free shipping pan-India for orders above Rs. 2000    ',
        style: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.barlow().fontFamily,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          fontSize: 14,
          height: 1.0,
          letterSpacing: 0.0,
        ),
        scrollAxis: Axis.horizontal,
        blankSpace: 160.0,
        velocity: 50.0,
        pauseAfterRound: const Duration(seconds: 0),
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 99,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              // color: Colors.red,
              height: 51.49,
              width: 211,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Image.asset(
                  'assets/fullLogoNew.png',
                  height: 31,
                  width: 191,
                ),
              ),
            ),
            SizedBox(
              width: 192,
              height: 24.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/IconSearch.svg', // Ensure the correct path
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/IconWishlist.svg', // Ensure the correct path
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/IconProfile.svg', // Ensure the correct path
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/IconCart.svg', // Ensure the correct path
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        height: 320,
        child: Stack(
          children: [
            Positioned(
              left: 57,
              bottom: 40,
              child: SvgPicture.asset(
                'assets/footerbg.svg',
                height: 258,
                width: 254,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  Color(0xFFDDEAFF),
                  BlendMode.srcIn,
                ),
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80, left: 21, right: 18),
                  child: Divider(color: Color(0xFF3E5B84), thickness: 1),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 21, top: 50),
                              child: Container(
                                height: 101,
                                width: 150,
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Shipping Policy",
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 1.0,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 1.0,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Contact",
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 1.0,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 35,
                              width: 217,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.grey[50], // Light background
                                  elevation: 0, // No shadow
                                  side: BorderSide(
                                    color: Colors.grey[300]!,
                                  ), // Lighter border color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // Optional rounded corners
                                  ),
                                ),

                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Handmade",
                                        style: TextStyle(
                                          fontFamily: 'Cralika',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          letterSpacing: 0.04,
                                          color: Color(0xFF3e5b84),
                                        ),
                                      ),

                                      TextSpan(
                                        text: "with",
                                        style: TextStyle(
                                          fontFamily: 'Cralika',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          letterSpacing: 0.04,
                                          color: Color(0xFF5a8acf),
                                        ),
                                      ),
                                      TextSpan(
                                        text: "love",
                                        style: TextStyle(
                                          fontFamily: 'Cralika',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          letterSpacing: 0.04,
                                          color: Color(0xFF94c0ff),
                                        ),
                                      ),
                                      TextSpan(
                                        text: "🩵",
                                        style: TextStyle(
                                          fontFamily: 'Cralika',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          letterSpacing: 0.04,
                                          // color: Color(0xFF94c0ff),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 21),
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 114,
                                width: 460,
                                child: Text(
                                  '"Kireimics" began as a passion project combining handmade pottery with a deep love for animals. Each piece we create carries dedication, creativity, and soul. Our mission extends beyond crafting beautiful pottery—we\'re committed to helping community strays. A majority of proceeds from every sale goes directly to animal organizations and charities.',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                    color: Color(0xFF414141),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 35,
                                width: 217,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  "Copyright Kireimics 2025",
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                    color: Color(0xFF979797),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatefulWidget {
  final List<String> sidebarItems;
  final String selectedItem;
  final Function(String) onItemSelected;

  const Sidebar({
    super.key,
    required this.sidebarItems,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 44,
      // top: 155, // Header height (32 + 99) + some padding
      child: Padding(
        padding: const EdgeInsets.only(left: 44, top: 155),
        child: Container(
          width: 150,
          height: 210.0,
          // margin: const EdgeInsets.only(left: 44, top: 24),
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...widget.sidebarItems.map((item) {
                      bool isSelected = item == widget.selectedItem;
                      return GestureDetector(
                        onTap: () {
                          widget.onItemSelected(item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            item.toUpperCase(),
                            style: TextStyle(
                              fontFamily: GoogleFonts.barlow().fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.0,
                              letterSpacing: 1.5,

                              // Set text color based on conditions
                              color:
                                  item == "SALE"
                                      ? const Color(
                                        0xFFF46856,
                                      ) // Always red for SALE
                                      : const Color(
                                        0xFF3E5B84,
                                      ), // Blue for non-SALE
                              // Set background only if selected and not SALE
                              background:
                                  item != "SALE" && isSelected
                                      ? (Paint()
                                        ..color = const Color(
                                          0xFFd3e4fd,
                                        ) // Yellow background when selected
                                        ..style = PaintingStyle.fill)
                                      : null, // Transparent background when not selected or is SALE
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 22),
                    const Divider(color: Color(0xFF3E5B84), thickness: 1),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: SvgPicture.asset(
                      'assets/instagram.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: SvgPicture.asset(
                      'assets/email.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Transform.translate(
                  offset: const Offset(491, -20),
                  child: Padding(
                    padding: const EdgeInsets.only(top:20),
                    child: Stack(
                      children: [
                        Container(
                          height: 373,
                          width: 699,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/aquaCollection.png'),
                              fit: BoxFit.cover,
                            ),
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
                                    letterSpacing:
                                        0.04 * 16, // 4% of 16px = 0.64
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
                Positioned(
                  left: 282,
                  top: 173,
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
                        Color(
                          0xFF2472e3,
                        ).withOpacity(0.9), // Adjust opacity here
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
                                      fontFamily:
                                          GoogleFonts.barlow().fontFamily,
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
                      child: SizedBox(
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
                            itemCount: 6,
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
                          child: _AutoScrollImages(
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
      ],
    );
  }
}

class _AutoScrollImages extends StatefulWidget {
  final List<String> imagePaths;
  final List<double> imageHeights;

  const _AutoScrollImages({
    required this.imagePaths,
    required this.imageHeights,
  });

  @override
  State<_AutoScrollImages> createState() => _AutoScrollImagesState();
}

class _AutoScrollImagesState extends State<_AutoScrollImages> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_scrollController.hasClients) {
        _scrollPosition += 1.0; // change this to control speed
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0.0;
        }
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.imagePaths.length * 3, // Repeat 3x
      itemBuilder: (context, index) {
        int actualIndex = index % widget.imagePaths.length;
        bool isLastInLoop = actualIndex == widget.imagePaths.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 8,
              ), // Small space between all images
              child: SvgPicture.asset(
                widget.imagePaths[actualIndex],
                height: widget.imageHeights[actualIndex],
                fit: BoxFit.contain,
              ),
            ),
            if (isLastInLoop)
              const SizedBox(width: 15), // Larger space after a full cycle
          ],
        );
      },
    );
  }
}
