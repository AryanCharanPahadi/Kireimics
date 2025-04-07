import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/custom_text.dart';
import 'package:kireimics/web/component/above_footer.dart';

import '../../component/categories/categories_controller.dart';
import '../../component/routes.dart';

class CatalogWeb extends StatefulWidget {
  const CatalogWeb({super.key});

  @override
  State<CatalogWeb> createState() => _CatalogWebState();
}

class _CatalogWebState extends State<CatalogWeb> {
  final List<bool> _isHoveredList = List.generate(
    9,
    (_) => false,
  ); // Track hover state for each item
  final List<bool> _wishlistStates = List.filled(9, false);

  final CatalogController categoriesController = Get.put(CatalogController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            // height: 142,
            child: Padding(
              padding: const EdgeInsets.only(left: 453),
              child: Container(
                // color: Colors.yellow,
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
                  padding: const EdgeInsets.only(
                    top: 41,
                    right: 90,
                    left: 46,
                    bottom: 41,
                  ),
                  child: BarlowText(
                    text:
                        "/A wide range of handmade pottery that's designed to be fun & functional. Each piece is unique, original and perfect for adding charm to any space/",
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            // height: 142,
            child: Padding(
              padding: const EdgeInsets.only(left: 292),
              child: Container(
                // color: Colors.green,
                child: CralikaFont(
                  text: "24 Products",
                  fontWeight: FontWeight.w400,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            // height: 142,
            child: Padding(
              padding: EdgeInsets.only(
                left: 292,
                right: MediaQuery.of(context).size.width * 0.07,
              ), // 7% of screen width),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Obx(() {
                    if (categoriesController.isLoading.value) {
                      return const CircularProgressIndicator();
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                          categoriesController.categories.map((category) {
                            final name = category['name'] as String;
                            final id = category['id'] as int;

                            return Padding(
                              padding: const EdgeInsets.only(right: 32),
                              child: BarlowText(
                                text: name,
                                color: const Color(0xFF3E5B84),
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.012,
                                lineHeight: 1.0,
                                letterSpacing: 0.04 * 16,
                                route: AppRoutes.collection,

                                enableUnderlineForActiveRoute:
                                    name == "Collections",
                                decorationColor: const Color(0xFF3E5B84),
                                onTap: () {
                                  if (name == "Collections") {
                                    context.go(AppRoutes.collection);
                                  } else {
                                    print('Tapped: $name (ID: $id)');
                                    // You can add other logic here for other categories
                                  }
                                },
                              ),
                            );
                          }).toList(),
                    );
                  }),
                  Row(
                    // color: Colors.green,
                    children: [
                      BarlowText(
                        text: "Sort / New",
                        color: Color(0xFF3E5B84),
                        fontWeight: FontWeight.w600, // font-weight: 600
                        fontSize:
                            MediaQuery.of(context).size.width *
                            0.012, // Responsive font size
                        lineHeight: 1.0, // line-height: 100%
                        letterSpacing:
                            0.04 * 16, // letter-spacing: 4% of font size
                      ),
                      SizedBox(width: 24),

                      BarlowText(
                        text: "Filter / All",
                        color: Color(0xFF3E5B84),
                        fontWeight: FontWeight.w600, // font-weight: 600
                        fontSize:
                            MediaQuery.of(context).size.width *
                            0.012, // Responsive font size
                        lineHeight: 1.0, // line-height: 100%
                        letterSpacing:
                            0.04 * 16, // letter-spacing: 4% of font size
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 23,
                  mainAxisSpacing: 23,
                  childAspectRatio: 0.9,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return MouseRegion(
                    onEnter:
                        (_) => setState(() => _isHoveredList[index] = true),
                    onExit:
                        (_) => setState(() => _isHoveredList[index] = false),
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
                                  'assets/home_page/gridview_img.jpeg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: imageHeight * 0.04, // 4% of image height
                                left: imageWidth * 0.05, // 5% of image width
                                right: imageWidth * 0.05, // 5% of image width
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Define your onPressed functionality here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical:
                                              imageHeight *
                                              0.025, // Adjusts dynamically
                                          horizontal:
                                              imageWidth *
                                              0.08, // Adjusts dynamically
                                        ),
                                        backgroundColor:
                                            index == 1
                                                ? Color(0xFFF46856)
                                                : Colors
                                                    .white, // White background for "Few Pieces Left"
                                        elevation: 0,
                                        side:
                                            index == 1
                                                ? BorderSide
                                                    .none // No border for "50% OFF"
                                                : BorderSide(
                                                  color: Color(0xFFF46856),
                                                  width: 1,
                                                ), // Red border for "Few Pieces Left"
                                      ),
                                      child: Text(
                                        index == 1
                                            ? '50% OFF'
                                            : 'Few Pieces Left',
                                        style: TextStyle(
                                          fontSize:
                                              imageWidth *
                                              0.04, // Adjusts font size dynamically
                                          fontWeight: FontWeight.bold,
                                          color:
                                              index == 1
                                                  ? Colors.white
                                                  : Color(0xFFF46856),
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
                                            ? 'assets/home_page/IconWishlist.svg'
                                            : 'assets/home_page/IconWishlistEmpty.svg',
                                        width:
                                            imageWidth *
                                            0.10, // 12% of image width
                                        height:
                                            imageHeight *
                                            0.05, // 6% of image height
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom:
                                    imageHeight * 0.02, // 2% of image height
                                left: imageWidth * 0.02, // 2% of image width
                                right: imageWidth * 0.02, // 2% of image width
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: _isHoveredList[index] ? 1.0 : 0.0,
                                  child: Container(
                                    width: imageWidth * 0.95,
                                    height: imageHeight * 0.35,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          imageWidth * 0.05, // 5% of width
                                      vertical:
                                          imageHeight * 0.02, // 2% of height
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        0xFF3E5B84,
                                      ).withOpacity(0.8), // 50% opacity
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Checkered Trinket Dish",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Cralika',
                                            fontWeight: FontWeight.w400,
                                            fontSize:
                                                imageWidth *
                                                0.05, // Responsive font size
                                            height: 1.2, // Line height
                                            letterSpacing:
                                                imageWidth *
                                                0.002, // Responsive letter spacing
                                          ),
                                        ),
                                        SizedBox(
                                          height: imageHeight * 0.04,
                                        ), // Responsive spacing
                                        Text(
                                          "Rs. 500.00",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize:
                                                imageWidth *
                                                0.040, // Responsive font size
                                            height: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: imageHeight * 0.04),
                                        Row(
                                          children: [
                                            Text(
                                              "VIEW",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    GoogleFonts.barlow()
                                                        .fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    imageWidth *
                                                    0.040, // Responsive font size
                                                height: 1.0,
                                              ),
                                            ),
                                            SizedBox(width: imageWidth * 0.02),
                                            Text(
                                              "/",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    GoogleFonts.barlow()
                                                        .fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize: imageWidth * 0.040,
                                                height: 1.0,
                                              ),
                                            ),
                                            SizedBox(width: imageWidth * 0.02),
                                            Text(
                                              "ADD TO CART",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    GoogleFonts.barlow()
                                                        .fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    imageWidth *
                                                    0.040, // Responsive font size
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
