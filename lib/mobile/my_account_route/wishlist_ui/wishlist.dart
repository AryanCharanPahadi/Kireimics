import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/no_result_found/no_order_yet.dart';
import '../../../component/api_helper/api_helper.dart';
import '../../../component/cart_length/cart_loader.dart';
import '../../../component/no_result_found/no_result_found.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/product_details/product_details_modal.dart';
import '../../../component/app_routes/routes.dart' show AppRoutes;
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../../web_desktop_common/notify_me/notify_me.dart';

class WishlistUiMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Updated callback

  const WishlistUiMobile({super.key, this.onWishlistChanged});
  @override
  State<WishlistUiMobile> createState() => _WishlistUiMobileState();
}

class _WishlistUiMobileState extends State<WishlistUiMobile> {
  List<Product> productList = [];
  bool isLoading = true;
  String errorMessage = "";
  final List<bool> _isHoveredList = [];
  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

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
        final int? productId = int.tryParse(id);
        if (productId != null) {
          final product = await ApiHelper.fetchProductDetailsById(productId);
          if (product != null) {
            fetchedProducts.add(product);
          }
        }
      }

      setState(() {
        productList = fetchedProducts;
        _isHoveredList.clear();
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
      widget.onWishlistChanged?.call('Product Removed From Wishlist');
      // Immediately remove the product from productList to update GridView
      setState(() {
        final index = productList.indexWhere(
          (p) => p.id.toString() == productId,
        );
        if (index != -1) {
          productList.removeAt(index);
          _isHoveredList.removeAt(index);
        }
      });
    } else {
      await SharedPreferencesHelper.addToWishlist(productId);
      widget.onWishlistChanged?.call('Product Added To Wishlist');
      // Fetch and add the product to the list if needed
      final int? productIdInt = int.tryParse(productId);
      if (productIdInt != null) {
        final product = await ApiHelper.fetchProductDetailsById(productIdInt);
        if (product != null) {
          setState(() {
            productList.add(product);
            _isHoveredList.add(false);
          });
        }
      }
    }
  }

  Future<int?> fetchStockQuantity(String productId) async {
    try {
      var result = await ApiHelper.getStockDetail(productId);
      if (result['error'] == false && result['data'] != null) {
        for (var stock in result['data']) {
          if (stock['product_id'].toString() == productId) {
            return stock['quantity'];
          }
        }
      }
      return null;
    } catch (e) {
      print("Error fetching stock: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
      );
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
                      color: const Color(0xFF30578E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      route: AppRoutes.myAccount,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF30578E),
                      onTap: () {
                        context.go(AppRoutes.myAccount);
                      },
                    ),
                    const SizedBox(width: 32),
                    BarlowText(
                      text: "My Orders",
                      color: const Color(0xFF30578E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.myOrder,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF30578E),
                      onTap: () {
                        context.go(AppRoutes.myOrder);
                      },
                    ),
                    const SizedBox(width: 32),
                    BarlowText(
                      text: "Wishlist",
                      color: const Color(0xFF30578E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.wishlist,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF30578E),
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
                        child: CartEmpty(
                          cralikaText: "No product added!",
                          barlowText:
                              "Browse our catalog and heart the items you like! They will appear here.",
                        ),
                      )
                    else
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 24,
                                mainAxisSpacing:
                                    24, // Increased vertical spacing
                                childAspectRatio: () {
                                  double width =
                                      MediaQuery.of(context).size.width;
                                  if (width > 320 && width <= 410) {
                                    return 0.48;
                                  } else if (width > 410 && width <= 500) {
                                    return 0.53;
                                  } else if (width > 500 && width <= 600) {
                                    return 0.56;
                                  } else if (width > 600 && width <= 700) {
                                    return 0.62;
                                  } else if (width > 700 && width <= 800) {
                                    return 0.65;
                                  } else {
                                    return 0.50;
                                  }
                                }(),
                              ),
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            final product = productList[index];
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final imageWidth = (screenWidth / 2) - 24;
                            final imageHeight = imageWidth * 1.2;
                            final maxWidth = 800;
                            final cappedWidth =
                                screenWidth > maxWidth
                                    ? (maxWidth / 2) - 24
                                    : imageWidth;
                            final cappedHeight =
                                screenWidth > maxWidth
                                    ? ((maxWidth / 2) - 24) * 1.2
                                    : imageHeight;

                            return FutureBuilder<int?>(
                              future: fetchStockQuantity(product.id.toString()),
                              builder: (context, snapshot) {
                                final quantity = snapshot.data;
                                final isOutOfStock = quantity == 0;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: cappedWidth,
                                      height: cappedHeight,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: GestureDetector(
                                              onTap: () {
                                                context.go(
                                                  AppRoutes.productDetails(
                                                    product.id,
                                                  ),
                                                );
                                              },
                                              child: ColorFiltered(
                                                colorFilter:
                                                    isOutOfStock
                                                        ? const ColorFilter.matrix(
                                                          [
                                                            0.2126,
                                                            0.7152,
                                                            0.0722,
                                                            0,
                                                            0,
                                                            0.2126,
                                                            0.7152,
                                                            0.0722,
                                                            0,
                                                            0,
                                                            0.2126,
                                                            0.7152,
                                                            0.0722,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            1,
                                                            0,
                                                          ],
                                                        )
                                                        : const ColorFilter.mode(
                                                          Colors.transparent,
                                                          BlendMode.multiply,
                                                        ),
                                                child: Image.network(
                                                  product.thumbnail,
                                                  width: cappedWidth,
                                                  height: cappedHeight,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            top: 10,
                                            left: 10,
                                            right: 10,
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                bool isMobile =
                                                    constraints.maxWidth < 800;
                                                if (isOutOfStock) {
                                                  // Only show out-of-stock image and wishlist icon
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment
                                                                .centerLeft,
                                                        child: SvgPicture.asset(
                                                          "assets/home_page/outofstock.svg",
                                                          height: 24,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment
                                                                .centerRight,
                                                        child: FutureBuilder<
                                                          bool
                                                        >(
                                                          future:
                                                              SharedPreferencesHelper.isInWishlist(
                                                                product.id
                                                                    .toString(),
                                                              ),
                                                          builder: (
                                                            context,
                                                            snapshot,
                                                          ) {
                                                            final isInWishlist =
                                                                snapshot.data ??
                                                                false;
                                                            return GestureDetector(
                                                              onTap: () {
                                                                toggleWishlist(
                                                                  product.id
                                                                      .toString(),
                                                                );
                                                              },
                                                              child: SvgPicture.asset(
                                                                isInWishlist
                                                                    ? 'assets/home_page/IconWishlist.svg'
                                                                    : 'assets/home_page/IconWishlistEmpty.svg',
                                                                width:
                                                                    isMobile
                                                                        ? 20
                                                                        : 24,
                                                                height:
                                                                    isMobile
                                                                        ? 18
                                                                        : 20,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }

                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // First badge (maker_choice)
                                                        if (product
                                                                .isMakerChoice ==
                                                            1)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 2,
                                                                ), // manual top offset to align
                                                            child: SvgPicture.asset(
                                                              "assets/home_page/maker_choice.svg",
                                                              height: 40,
                                                              fit:
                                                                  BoxFit
                                                                      .contain,
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                            ),
                                                          ),
                                                        if (product.isMakerChoice ==
                                                                1 &&
                                                            product.discount !=
                                                                0)
                                                          const SizedBox(
                                                            height: 5,
                                                          ), // <-- This adds the 5px gap between badges
                                                        if (product.discount !=
                                                            0)
                                                          Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  top: 2,
                                                                ),
                                                            height: 32,
                                                            width: 80,
                                                            child: ElevatedButton(
                                                              onPressed: () {},
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                      0xFFF46856,
                                                                    ),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                elevation: 0,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        79,
                                                                      ),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                "${product.discount}% OFF",
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      GoogleFonts.barlow()
                                                                          .fontFamily,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      0.65,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 5,
                                                          ),
                                                      child: FutureBuilder<
                                                        bool
                                                      >(
                                                        future:
                                                            SharedPreferencesHelper.isInWishlist(
                                                              product.id
                                                                  .toString(),
                                                            ),
                                                        builder: (
                                                          context,
                                                          snapshot,
                                                        ) {
                                                          final isInWishlist =
                                                              snapshot.data ??
                                                              false;
                                                          return GestureDetector(
                                                            onTap: () {
                                                              toggleWishlist(
                                                                product.id
                                                                    .toString(),
                                                              );
                                                            },
                                                            child: SvgPicture.asset(
                                                              isInWishlist
                                                                  ? 'assets/home_page/IconWishlist.svg'
                                                                  : 'assets/home_page/IconWishlistEmpty.svg',
                                                              width:
                                                                  isMobile
                                                                      ? 20
                                                                      : 24,
                                                              height:
                                                                  isMobile
                                                                      ? 18
                                                                      : 20,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CralikaFont(
                                            text: product.name,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            lineHeight: 1.2,
                                            letterSpacing: 0.64,
                                            color: Color(0xFF30578E),
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 8),
                                          if (!isOutOfStock) ...[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                // Original price with strikethrough
                                                if (product.discount != 0)
                                                  Text(
                                                    "Rs. ${product.price.toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                      color: Color(
                                                        0xFF30578E,
                                                      ).withOpacity(0.7),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      height: 1.2,
                                                      decoration:
                                                          TextDecoration
                                                              .lineThrough,
                                                      decorationColor: Color(
                                                        0xFF30578E,
                                                      ).withOpacity(0.7),
                                                      fontFamily:
                                                          GoogleFonts.barlow()
                                                              .fontFamily,
                                                    ),
                                                  ),

                                                // Vertical divider
                                                if (product.discount != 0)
                                                  SizedBox(width: 6),
                                                // Discounted price
                                                BarlowText(
                                                  text:
                                                      product.discount != 0
                                                          ? "Rs. ${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}"
                                                          : "Rs. ${product.price.toStringAsFixed(2)}",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  lineHeight: 1.2,
                                                  color: const Color(
                                                    0xFF30578E,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],

                                          if (isOutOfStock) ...[
                                            BarlowText(
                                              text:
                                                  "Rs. ${product.price.toStringAsFixed(2)}",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              lineHeight: 1.2,
                                              color: const Color(0xFF30578E),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap:
                                                isOutOfStock
                                                    ? null
                                                    : () async {
                                                      widget.onWishlistChanged
                                                          ?.call(
                                                            'Product Added To Cart',
                                                          );
                                                      await SharedPreferencesHelper.addProductId(
                                                        product.id,
                                                      );
                                                      cartNotifier.refresh();
                                                    },
                                            child:
                                                isOutOfStock
                                                    ? NotifyMeButton(
                                                      productId: product.id,
                                                      onWishlistChanged:
                                                          widget
                                                              .onWishlistChanged,
                                                      onErrorWishlistChanged: (
                                                        error,
                                                      ) {
                                                        widget.onWishlistChanged
                                                            ?.call(error);
                                                      },
                                                    )
                                                    : BarlowText(
                                                      text: "ADD TO CART",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      lineHeight: 1.0,
                                                      letterSpacing: 0.56,
                                                      color: const Color(
                                                        0xFF30578E,
                                                      ),
                                                    ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
