import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/app_routes/routes.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../cart/cart_panel.dart';
import '../component/animation_gridview.dart';
import '../component/badges_web_desktop.dart';
import '../component/height_weight.dart';
import '../component/rotating_svg_loader.dart';
import '../notify_me/notify_me.dart';

class SearchGridview extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  const SearchGridview({super.key, this.onWishlistChanged});

  @override
  State<SearchGridview> createState() => _SearchGridviewState();
}

class _SearchGridviewState extends State<SearchGridview>
    with TickerProviderStateMixin {
  final ProductController productController = Get.put(ProductController());
  List<bool> _isHoveredList = [];
  List<bool> _wishlistStates = [];
  String _currentQuery = '';
  bool _initialized = false;
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentQuery =
              GoRouterState.of(context).uri.queryParameters['query'] ?? '';
          productController.resetFilter();
          productController.filterProducts(_currentQuery);
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
        productController.resetFilter();
        productController.filterProducts(_currentQuery);
      }
    }
  }

  void _initializeStates(int count) {
    // Initialize hover, wishlist states, and animation controllers
    if (_isHoveredList.length != count) {
      _isHoveredList = List.filled(count, false);
    }
    if (_wishlistStates.length != count) {
      _wishlistStates = List.filled(count, false);
    }
    if (_controllers.length != count) {
      // Dispose old controllers if count changes
      for (var controller in _controllers) {
        controller.dispose();
      }
      _controllers = List.generate(
        count,
        (_) => AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        ),
      );
      _animations =
          _controllers
              .map(
                (controller) => Tween<double>(begin: 1.0, end: 1.1).animate(
                  CurvedAnimation(parent: controller, curve: Curves.easeOut),
                ),
              )
              .toList();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
    final query = GoRouterState.of(context).uri.queryParameters['query'] ?? '';
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Expanded(
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    right:
                        isLargeScreen ? screenWidth * 0.15 : screenWidth * 0.07,
                    left: isLargeScreen ? 389 : 289,
                    top: 30,
                  ),
                  child: Obx(() {
                    if (productController.isLoading.value) {
                      return const Center(
                        child: RotatingSvgLoader(
                          assetPath: 'assets/footer/footerbg.svg',
                        ),
                      );
                    }

                    if (productController.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text("Error: ${productController.errorMessage}"),
                      );
                    }

                    final resultCount =
                        productController.filteredProducts.length;
                    final resultText =
                    resultCount == 1
                        ? '1 Result'
                        : resultCount == 0
                        ? '0 Result'
                        : '$resultCount Results';

                    if (productController.filteredProducts.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CralikaFont(
                            text: '"$query"',
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF414141),
                          ),
                          const SizedBox(height: 8),
                          CralikaFont(
                            text: resultText,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF414141),
                          ),
                          const SizedBox(height: 40),

                          Center(
                            child: CartEmpty(
                              cralikaText: "No results found!",
                              barlowText:
                                  "Looks like the product you're looking for is not available. Please try a different keyword, or check the spelling!",
                            ),
                          ),
                        ],
                      );
                    }

                    // Initialize states for the current product list
                    _initializeStates(
                      productController.filteredProducts.length,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CralikaFont(
                          text: '"$_currentQuery"',
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF414141),
                        ),
                        const SizedBox(height: 8),
                        CralikaFont(
                          text: resultText,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF414141),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: screenWidth * 0.9, // Responsive width
                          constraints: const BoxConstraints(maxWidth: 1301),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isLargeScreen ? 4 : 3,
                                  crossAxisSpacing: 23,
                                  mainAxisSpacing: 23,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount:
                                productController.filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product =
                                  productController.filteredProducts[index];

                              return FutureBuilder<int?>(
                                future: fetchStockQuantity(
                                  product.id.toString(),
                                ),
                                builder: (context, snapshot) {
                                  final quantity = snapshot.data;
                                  final isOutOfStock = quantity == 0;

                                  return MouseRegion(
                                    onEnter: (_) {
                                      setState(
                                        () => _isHoveredList[index] = true,
                                      );
                                      _controllers[index].forward();
                                    },
                                    onExit: (_) {
                                      setState(
                                        () => _isHoveredList[index] = false,
                                      );
                                      _controllers[index].reverse();
                                    },
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        double imageWidth =
                                            constraints.maxWidth;
                                        double imageHeight =
                                            constraints.maxHeight;

                                        return SizedBox(
                                          width: imageWidth,
                                          height: imageHeight,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRect(
                                                  child: AnimatedBuilder(
                                                    animation:
                                                        _animations[index],
                                                    builder: (context, child) {
                                                      double scale =
                                                          _isHoveredList[index]
                                                              ? _animations[index]
                                                                  .value
                                                              : 1.0;

                                                      Widget imageWidget =
                                                          AnimatedZoomImage(
                                                            imageUrl:
                                                                product
                                                                    .thumbnail,
                                                          );

                                                      // Apply grayscale filter if out of stock
                                                      if (isOutOfStock) {
                                                        imageWidget = ColorFiltered(
                                                          colorFilter:
                                                              const ColorFilter.matrix(
                                                                <double>[
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
                                                              ),
                                                          child: imageWidget,
                                                        );
                                                      }

                                                      return Transform.scale(
                                                        scale: scale,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            context.go(
                                                              AppRoutes.productDetails(
                                                                product.id,
                                                              ),
                                                            );
                                                          },
                                                          child: imageWidget,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              // if (isOutOfStock)
                                              //   Positioned.fill(
                                              //     child: Container(
                                              //       color: Colors.black
                                              //           .withOpacity(0.5),
                                              //     ),
                                              //   ),
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

                                                    // Responsive scaling for 800–1400px
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
                                                                  (1400 -
                                                                      800)));
                                                    }

                                                    double paddingVertical =
                                                        getResponsiveValue(
                                                          6,
                                                          12,
                                                        );

                                                    return WishlistBadgeRow(
                                                      product: product,
                                                      isOutOfStock:
                                                          isOutOfStock,
                                                      quantity: quantity,
                                                      onWishlistChanged:
                                                          widget
                                                              .onWishlistChanged,
                                                      paddingVertical:
                                                          paddingVertical,
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
                                                          : 0.0, // Show on hover
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
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              imageWidth * 0.05,
                                                          vertical:
                                                              imageHeight *
                                                              0.02,
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
                                                          text: product.name,
                                                          maxLines: 2,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          lineHeight: 1.2,
                                                          letterSpacing:
                                                              imageWidth *
                                                              0.002,
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              imageHeight *
                                                              0.01,
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
                                                                    fontSize:
                                                                        14,
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
                                                                    Colors
                                                                        .white,
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
                                                              imageHeight *
                                                              0.04,
                                                        ),

                                                        if (isOutOfStock)
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  context.go(
                                                                    AppRoutes.productDetails(
                                                                      product
                                                                          .id,
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
                                                                  lineHeight:
                                                                      1.0,
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
                                                              ),
                                                            ],
                                                          )
                                                        else
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  context.go(
                                                                    AppRoutes.productDetails(
                                                                      product
                                                                          .id,
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
                                                                  lineHeight:
                                                                      1.0,
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
                                                                    Colors
                                                                        .white,
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
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
