import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/product_details/product_details_controller.dart';
import '../../component/routes.dart';

class Gridview extends StatefulWidget {
  const Gridview({super.key});

  @override
  State<Gridview> createState() => _GridviewState();
}

class _GridviewState extends State<Gridview> {
  final ProductController controller = Get.put(ProductController());

  final List<bool> _wishlistStates = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
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

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 5,
                childAspectRatio: 0.50,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final product =
                    controller.products[index]; // Get the current product
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 196,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.go(AppRoutes.productDetails(product.id));
                            },
                            child: Image.network(
                              height: 196,
                              width: 170,
                              product.thumbnail,
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
                                ElevatedButton(
                                  onPressed: null, // Disable the button
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
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
                                      fontFamily:
                                          GoogleFonts.barlow().fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.48,
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
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name, // Use product name
                              style: const TextStyle(
                                fontFamily: "Cralika",
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                height: 1.2,
                                letterSpacing: 0.64,
                                color: Color(0xFF3E5B84),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Rs. ${product.price}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.barlow(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.2,
                                color: const Color(0xFF3E5B84),
                              ),
                            ),
                            const SizedBox(height: 8),

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
        );
      }),
    );
  }
}
