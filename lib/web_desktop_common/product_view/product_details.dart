import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/no_result_found/no_product_yet.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/cart/cart_panel.dart';
import '../catalog_sale_gridview/catalog_controller1.dart';
import '../login_signup/login/login_page.dart';

class ProductDetails extends StatefulWidget {
  final int productId;
  final Function(String)? onWishlistChanged; // Callback to notify parent

  const ProductDetails({
    Key? key,
    required this.productId,
    this.onWishlistChanged,
  }) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with SingleTickerProviderStateMixin {
  Product? product;
  bool isLoading = true;
  String errorMessage = "";
  List<Product> relatedProducts = [];
  int _currentIndex = 0; // Tracks the starting index of displayed products
  String? _currentMainImage; // Track the currently displayed main image
  List<String> _otherImages = []; // Track all other images
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    print("This is the product id ${widget.productId}");
    fetchProduct();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Add this to handle updates when productId changes
  @override
  void didUpdateWidget(ProductDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      // Reset state and fetch new product when productId changes
      setState(() {
        product = null;
        isLoading = true;
        errorMessage = "";
        relatedProducts = [];
      });
      fetchProduct();
    }
  }

  final List<bool> _isHoveredList = List.generate(3, (_) => false);

  Future<void> fetchProduct() async {
    try {
      final fetchedProduct = await ApiHelper.fetchProductDetailsById(
        widget.productId,
      );
      if (fetchedProduct != null) {
        setState(() {
          product = fetchedProduct;
          _currentMainImage = fetchedProduct.thumbnail;
          _otherImages = List.from(fetchedProduct.otherImages);
          isLoading = false;
        });

        // Fetch related products by category ID
        final categoryProducts = await ApiHelper.fetchProductByCatId(
          fetchedProduct.catId,
        );
        if (categoryProducts != null) {
          setState(() {
            relatedProducts =
                categoryProducts
                    .where(
                      (p) => p.id != widget.productId,
                    ) // Exclude current product
                    .toList(); // Remove the .take(3) limit
          });
        }
      } else {
        setState(() {
          errorMessage = "Product not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong";
        isLoading = false;
      });
    }
  }

  void _swapImageWithMain(int index) {
    setState(() {
      // Swap the clicked image with the current main image
      final clickedImage = _otherImages[index];
      _otherImages[index] = _currentMainImage!;
      _currentMainImage = clickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
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

    List<Product> displayedProducts = [];
    if (relatedProducts.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        int index = (_currentIndex + i) % relatedProducts.length;
        displayedProducts.add(relatedProducts[index]);
      }
    }

    return Stack(
      children: [
        Positioned(
          top: 500, // Adjust this value based on your content height
          left: 0,
          right: 0,
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,

                child: Padding(
                  padding: EdgeInsets.only(
                    left: isLargeScreen ? 580 : 490,
                    right: isLargeScreen ? screenWidth * 0.15 : 0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage(
                          "assets/home_page/background.png",
                        ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          const Color(0xFF2472e3).withOpacity(0.9),
                          BlendMode.srcATop,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 230,
                        right: 100,
                        top: 35,
                        bottom: 41,
                      ),
                      child: Column(
                        children:
                            product!.otherDetails.map((detail) {
                              // You can optionally map specific titles to SVG icons
                              String iconPath;
                              switch (detail.title.toLowerCase()) {
                                case 'materials':
                                  iconPath = 'assets/icons/material.svg';
                                  break;
                                case 'product care':
                                  iconPath = 'assets/icons/care.svg';
                                  break;
                                case 'shipping':
                                  iconPath = 'assets/icons/shipping.svg';
                                  break;
                                default:
                                  iconPath =
                                      'assets/icons/info.svg'; // default fallback icon
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: infoTile(
                                  svgAssetPath: iconPath,
                                  title: detail.title,
                                  description: detail.description,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 44),
              Padding(
                padding: EdgeInsets.only(
                  left: isLargeScreen ? 512 : 100.0,
                  right: isLargeScreen ? screenWidth * 0.15 : 38,
                ),
                child: Container(
                  // color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          if (relatedProducts.isNotEmpty) SizedBox(height: 19),
                          if (relatedProducts.isNotEmpty)
                            CralikaFont(
                              text: "Other Products\nyou may like",
                              textAlign: TextAlign.right,
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              lineHeight: 27 / 24,
                              letterSpacing: 0.96,
                              color: Color(0xFF414141),
                            ),
                          SizedBox(height: 19),
                          if (relatedProducts.isNotEmpty) SizedBox(height: 19),
                          if (relatedProducts.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                final controller = Get.put(
                                  CatalogPageController(),
                                ); // Access the controller
                                controller.selectedCategoryId.value =
                                    product!.catId; // Update selectedCategoryId
                                context.go(
                                  AppRoutes
                                      .catalog, // Navigate to the CatalogPage route
                                  extra: {
                                    'categoryId': product!.catId,
                                  }, // Pass categoryId as extra data if needed
                                );
                              },
                              child: BarlowText(
                                text: "BROWSE OUR CATALOG",
                                textAlign: TextAlign.right,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                lineHeight: 1.0,
                                letterSpacing: 0.64,
                                color: Color(0xFF3E5B84),
                                backgroundColor: Color(0xFFb9d6ff),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 22),
                      relatedProducts.isEmpty
                          ? GestureDetector(
                            onTap: () {
                              // context.go(AppRoutes.catalog);
                            },
                            child: Center(child: NoProductYet()),
                          )
                          : Row(
                            children: List.generate(
                              relatedProducts.length > 3
                                  ? 3
                                  : relatedProducts.length,
                              (index) {
                                final relatedProduct =
                                    relatedProducts[(_currentIndex + index) %
                                        relatedProducts.length];
                                final isLast =
                                    index ==
                                    (relatedProducts.length > 3
                                        ? 2
                                        : relatedProducts.length - 1);

                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: isLast ? 0.0 : 10,
                                  ),
                                  child: FutureBuilder<int?>(
                                    future: fetchStockQuantity(
                                      relatedProduct.id.toString(),
                                    ),
                                    builder: (context, snapshot) {
                                      final quantity = snapshot.data;
                                      final isOutOfStock = quantity == 0;

                                      return MouseRegion(
                                        onEnter:
                                            isOutOfStock
                                                ? null
                                                : (_) {
                                                  setState(() {
                                                    _isHoveredList[index] =
                                                        true;
                                                  });
                                                  _controller.forward();
                                                },
                                        onExit:
                                            isOutOfStock
                                                ? null
                                                : (_) {
                                                  setState(() {
                                                    _isHoveredList[index] =
                                                        false;
                                                  });
                                                  _controller.reverse();
                                                },
                                        child: SizedBox(
                                          height: 342,
                                          width: 297,
                                          child: Stack(
                                            children: [
                                              ClipRect(
                                                child: AnimatedBuilder(
                                                  animation: _controller,
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale:
                                                          _isHoveredList[index]
                                                              ? _animation.value
                                                              : 1.0,
                                                      child: Image.network(
                                                        relatedProduct
                                                            .thumbnail,
                                                        height: 342,
                                                        width: 297,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
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
                                                top: 10,
                                                left: 6,
                                                right: 6,
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

                                                    return Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Builder(
                                                          builder: (context) {
                                                            final List<Widget>
                                                            badgeWidgets = [];

                                                            if (relatedProduct
                                                                    .isMakerChoice ==
                                                                1) {
                                                              badgeWidgets.add(
                                                                SvgPicture.asset(
                                                                  "assets/home_page/maker_choice.svg",
                                                                  height: 50,
                                                                ),
                                                              );
                                                            }

                                                            if (quantity !=
                                                                    null &&
                                                                quantity < 2) {
                                                              if (badgeWidgets
                                                                  .isNotEmpty) {
                                                                badgeWidgets
                                                                    .add(
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    );
                                                              }
                                                              badgeWidgets.add(
                                                                SvgPicture.asset(
                                                                  "assets/home_page/fewPiecesLeft.svg",
                                                                ),
                                                              );
                                                            }

                                                            if (relatedProduct
                                                                    .discount !=
                                                                0) {
                                                              if (badgeWidgets
                                                                  .isNotEmpty) {
                                                                badgeWidgets
                                                                    .add(
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    );
                                                              }
                                                              badgeWidgets.add(
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      null,
                                                                  style: ElevatedButton.styleFrom(
                                                                    padding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          paddingVertical,
                                                                      horizontal:
                                                                          32,
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
                                                                    elevation:
                                                                        0,
                                                                    side:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  child: Text(
                                                                    "${relatedProduct.discount}% OFF",
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            return Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children:
                                                                  badgeWidgets,
                                                            );
                                                          },
                                                        ),
                                                        Spacer(),
                                                        FutureBuilder<bool>(
                                                          future:
                                                              SharedPreferencesHelper.isInWishlist(
                                                                relatedProduct
                                                                    .id
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
                                                              onTap: () async {
                                                                if (isInWishlist) {
                                                                  await SharedPreferencesHelper.removeFromWishlist(
                                                                    relatedProduct
                                                                        .id
                                                                        .toString(),
                                                                  );
                                                                  widget
                                                                      .onWishlistChanged
                                                                      ?.call(
                                                                        'Product Removed From Wishlist',
                                                                      );
                                                                } else {
                                                                  await SharedPreferencesHelper.addToWishlist(
                                                                    relatedProduct
                                                                        .id
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
                                                bottom: 9,
                                                left: 8,
                                                right: 7,
                                                child: AnimatedOpacity(
                                                  duration: Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  opacity:
                                                      _isHoveredList[index] &&
                                                              !isOutOfStock
                                                          ? 1.0
                                                          : 0.0,
                                                  child: Container(
                                                    width: 282,
                                                    height: 120,
                                                    padding: EdgeInsets.only(
                                                      left: 18,
                                                      right: 20,
                                                      bottom: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(
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
                                                          text:
                                                              relatedProduct
                                                                  .name,
                                                          maxLines: 1,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          lineHeight: 1.2,
                                                          letterSpacing: 0.80,
                                                        ),
                                                        SizedBox(height: 8),
                                                        BarlowText(
                                                          text:
                                                              "Rs. ${relatedProduct.price.toStringAsFixed(2)}",
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          lineHeight: 1.0,
                                                        ),
                                                        SizedBox(height: 14),
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap:
                                                                  isOutOfStock
                                                                      ? null
                                                                      : () {
                                                                        context.go(
                                                                          AppRoutes.productDetails(
                                                                            relatedProduct.id,
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
                                                            SizedBox(width: 5),
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
                                                            SizedBox(width: 5),
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
                                                                                  relatedProduct.id,
                                                                            );
                                                                          },
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
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Column(
          children: [
            SizedBox(
              // color: Colors.green,
              width: MediaQuery.of(context).size.width,

              child: Padding(
                padding: EdgeInsets.only(
                  left: isLargeScreen ? 389 : 292, // 40% of screen width
                  top: 25,
                  right: 100, // 7% of screen width
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BarlowText(
                          text: "Catalog",
                          color: Color(0xFF3E5B84),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          letterSpacing: 1 * 0.04, // 4% of 32px
                          onTap: () {
                            context.go(AppRoutes.catalog);
                          },
                        ),
                        SizedBox(width: 9.0),
                        SvgPicture.asset(
                          'assets/icons/right_icon.svg',
                          width: 24,
                          height: 24,
                          color: Color(0xFF3E5B84),
                        ),
                        SizedBox(width: 9.0),

                        BarlowText(
                          text: product!.catName,
                          color: Color(0xFF3E5B84),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          onTap: () {
                            final controller = Get.put(
                              CatalogPageController(),
                            ); // Access the controller
                            controller.selectedCategoryId.value =
                                product!.catId; // Update selectedCategoryId
                            context.go(
                              AppRoutes
                                  .catalog, // Navigate to the CatalogPage route
                              extra: {
                                'categoryId': product!.catId,
                              }, // Pass categoryId as extra data if needed
                            );
                          },
                        ),
                        SizedBox(width: 9.0),
                        SvgPicture.asset(
                          'assets/icons/right_icon.svg',
                          width: 24,
                          height: 24,
                          color: Color(0xFF3E5B84),
                        ),
                        SizedBox(width: 9.0),

                        BarlowText(
                          text: "View Details",
                          color: Color(0xFF3E5B84),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          route: AppRoutes.productDetails(product!.id),
                          enableUnderlineForActiveRoute:
                              true, // Enable underline when active
                          decorationColor: Color(
                            0xFF3E5B84,
                          ), // Color of the underline
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              _currentMainImage!, // Use the current main image
                              width: 370,
                              height: 444,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 10),
                            Row(
                              children:
                                  _otherImages.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final imageUrl = entry.value;
                                    return GestureDetector(
                                      onTap: () => _swapImageWithMain(index),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          width: 118,
                                          height: 122,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 106,
                                                    height: 122,
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.broken_image,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(width: 50),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Container(
                              width: 400,
                              child: CralikaFont(
                                text: product!.name,

                                fontWeight: FontWeight.w400, // 400 weight
                                fontSize: 32, // 32px
                                lineHeight:
                                    36 /
                                    32, // Line height (36px) divided by font size (32px)
                                letterSpacing: 32 * 0.04, // 4% of 32px
                                color: Color(0xFF414141),
                                softWrap: true,
                              ),
                            ),

                            SizedBox(height: 09.0),

                            BarlowText(
                              text: product!.catName,

                              fontWeight: FontWeight.w600, // 400 weight
                              fontSize: 16, // 32px
                              lineHeight: 1.0,
                              letterSpacing: 1 * 0.04, // 4% of 32px
                              color: Color(0xFF3E5B84),
                            ),

                            SizedBox(height: 14),

                            BarlowText(
                              text: product!.price.toStringAsFixed(2),

                              fontWeight: FontWeight.w400, // 400 weight
                              fontSize: 16, // 32px
                              lineHeight: 1.0,
                              letterSpacing: 1 * 0.04, // 4% of 32px
                              color: Color(0xFF414141),
                            ),
                            SizedBox(height: 14),

                            BarlowText(
                              text: product!.dimensions,

                              fontWeight: FontWeight.w400, // 400 weight
                              fontSize: 16, // 32px
                              lineHeight: 1.0,
                              letterSpacing: 1 * 0.04, // 4% of 32px
                              color: Color(0xFF414141),
                            ),

                            SizedBox(height: 14),

                            SizedBox(
                              width: 508,

                              child: BarlowText(
                                text: product!.description,

                                fontWeight: FontWeight.w400, // 400 weight
                                fontSize: 16, // 32px
                                lineHeight: 1.0,
                                letterSpacing: 1 * 0.04, // 4% of 32px
                                color: Color(0xFF414141),
                                softWrap: true,
                              ),
                            ),

                            SizedBox(height: 44),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    cartNotifier.refresh();

                                    return CartPanel(productId: product!.id);
                                  },
                                );
                              },

                              child: BarlowText(
                                text: "ADD TO CART",
                                color: Color(0xFF3E5B84),
                                fontWeight: FontWeight.w600, // 400 weight
                                fontSize: 16, // 32px
                                lineHeight: 1.0,

                                letterSpacing: 1 * 0.04, // 4% of 32px
                                backgroundColor: Color(0xFFb9d6ff),
                              ),
                            ),
                            SizedBox(height: 24),
                            FutureBuilder<bool>(
                              future: SharedPreferencesHelper.isInWishlist(
                                product!.id.toString(),
                              ),
                              builder: (context, snapshot) {
                                final isInWishlist = snapshot.data ?? false;
                                return GestureDetector(
                                  onTap: () async {
                                    bool isLoggedIn =
                                        await _isLoggedIn(); // Await login status
                                    if (!isLoggedIn) {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.transparent,
                                        builder:
                                            (BuildContext context) =>
                                                const LoginPage(),
                                      );
                                      return;
                                    }

                                    if (isInWishlist) {
                                      // Product already in wishlist
                                      widget.onWishlistChanged?.call(
                                        'Already in wishlist',
                                      );
                                    } else {
                                      // Add product to wishlist
                                      await SharedPreferencesHelper.addToWishlist(
                                        product!.id.toString(),
                                      );
                                      widget.onWishlistChanged?.call(
                                        'Product Added to Wishlist',
                                      );
                                      setState(() {});
                                    }
                                  },
                                  child: BarlowText(
                                    text: "WISHLIST",
                                    color: const Color(0xFF3E5B84),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    lineHeight: 1.0,
                                    letterSpacing: 1 * 0.04,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 650),
          ],
        ),
      ],
    );
  }

  Widget infoTile({
    required String svgAssetPath, // change from IconData to String
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: SvgPicture.asset(
            svgAssetPath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
