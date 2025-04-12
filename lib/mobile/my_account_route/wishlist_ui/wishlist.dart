import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/cart_loader.dart';
import '../../../component/custom_text.dart';
import '../../../component/product_details/product_details_modal.dart';
import '../../../component/routes.dart' show AppRoutes;
import '../../../component/shared_preferences.dart';
import '../../../web/cart/cart_panel.dart';
import '../../../web/home_page_web/gridview/animation_gridview.dart';

class WishlistUiMobile extends StatefulWidget {
  const WishlistUiMobile({super.key});

  @override
  State<WishlistUiMobile> createState() => _WishlistUiMobileState();
}

class _WishlistUiMobileState extends State<WishlistUiMobile> {
  List<Product> productList = [];
  bool isLoading = true;
  String errorMessage = "";
  final List<bool> _isHoveredList = [];

  @override
  void initState() {
    super.initState();
    initWishlist();
  }

  Future<void> initWishlist() async {
    try {
      List<String> storedIds = await SharedPreferencesHelper.getWishlist();
      List<Product> fetchedProducts = [];

      for (String id in storedIds) {
        // Convert the String ID to int before passing to fetchProductById
        final int? productId = int.tryParse(id);
        if (productId != null) {
          final product = await ApiHelper.fetchProductById(productId);
          if (product != null) {
            fetchedProducts.add(product);
          }
        }
      }

      setState(() {
        productList = fetchedProducts;
        _isHoveredList.addAll(List.filled(fetchedProducts.length, false));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load wishlist";
        isLoading = false;
      });
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final isInWishlist = await SharedPreferencesHelper.isInWishlist(productId);

    if (isInWishlist) {
      await SharedPreferencesHelper.removeFromWishlist(productId);
    } else {
      await SharedPreferencesHelper.addToWishlist(productId);
    }

    // Refresh the wishlist
    await initWishlist();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF3E5B84)));
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),

                CralikaFont(
                  text: "Wishlist",
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  lineHeight: 36 / 32,
                  letterSpacing: 1.28,
                  color: const Color(0xFF414141),
                ),
                const SizedBox(height: 13),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BarlowText(
                      text: "My Account",
                      color: const Color(0xFF3E5B84),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      route: AppRoutes.myAccount,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF3E5B84),
                      onTap: () {
                        context.go(AppRoutes.myAccount);
                      },
                    ),
                    const SizedBox(width: 32),

                    BarlowText(
                      text: "My Orders",
                      color: const Color(0xFF3E5B84),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.myOrder,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF3E5B84),
                      onTap: () {
                        context.go(AppRoutes.myOrder);
                      },
                    ),
                    const SizedBox(width: 32),

                    BarlowText(
                      text: "Wishlist",
                      color: const Color(0xFF3E5B84),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.wishlist,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF3E5B84),
                      onTap: () {
                        context.go(AppRoutes.wishlist);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CralikaFont(
                      text: "${productList.length} Items Added",
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      lineHeight: 36 / 32,
                      letterSpacing: 1.28,
                      color: const Color(0xFF414141),
                    ),
                    const SizedBox(height: 24),

                    if (productList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SvgPicture.asset("assets/icons/notFound.svg"),
                            SizedBox(height: 20),
                            CralikaFont(text: "No product added!"),
                            SizedBox(height: 10),
                            BarlowText(
                              text:
                                  "Browse our catalog and heart the items you like! They will appear here.",
                              fontSize: 18,
                              textAlign: TextAlign.center, // Add this line
                            ),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () {
                                context.go(AppRoutes.catalog);
                              },
                              child: BarlowText(
                                text: "BROWSE OUR CATALOG",
                                backgroundColor: Color(0xFFb9d6ff),
                                color: Color(0xFF3E5B84),
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: 0.48,
                                ),
                            itemCount: productList.length,
                            itemBuilder: (context, index) {
                              final product = productList[index];
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
                                            context.go(
                                              AppRoutes.productDetails(
                                                product.id,
                                              ),
                                            );
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: null,
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                  backgroundColor: const Color(
                                                    0xFFF46856,
                                                  ),
                                                  disabledBackgroundColor:
                                                      const Color(0xFFF46856),
                                                  disabledForegroundColor:
                                                      Colors.white,
                                                  elevation: 0,
                                                ),
                                                child: Text(
                                                  "${product.discount}% OFF",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        GoogleFonts.barlow()
                                                            .fontFamily,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.48,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  await toggleWishlist(
                                                    product.id.toString(),
                                                  );
                                                },
                                                child: SvgPicture.asset(
                                                  'assets/home_page/IconWishlist.svg',
                                                  width: 34,
                                                  height: 20,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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

                                          GestureDetector(
                                            onTap: () {
                                              context.go(
                                                AppRoutes.cartDetails(
                                                  product.id,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "ADD TO CART",
                                              style: GoogleFonts.barlow(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                height: 1.2,
                                                letterSpacing: 0.56,
                                                color: const Color(0xFF3E5B84),
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
