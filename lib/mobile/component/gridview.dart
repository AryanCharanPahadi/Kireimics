import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/product_details/product_details_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';

class Gridview extends StatefulWidget {

  final Function(String)? onWishlistChanged; // Callback to notify parent
  const Gridview({super.key, this.onWishlistChanged});
  @override
  State<Gridview> createState() => _GridviewState();
}

class _GridviewState extends State<Gridview> {
  final ProductController controller = Get.put(ProductController());

  List<bool> _isHoveredList = [];
  List<bool> _wishlistStates = [];

  void _initializeStates(int count) {
    if (_isHoveredList.length != count) {
      _isHoveredList = List.filled(count, false);
    }
    if (_wishlistStates.length != count) {
      _wishlistStates = List.filled(count, false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize wishlist states when widget loads
    _initializeWishlistStates();
  }

  Future<void> _initializeWishlistStates() async {
    // This will be called after products are loaded
    if (mounted) setState(() {});
  }

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

        if (controller.products.isNotEmpty) {
          _initializeStates(
            controller.products.length,
          ); // ← add this only once here
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
                              product.thumbnail,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    backgroundColor: const Color(0xFFF46856),
                                    disabledBackgroundColor: const Color(
                                      0xFFF46856,
                                    ),
                                    disabledForegroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "${product.discount}% OFF",
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.barlow().fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                                  child: FutureBuilder<bool>(
                                    future:
                                    SharedPreferencesHelper.isInWishlist(
                                      product.id.toString(),
                                    ),
                                    builder: (context, snapshot) {
                                      final isInWishlist =
                                          snapshot.data ?? false;
                                      return GestureDetector(
                                        onTap: () async {
                                          if (isInWishlist) {
                                            await SharedPreferencesHelper.removeFromWishlist(
                                              product.id.toString(),
                                            );
                                            widget.onWishlistChanged
                                                ?.call(
                                              'Product Removed From Wishlist',
                                            );
                                          } else {
                                            await SharedPreferencesHelper.addToWishlist(
                                              product.id.toString(),
                                            );
                                            widget.onWishlistChanged?.call(
                                              'Product Added To Wishlist',
                                            ); // Trigger notification
                                          }
                                          setState(() {});
                                        },
                                        child: SvgPicture.asset(
                                          isInWishlist
                                              ? 'assets/home_page/IconWishlist.svg'
                                              : 'assets/home_page/IconWishlistEmpty.svg',
                                          width: 24,
                                          height: 20,
                                        ),
                                      );
                                    },
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
                                color: Color(0xFF30578E),
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
                                color: const Color(0xFF30578E),
                              ),
                            ),
                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () {
                                context.go(AppRoutes.cartDetails(product.id));
                              },
                              child: Text(
                                "ADD TO CART",
                                style: GoogleFonts.barlow(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.2,
                                  letterSpacing: 0.56,
                                  color: const Color(0xFF30578E),
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
        );
      }),
    );
  }
}
