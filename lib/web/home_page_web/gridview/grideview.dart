import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/custom_text.dart';
import 'package:kireimics/web/product_view/product_details_web.dart';
import '../../../component/product_details/product_details_controller.dart';
import '../../../component/routes.dart';
import 'animation_gridview.dart';

class GridViewWeb extends StatefulWidget {
  const GridViewWeb({super.key});

  @override
  State<GridViewWeb> createState() => _GridViewWebState();
}

class _GridViewWebState extends State<GridViewWeb> {
  final ProductController controller = Get.put(ProductController());

  final List<bool> _isHoveredList = List.generate(
    6,
    (_) => false,
  ); // Track hover state for each item
  final List<bool> _wishlistStates = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.07, // 7% of screen width
          left: 292,
          top: 30,
        ),

        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text("Error: ${controller.errorMessage}"));
          }

          if (controller.products.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 23,
              mainAxisSpacing: 23,
              childAspectRatio: 0.9,
            ),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product =
                  controller.products[index]; // Get the current product

              return MouseRegion(
                onEnter: (_) => setState(() => _isHoveredList[index] = true),
                onExit: (_) => setState(() => _isHoveredList[index] = false),
                child: GestureDetector(
                  onTap: () {
                    context.go(AppRoutes.productDetails(product.id));
                  },


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
                              child: ClipRect(
                                child: AnimatedZoomImage(
                                  imageUrl: product.thumbnail,
                                ),
                              ),
                            ),

                            Positioned(
                              top: imageHeight * 0.04,
                              left: imageWidth * 0.05,
                              right: imageWidth * 0.05,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: null, // Disable the button
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: imageHeight * 0.025,
                                        horizontal: imageWidth * 0.08,
                                      ),
                                      backgroundColor: const Color(
                                        0xFFF46856,
                                      ), // Keep the same color when disabled
                                      disabledBackgroundColor: const Color(
                                        0xFFF46856,
                                      ),
                                      disabledForegroundColor: Colors.white,
                                      elevation: 0,
                                      side: BorderSide.none,
                                    ),
                                    child: Text(
                                      "${product.discount}% OFF",
                                      style: TextStyle(
                                        fontSize: imageWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                                      width: imageWidth * 0.10,
                                      height: imageHeight * 0.05,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: imageHeight * 0.02, // 2% of image height
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CralikaFont(
                                        text: product.name, // Use product name

                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,

                                        fontSize:
                                            imageWidth *
                                            0.05, // Responsive font size
                                        lineHeight: 1.2, // Line height
                                        letterSpacing: imageWidth * 0.002,
                                      ), // Responsive letter spacing),
                                      SizedBox(
                                        height: imageHeight * 0.03,
                                      ), // Responsive spacing

                                      BarlowText(
                                        text: "Rs. ${product.price}",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            imageWidth *
                                            0.040, // Responsive font size
                                        lineHeight: 1.0,
                                      ),
                                      SizedBox(height: imageHeight * 0.03),
                                      Row(
                                        children: [
                                          BarlowText(
                                            text: "VIEW",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                imageWidth *
                                                0.040, // Responsive font size
                                            lineHeight: 1.0,
                                          ),
                                          SizedBox(width: imageWidth * 0.02),
                                          BarlowText(
                                            text: " / ",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                imageWidth *
                                                0.040, // Responsive font size
                                            lineHeight: 1.0,
                                          ),
                                          SizedBox(width: imageWidth * 0.02),

                                          GestureDetector(
                                            onTap:
                                                () => print(
                                                  "Add to cart ${product.name}",
                                                ),
                                            child: BarlowText(
                                              text: "ADD TO CART",
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  imageWidth *
                                                  0.040, // Responsive font size
                                              lineHeight: 1.0,
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
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
