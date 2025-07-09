import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/categories/categories_controller.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../cart/cart_panel.dart';
import '../component/animation_gridview.dart';

class CatalogViewAll extends StatefulWidget {
  final int catId;
  final Function(String)? onWishlistChanged;

  const CatalogViewAll({
    super.key,
    this.onWishlistChanged,
    required this.catId,
  });

  @override
  State<CatalogViewAll> createState() => _CatalogViewAllState();
}

class _CatalogViewAllState extends State<CatalogViewAll>
    with TickerProviderStateMixin {
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );
  List<Product> productList = [];
  bool isLoading = false;
  List<bool> _isHoveredList = [];
  List<bool> _wishlistStates = [];
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];

  void _initializeStates(int count) {
    if (_isHoveredList.length != count) {
      _isHoveredList = List.filled(count, false);
    }
    if (_wishlistStates.length != count) {
      _wishlistStates = List.filled(count, false);
    }

    // Initialize animation controllers and animations
    while (_controllers.length < count) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      final animation = Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
      _controllers.add(controller);
      _animations.add(animation);
    }

    // Remove extra controllers if count decreased
    while (_controllers.length > count) {
      _controllers.removeLast().dispose();
      _animations.removeLast();
    }
  }

  Future<void> _initializeWishlistStates() async {
    for (int i = 0; i < productList.length; i++) {
      final isInWishlist = await SharedPreferencesHelper.isInWishlist(
        productList[i].id.toString(),
      );
      setState(() {
        _wishlistStates[i] = isInWishlist;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProductsByCategoryId(widget.catId);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchProductsByCategoryId(int catId) async {
    setState(() {
      isLoading = true;
    });

    final products = await ApiHelper.fetchProductByCatId(catId);

    setState(() {
      productList = products ?? [];
      isLoading = false;
      _initializeStates(productList.length);
      _initializeWishlistStates();
    });
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
      // print("Error fetching stock: $e");
      return null;
    }
  }

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : productList.isEmpty
              ? Padding(
                padding: EdgeInsets.only(
                  left: isLargeScreen ? 450 : 296,
                  top: 80,
                ),
                child: Column(
                  children: [
                    SvgPicture.asset("assets/icons/notFound.svg"),
                    const SizedBox(height: 20),
                    const CralikaFont(text: "No results found!"),
                    const SizedBox(height: 10),
                    const BarlowText(
                      text:
                          "Looks like the product you're looking for is not available. Please try a different keyword, or check the spelling!",
                      fontSize: 18,
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRoutes.catalog);
                      },
                      child: const BarlowText(
                        text: "BROWSE OUR CATALOG",
                        backgroundColor: Color(0xFFb9d6ff),
                        color: Color(0xFF30578E),
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    right:
                        isLargeScreen
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.07,
                    left: isLargeScreen ? 389 : 292,
                    top: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CralikaFont(
                        text: "${productList.length} PRODUCT FOUND",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF30578E),
                      ),
                      SizedBox(height: 20),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 1400 ? 4 : 3,
                          mainAxisSpacing: 23,
                          crossAxisSpacing: 23,
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
                                    isOutOfStock
                                        ? null
                                        : (_) {
                                          setState(
                                            () => _isHoveredList[index] = true,
                                          );
                                          _controllers[index].forward();
                                        },
                                onExit:
                                    isOutOfStock
                                        ? null
                                        : (_) {
                                          setState(
                                            () => _isHoveredList[index] = false,
                                          );
                                          _controllers[index].reverse();
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
                                              child: AnimatedBuilder(
                                                animation: _animations[index],
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
                                                                    product.id,
                                                                  ),
                                                                );
                                                              },
                                                      child: AnimatedZoomImage(
                                                        imageUrl:
                                                            product.thumbnail,
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
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            top: imageHeight * 0.04,
                                            left: imageWidth * 0.05,
                                            right: imageWidth * 0.05,
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
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
                                                          ((screenWidth - 800) /
                                                              (1400 - 800)));
                                                }

                                                double paddingVertical =
                                                    getResponsiveValue(6, 12);

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
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: imageWidth * 0.05,
                                                  vertical: imageHeight * 0.02,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF30578E,
                                                  ).withOpacity(0.8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CralikaFont(
                                                      maxLines: 1,
                                                      text: product.name,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16,
                                                      lineHeight: 1.2,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          imageHeight * 0.04,
                                                    ),
                                                    BarlowText(
                                                      text:
                                                          "Rs. ${product.price.toStringAsFixed(2)}",
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16,
                                                      lineHeight: 1.2,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          imageHeight * 0.04,
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
                                                                        product
                                                                            .id,
                                                                      ),
                                                                    );
                                                                  },
                                                          child: const BarlowText(
                                                            text: "VIEW",
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            lineHeight: 1.0,
                                                            enableHoverBackground:
                                                                true,
                                                            hoverBackgroundColor:
                                                                Colors.white,
                                                            hoverTextColor:
                                                                Color(
                                                                  0xFF30578E,
                                                                ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              imageWidth * 0.02,
                                                        ),
                                                        Text(
                                                          "/",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                GoogleFonts.barlow()
                                                                    .fontFamily,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15,
                                                            height: 1.0,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              imageWidth * 0.02,
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
                                                                          Colors
                                                                              .transparent,
                                                                      builder: (
                                                                        BuildContext
                                                                        context,
                                                                      ) {
                                                                        cartNotifier
                                                                            .refresh();
                                                                        return isLargeScreen
                                                                            ? CartPanel(
                                                                              productId:
                                                                                  product.id,
                                                                            )
                                                                            : CartPanel(
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
                                                          child: const BarlowText(
                                                            text: "ADD TO CART",
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            lineHeight: 1.0,
                                                            enableHoverBackground:
                                                                true,
                                                            hoverBackgroundColor:
                                                                Colors.white,
                                                            hoverTextColor:
                                                                Color(
                                                                  0xFF30578E,
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
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
