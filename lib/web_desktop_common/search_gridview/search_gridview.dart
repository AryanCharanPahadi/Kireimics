import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/app_routes/routes.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../cart/cart_panel.dart';
import '../component/animation_gridview.dart';

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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productController.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text("Error: ${productController.errorMessage}"),
                      );
                    }

                    final resultCount =
                        productController.filteredProducts.length;
                    final resultText =
                        resultCount == 1 ? '1 Result' : '$resultCount Results';

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
                          BarlowText(
                            text: resultText,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF414141),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: SvgPicture.asset(
                              "assets/icons/notFound.svg",
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: CralikaFont(text: "No results found!"),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: BarlowText(
                              text:
                                  "Looks like the product you're looking for is not available. Please try a different keyword, or check the spelling!",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              context.go(AppRoutes.catalog);
                            },
                            child: const Center(
                              child: BarlowText(
                                text: "BROWSE OUR CATALOG",
                                backgroundColor: Color(0xFFb9d6ff),
                                color: Color(0xFF3E5B84),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
                                    onEnter:
                                        isOutOfStock
                                            ? null
                                            : (_) {
                                              setState(
                                                () =>
                                                    _isHoveredList[index] =
                                                        true,
                                              );
                                              _controllers[index].forward();
                                            },
                                    onExit:
                                        isOutOfStock
                                            ? null
                                            : (_) {
                                              setState(
                                                () =>
                                                    _isHoveredList[index] =
                                                        false,
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
                                                      return Transform.scale(
                                                        scale:
                                                            _animations[index]
                                                                .value,
                                                        child: GestureDetector(
                                                          onTap:
                                                              isOutOfStock
                                                                  ? null
                                                                  : () {
                                                                    context.go(
                                                                      AppRoutes.productDetails(
                                                                        product
                                                                            .id,
                                                                      ),
                                                                    );
                                                                  },
                                                          child: AnimatedZoomImage(
                                                            imageUrl:
                                                                product
                                                                    .thumbnail,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              if (isOutOfStock)
                                                Positioned.fill(
                                                  child: Container(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
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

                                                    if (isOutOfStock) {
                                                      // Only return the Out of Stock image, nothing else
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
                                                            child: SvgPicture.asset(
                                                              "assets/home_page/IconWishlistEmpty.svg",
                                                              width: 23,
                                                              height: 20,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }

                                                    // Normal UI when product is in stock
                                                    return Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Builder(
                                                          builder: (context) {
                                                            final List<Widget> badges = [];

                                                            if (product.isMakerChoice == 1) {
                                                              badges.add(
                                                                SvgPicture.asset(
                                                                  "assets/home_page/maker_choice.svg",
                                                                  height: 50,
                                                                ),
                                                              );
                                                            }

                                                            if (quantity != null && quantity < 2) {
                                                              if (badges.isNotEmpty) badges.add(SizedBox(height: 10));
                                                              badges.add(
                                                                SvgPicture.asset(
                                                                  "assets/home_page/fewPiecesLeft.svg",
                                                                ),
                                                              );
                                                            }

                                                            if (product.discount != 0) {
                                                              if (badges.isNotEmpty) badges.add(SizedBox(height: 10));
                                                              badges.add(
                                                                ElevatedButton(
                                                                  onPressed: null,
                                                                  style: ElevatedButton.styleFrom(
                                                                    padding: EdgeInsets.symmetric(
                                                                      vertical: paddingVertical,
                                                                      horizontal: 32,
                                                                    ),
                                                                    backgroundColor: const Color(0xFFF46856),
                                                                    disabledBackgroundColor: const Color(0xFFF46856),
                                                                    disabledForegroundColor: Colors.white,
                                                                    elevation: 0,
                                                                    side: BorderSide.none,
                                                                  ),
                                                                  child: Text(
                                                                    "${product.discount}% OFF",
                                                                    style: const TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            return Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: badges,
                                                            );
                                                          },
                                                        ),
                                                        Spacer(),
                                                        FutureBuilder<bool>(
                                                          future: SharedPreferencesHelper.isInWishlist(
                                                            product.id.toString(),
                                                          ),
                                                          builder: (context, snapshot) {
                                                            final isInWishlist = snapshot.data ?? false;

                                                            return GestureDetector(
                                                              onTap: () async {
                                                                if (isInWishlist) {
                                                                  await SharedPreferencesHelper.removeFromWishlist(
                                                                    product.id.toString(),
                                                                  );
                                                                  widget.onWishlistChanged?.call('Product Removed From Wishlist');
                                                                } else {
                                                                  await SharedPreferencesHelper.addToWishlist(
                                                                    product.id.toString(),
                                                                  );
                                                                  widget.onWishlistChanged?.call('Product Added To Wishlist');
                                                                }
                                                                setState(() {});
                                                              },
                                                              child: SvgPicture.asset(
                                                                isInWishlist
                                                                    ? 'assets/home_page/IconWishlist.svg'
                                                                    : 'assets/home_page/IconWishlistEmpty.svg',
                                                                width: 23,
                                                                height: 20,
                                                              ),
                                                            );
                                                          },
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
                                                      _isHoveredList[index] &&
                                                              !isOutOfStock
                                                          ? 1.0
                                                          : 0.0,
                                                  child: Container(
                                                    width: imageWidth * 0.95,
                                                    height: imageHeight * 0.35,
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
                                                        0xFF3E5B84,
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
                                                          maxLines: 1,
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
                                                              0.03,
                                                        ),
                                                        BarlowText(
                                                          text:
                                                              "Rs. ${product.price.toStringAsFixed(2)}",
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16,
                                                          lineHeight: 1.0,
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              imageHeight *
                                                              0.03,
                                                        ),
                                                        Row(
                                                          children: [
                                                            GestureDetector(
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
                                                                      0xFF3E5B84,
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
                                                            GestureDetector(
                                                              onTap:
                                                                  isOutOfStock
                                                                      ? null
                                                                      : () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          barrierColor:
                                                                              Colors.transparent,
                                                                          builder: (
                                                                            BuildContext
                                                                            context,
                                                                          ) {
                                                                            cartNotifier.refresh();

                                                                            return CartPanel(
                                                                              productId:
                                                                                  product.id,
                                                                            );
                                                                          },
                                                                        );
                                                                        widget
                                                                            .onWishlistChanged
                                                                            ?.call(
                                                                              'Product Added To Cart',
                                                                            );
                                                                      },
                                                              child: BarlowText(
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
                                                                      0xFF3E5B84,
                                                                    ),
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
