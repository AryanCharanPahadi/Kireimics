import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';

class GridviewSearch extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent

  const GridviewSearch({super.key, this.onWishlistChanged});

  @override
  State<GridviewSearch> createState() => _GridviewSearchState();
}

class _GridviewSearchState extends State<GridviewSearch> {
  final ProductController controller = Get.put(ProductController());
  List<bool> _isHoveredList = [];
  List<bool> _wishlistStates = [];
  String _currentQuery = '';
  bool _initialized = false;
  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentQuery =
              GoRouterState.of(context).uri.queryParameters['query'] ?? '';
          controller.resetFilter();
          controller.filterProducts(_currentQuery);
          _initialized = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      final newQuery =
          GoRouterState.of(context).uri.queryParameters['query'] ?? '';
      if (newQuery != _currentQuery) {
        setState(() {
          _currentQuery = newQuery;
        });
        controller.resetFilter();
        controller.filterProducts(_currentQuery);
      }
    }
  }

  void _initializeStates(int count) {
    if (_isHoveredList.length != count) {
      _isHoveredList = List.filled(count, false);
    }
    if (_wishlistStates.length != count) {
      _wishlistStates = List.filled(count, false);
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
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 14, right: 14),
      child: Obx(() {
        if (controller.isLoading.value && controller.filteredProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text("Error: ${controller.errorMessage}"));
        }

        final resultCount = controller.filteredProducts.length;
        final resultText =
            resultCount == 1 ? '1 Result' : '$resultCount Results';

        if (controller.filteredProducts.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CralikaFont(
                text: '"$_currentQuery"',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Color(0xFF414141),
              ),
              SizedBox(height: 8),
              BarlowText(
                text: resultText,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF414141),
              ),
              SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CartEmpty(
                  cralikaText: "No results found!",
                  barlowText:
                      "Looks like the product you're looking for is not available. Please try a different keyword, or check the spelling!",
                ),
              ),
            ],
          );
        }
        if (controller.filteredProducts.isNotEmpty) {
          _initializeStates(controller.filteredProducts.length);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CralikaFont(
              text: '"$_currentQuery"',
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Color(0xFF414141),
            ),
            SizedBox(height: 8),
            CralikaFont(
              text: resultText,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0xFF414141),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24, // Increased vertical spacing
                  childAspectRatio: () {
                    double width = MediaQuery.of(context).size.width;
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
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final imageWidth = (screenWidth / 2) - 24;
                  final imageHeight = imageWidth * 1.2;
                  final maxWidth = 800;
                  final cappedWidth =
                      screenWidth > maxWidth ? (maxWidth / 2) - 24 : imageWidth;
                  final cappedHeight =
                      screenWidth > maxWidth
                          ? ((maxWidth / 2) - 24) * 1.2
                          : imageHeight;
                  final product = controller.filteredProducts[index];

                  return FutureBuilder<int?>(
                    future: fetchStockQuantity(product.id.toString()),
                    builder: (context, snapshot) {
                      final quantity = snapshot.data;
                      final isOutOfStock = quantity == 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
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
                                        AppRoutes.productDetails(product.id),
                                      );
                                    },
                                    child: ColorFiltered(
                                      colorFilter:
                                          isOutOfStock
                                              ? const ColorFilter.matrix([
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
                                              ])
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: SvgPicture.asset(
                                                "assets/home_page/outofstock.svg",
                                                height: 24,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
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
                                                        widget.onWishlistChanged
                                                            ?.call(
                                                              'Product Added To Wishlist',
                                                            );
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: SvgPicture.asset(
                                                      isInWishlist
                                                          ? 'assets/home_page/IconWishlist.svg'
                                                          : 'assets/home_page/IconWishlistEmpty.svg',
                                                      width: isMobile ? 20 : 24,
                                                      height:
                                                          isMobile ? 18 : 20,
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
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              final List<Widget> badges = [];

                                              if (product.isMakerChoice == 1) {
                                                badges.add(
                                                  SvgPicture.asset(
                                                    "assets/home_page/maker_choice.svg",
                                                    height: isMobile ? 40 : 32,
                                                  ),
                                                );
                                              }

                                              if (quantity != null &&
                                                  quantity < 2) {
                                                if (badges.isNotEmpty)
                                                  badges.add(
                                                    SizedBox(height: 10),
                                                  );
                                                badges.add(
                                                  ElevatedButton(
                                                    onPressed:
                                                        () {}, // Replace with your logic
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                      Colors
                                                          .white,
                                                      foregroundColor:
                                                      const Color(
                                                        0xFFF46856,
                                                      ),
                                                      minimumSize:
                                                      const Size(
                                                        110,
                                                        32,
                                                      ),
                                                      maximumSize:
                                                      const Size(
                                                        110,
                                                        32,
                                                      ),
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                        14,
                                                        7,
                                                        14,
                                                        7,
                                                      ),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          79,
                                                        ),
                                                        side: const BorderSide(
                                                          color: Color(
                                                            0xFFF46856,
                                                          ),
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Few Pieces Left",
                                                      style: TextStyle(
                                                        fontFamily:
                                                        GoogleFonts.barlow()
                                                            .fontFamily,
                                                        fontSize:
                                                        10,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                        color: const Color(
                                                          0xFFF46856,
                                                        ),
                                                        letterSpacing:
                                                        0.48,
                                                      ),
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                    ),
                                                  ),

                                                );
                                              }

                                              if (product.discount != 0) {
                                                if (badges.isNotEmpty)
                                                  badges.add(
                                                    SizedBox(height: 10),
                                                  );
                                                badges.add(
                                                  ElevatedButton(
                                                    onPressed:
                                                        () {}, // Replace with your logic
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                      Color(
                                                        0xFFF46856,
                                                      ),
                                                      foregroundColor:
                                                      const Color(
                                                        0xFFF46856,
                                                      ),
                                                      minimumSize:
                                                      const Size(
                                                        110,
                                                        32,
                                                      ),
                                                      maximumSize:
                                                      const Size(
                                                        110,
                                                        32,
                                                      ),
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                        14,
                                                        7,
                                                        14,
                                                        7,
                                                      ),
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
                                                        fontSize:
                                                        10,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                        color:
                                                        Colors
                                                            .white,
                                                        letterSpacing:
                                                        0.48,
                                                      ),
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                    ),
                                                  ),
                                                );
                                              }

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: badges,
                                              );
                                            },
                                          ),
                                          Spacer(),
                                          FutureBuilder<bool>(
                                            future:
                                                SharedPreferencesHelper.isInWishlist(
                                                  product.id.toString(),
                                                ),
                                            builder: (context, snapshot) {
                                              final isInWishlist =
                                                  snapshot.data ?? false;
                                              return GestureDetector(
                                                onTap:
                                                    isOutOfStock
                                                        ? null
                                                        : () async {
                                                          if (isInWishlist) {
                                                            await SharedPreferencesHelper.removeFromWishlist(
                                                              product.id
                                                                  .toString(),
                                                            );
                                                            widget
                                                                .onWishlistChanged
                                                                ?.call(
                                                                  'Product Removed From Wishlist',
                                                                );
                                                          } else {
                                                            await SharedPreferencesHelper.addToWishlist(
                                                              product.id
                                                                  .toString(),
                                                            );
                                                            widget
                                                                .onWishlistChanged
                                                                ?.call(
                                                                  'Product Added To Wishlist',
                                                                );
                                                          }
                                                          setState(() {});
                                                        },
                                                child: SvgPicture.asset(
                                                  isInWishlist
                                                      ? 'assets/home_page/IconWishlist.svg'
                                                      : 'assets/home_page/IconWishlistEmpty.svg',
                                                  width: isMobile ? 20 : 24,
                                                  height: isMobile ? 18 : 20,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
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
                                  CralikaFont(
                                    text: product.name,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    lineHeight: 1.2,
                                    letterSpacing: 0.64,
                                    color: Color(0xFF30578E),
                                    maxLines: 1,
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
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              height: 1.2,
                                              decoration:
                                              TextDecoration.lineThrough,
                                              decorationColor: Color(
                                                0xFF30578E,
                                              ).withOpacity(0.7),
                                              fontFamily:
                                              GoogleFonts.barlow()
                                                  .fontFamily,
                                            ),
                                          ),

                                        // Vertical divider
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
                                          color: const Color(0xFF30578E),
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
                                            ? () async {
                                              bool isLoggedIn =
                                                  await _isLoggedIn();

                                              if (isLoggedIn) {
                                                widget.onWishlistChanged?.call(
                                                  "We'll notify you when this product is back in stock.",
                                                );
                                              } else {
                                                context.go(AppRoutes.logIn);
                                              }
                                            }
                                            : () {
                                              widget.onWishlistChanged?.call(
                                                'Product Added To Cart',
                                              );
                                              Future.delayed(
                                                Duration(seconds: 2),
                                                () {
                                                  context.go(
                                                    AppRoutes.cartDetails(
                                                      product.id,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                    child: Text(
                                      isOutOfStock
                                          ? "NOTIFY ME"
                                          : "ADD TO CART",
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
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
