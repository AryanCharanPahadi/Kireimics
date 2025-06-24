import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/no_result_found/no_order_yet.dart';
import 'package:kireimics/component/no_result_found/no_result_found.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../cart/cart_panel.dart';
import '../component/height_weight.dart';
import '../component/rotating_svg_loader.dart';
import '../notify_me/notify_me.dart';

class WishlistUi extends StatefulWidget {
  final Function(String)? onWishlistChanged;

  const WishlistUi({super.key, this.onWishlistChanged});

  @override
  State<WishlistUi> createState() => _WishlistUiState();
}

class _WishlistUiState extends State<WishlistUi> {
  List<Product> productList = [];
  bool isLoading = true;
  String errorMessage = "";
  List<bool> _isHoveredList = [];

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
        _isHoveredList = List.filled(fetchedProducts.length, false);
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
            padding:
                MediaQuery.of(context).size.width > 1400
                    ? EdgeInsets.only(
                      left: 389,
                      top: 24,
                      right: MediaQuery.of(context).size.width * 0.15,
                    )
                    : EdgeInsets.only(
                      left: 292,
                      top: 24,
                      right: MediaQuery.of(context).size.width * 0.07,
                    ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      hoverTextColor: const Color(0xFF2876E4),
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
                      hoverTextColor: const Color(0xFF2876E4),
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
                      hoverTextColor: const Color(0xFF2876E4),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      lineHeight: 36 / 32,
                      letterSpacing: 1.28,
                      color: const Color(0xFF414141),
                    ),
                    const SizedBox(height: 24),
                    if (productList.isEmpty)
                      Center(
                        child: CartEmpty(
                          cralikaText: "No product added!",
                          barlowText:
                              "Browse our catalog and heart the items you like! They will appear here.",
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 1400
                                        ? 4
                                        : 3,
                                crossAxisSpacing: 23,
                                mainAxisSpacing: 23,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            final product = productList[index];

                            return FutureBuilder<int?>(
                              future: fetchStockQuantity(product.id.toString()),
                              builder: (context, snapshot) {
                                final quantity = snapshot.data;
                                final isOutOfStock = quantity == 0;

                                return MouseRegion(
                                  onEnter:
                                      (_) => setState(
                                        () => _isHoveredList[index] = true,
                                      ),
                                  onExit:
                                      (_) => setState(
                                        () => _isHoveredList[index] = false,
                                      ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double imageWidth = constraints.maxWidth;
                                      double imageHeight =
                                          constraints.maxHeight;

                                      return SizedBox(
                                        width: imageWidth,
                                        height: imageHeight,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: ClipRRect(
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  transform:
                                                      Matrix4.identity()..scale(
                                                        _isHoveredList[index] &&
                                                                !isOutOfStock
                                                            ? 1.1
                                                            : 1.0,
                                                      ),
                                                  transformAlignment:
                                                      Alignment.center,
                                                  child: GestureDetector(
                                                    onTap:
                                                        isOutOfStock
                                                            ? null
                                                            : () {
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
                                                                Colors
                                                                    .transparent,
                                                                BlendMode
                                                                    .multiply,
                                                              ),
                                                      child: Image.network(
                                                        product.thumbnail,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 50,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Positioned(
                                              top: imageHeight * 0.04,
                                              left: imageWidth * 0.05,
                                              right: imageWidth * 0.05,
                                              child: LayoutBuilder(
                                                builder: (
                                                  context,
                                                  constraints,
                                                ) {
                                                  double screenWidth =
                                                      constraints.maxWidth;

                                                  double getResponsiveValue(
                                                    double min,
                                                    double max,
                                                  ) {
                                                    if (screenWidth <= 800)
                                                      return min;
                                                    if (screenWidth >= 1400)
                                                      return max;
                                                    return min +
                                                        ((max - min) *
                                                            ((screenWidth -
                                                                    800) /
                                                                (1400 - 800)));
                                                  }

                                                  double paddingVertical =
                                                      getResponsiveValue(6, 12);

                                                  if (isOutOfStock) {
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
                                                            height: 32,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment
                                                                  .centerRight,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              toggleWishlist(
                                                                product.id
                                                                    .toString(),
                                                              );
                                                            },
                                                            child: SvgPicture.asset(
                                                              productList.any(
                                                                    (p) =>
                                                                        p.id
                                                                            .toString() ==
                                                                        product
                                                                            .id
                                                                            .toString(),
                                                                  )
                                                                  ? 'assets/home_page/IconWishlist.svg'
                                                                  : 'assets/home_page/IconWishlistEmpty.svg',
                                                              width: 23,
                                                              height: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }

                                                  return Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          final List<Widget>
                                                          badges = [];

                                                          if (product
                                                                  .isMakerChoice ==
                                                              1) {
                                                            badges.add(
                                                              SvgPicture.asset(
                                                                "assets/home_page/maker_choice.svg",
                                                                height: 50,
                                                              ),
                                                            );
                                                          }



                                                          if (product
                                                                  .discount !=
                                                              0) {
                                                            if (badges
                                                                .isNotEmpty)
                                                              badges.add(
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                              );
                                                            badges.add(
                                                              ElevatedButton(
                                                                onPressed: null,
                                                                style: ElevatedButton.styleFrom(
                                                                  padding: EdgeInsets.symmetric(
                                                                    vertical: 7.5,
                                                                    horizontal: 14,
                                                                  ),
                                                                  backgroundColor:
                                                                      const Color(
                                                                        0xFFF46856,
                                                                      ),
                                                                  disabledBackgroundColor:
                                                                      const Color(
                                                                        0xFFF46856,
                                                                      ),
                                                                  disabledForegroundColor:
                                                                      Colors
                                                                          .white,
                                                                  elevation: 0,
                                                                  side:
                                                                      BorderSide
                                                                          .none,
                                                                ),
                                                                child:BarlowText(
                                                                  text: "${product.discount}% OFF",
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.white,
                                                                  lineHeight: 1.0, // 100% of font size
                                                                  letterSpacing: 0.56, // 4% of 14px = 0.56
                                                                ),
                                                              ),
                                                            );
                                                          }

                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: badges,
                                                          );
                                                        },
                                                      ),
                                                      Spacer(),
                                                      GestureDetector(
                                                        onTap: () {
                                                          toggleWishlist(
                                                            product.id
                                                                .toString(),
                                                          );
                                                        },
                                                        child: SvgPicture.asset(
                                                          productList.any(
                                                                (p) =>
                                                                    p.id
                                                                        .toString() ==
                                                                    product.id
                                                                        .toString(),
                                                              )
                                                              ? 'assets/home_page/IconWishlist.svg'
                                                              : 'assets/home_page/IconWishlistEmpty.svg',
                                                          width: 23,
                                                          height: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              bottom: imageHeight * 0.02,
                                              left: imageWidth * 0.02,
                                              right: imageWidth * 0.02,
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                opacity:
                                                    _isHoveredList[index]
                                                        ? 1.0
                                                        : 0.0,
                                                child: Container(
                                                  width: ResponsiveUtil(
                                                    context,
                                                  ).getResponsiveWidth(
                                                    imageWidth,
                                                  ),
                                                  height: ResponsiveUtil(
                                                    context,
                                                  ).getResponsiveHeight(
                                                    imageHeight,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        imageWidth * 0.05,
                                                    vertical:
                                                        imageHeight * 0.02,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF30578E,
                                                    ).withOpacity(0.8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CralikaFont(
                                                        maxLines: 2,
                                                        text:
                                                            product.name ??
                                                            "Product Name",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        lineHeight: 1.2,
                                                        letterSpacing:
                                                            imageWidth * 0.002,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            imageHeight * 0.01,
                                                      ),
                                                      if (!isOutOfStock) ...[
                                                        Row(
                                                          children: [
                                                            // Original price with strikethrough
                                                            if (product
                                                                    .discount !=
                                                                0)
                                                              Text(
                                                                "Rs. ${product.price.toStringAsFixed(2)}",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                        0.7,
                                                                      ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  height: 1.2,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  decorationColor: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                        0.7,
                                                                      ), // Match strikethrough color
                                                                  fontFamily:
                                                                      GoogleFonts.barlow()
                                                                          .fontFamily, // Match Barlow font
                                                                ),
                                                              ),
                                                            if (product
                                                                    .discount !=
                                                                0)
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                            // Discounted price
                                                            BarlowText(
                                                              text:
                                                                  product.discount !=
                                                                          0
                                                                      ? "Rs. ${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}"
                                                                      : "Rs. ${product.price.toStringAsFixed(2)}",
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              lineHeight: 1.2,
                                                            ),
                                                          ],
                                                        ),
                                                      ],

                                                      if (isOutOfStock) ...[
                                                        BarlowText(
                                                          text:
                                                              "Rs. ${product.price.toStringAsFixed(2)}",
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          lineHeight: 1.2,
                                                        ),
                                                      ],

                                                      SizedBox(
                                                        height:
                                                            imageHeight * 0.04,
                                                      ),
                                                      if (isOutOfStock)
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                context.go(
                                                                  AppRoutes.productDetails(
                                                                    product.id,
                                                                  ),
                                                                );
                                                              },
                                                              child: BarlowText(
                                                                text: "VIEW",
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                lineHeight: 1.0,
                                                                enableHoverBackground:
                                                                    true,
                                                                hoverBackgroundColor:
                                                                    Colors
                                                                        .white,
                                                                hoverTextColor:
                                                                    Color(
                                                                      0xFF30578E,
                                                                    ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  imageWidth *
                                                                  0.02,
                                                            ),
                                                            Text(
                                                              "/",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontFamily:
                                                                    GoogleFonts.barlow()
                                                                        .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 15,
                                                                height: 1.0,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  imageWidth *
                                                                  0.02,
                                                            ),
                                                            NotifyMeButton(
                                                              onWishlistChanged:
                                                              widget
                                                                  .onWishlistChanged,

                                                              productId:
                                                              product.id,
                                                            ),                                                          ],
                                                        )
                                                      else
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                context.go(
                                                                  AppRoutes.productDetails(
                                                                    product.id,
                                                                  ),
                                                                );
                                                              },
                                                              child: BarlowText(
                                                                text: "VIEW",
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                lineHeight: 1.0,
                                                                enableHoverBackground:
                                                                    true,
                                                                hoverBackgroundColor:
                                                                    Colors
                                                                        .white,
                                                                hoverTextColor:
                                                                    const Color(
                                                                      0xFF30578E,
                                                                    ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  imageWidth *
                                                                  0.02,
                                                            ),
                                                            BarlowText(
                                                              text: " / ",
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              lineHeight: 1.0,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  imageWidth *
                                                                  0.02,
                                                            ),
                                                            BarlowText(
                                                              text:
                                                                  "ADD TO CART",
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              lineHeight: 1.0,
                                                              enableHoverBackground:
                                                                  true,
                                                              hoverBackgroundColor:
                                                                  Colors.white,
                                                              hoverTextColor:
                                                                  const Color(
                                                                    0xFF30578E,
                                                                  ),
                                                              onTap: () async {
                                                                // 1. Call the wishlist changed callback immediately
                                                                widget
                                                                    .onWishlistChanged
                                                                    ?.call(
                                                                      'Product Added To Cart',
                                                                    );

                                                                // 2. Store the product ID in SharedPreferences
                                                                await SharedPreferencesHelper.addProductId(
                                                                  product.id,
                                                                );

                                                                // 3. Refresh the cart state
                                                                cartNotifier
                                                                    .refresh();

                                                                // Note: Removed the Future.delayed and showDialog parts
                                                              },
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
