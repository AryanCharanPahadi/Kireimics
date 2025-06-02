import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/no_result_found/no_product_yet.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/catalog_sale_gridview/catalog_controller1.dart';

class ProductDetailsMobile extends StatefulWidget {
  final int productId;
  final Function(String)? onWishlistChanged; // Callback to notify parent

  const ProductDetailsMobile({
    super.key,
    required this.productId,
    this.onWishlistChanged,
  });
  @override
  State<ProductDetailsMobile> createState() => _ProductDetailsMobileState();
}

class _ProductDetailsMobileState extends State<ProductDetailsMobile> {
  Product? product;
  bool isLoading = true;
  String errorMessage = "";
  List<Product> relatedProducts = [];
  int _currentIndex = 0; // Tracks the starting index of displayed products
  String? _currentMainImage; // Track the currently displayed main image
  List<String> _otherImages = []; // Track all other images
  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  void _showPreviousProducts() {
    setState(() {
      print("Back button pressed");

      if (relatedProducts.isNotEmpty) {
        _currentIndex = (_currentIndex - 1) % relatedProducts.length;
        if (_currentIndex < 0) {
          _currentIndex = relatedProducts.length - 1;
        }
      }
    });
  }

  // Add this to handle updates when productId changes
  @override
  void didUpdateWidget(ProductDetailsMobile oldWidget) {
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
                    .where((p) => p.id != widget.productId)
                    .take(3)
                    .toList();
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
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 22, top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BarlowText(
                      text: "Catalog",
                      color: Color(0xFF3E5B84),
                      fontSize: 14,
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
                      width: 20,
                      height: 20,
                      color: Color(0xFF3E5B84),
                    ),
                    SizedBox(width: 9.0),

                    BarlowText(
                      text: product!.catName,
                      color: Color(0xFF3E5B84),
                      fontSize: 14,
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
                      width: 20,
                      height: 20,
                      color: Color(0xFF3E5B84),
                    ),
                    SizedBox(width: 9.0),

                    BarlowText(
                      text: "View Details",
                      color: Color(0xFF3E5B84),
                      fontSize: 14,
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
                SizedBox(height: 20),
                Image.network(
                  _currentMainImage!, // Use the current main image
                  // width: 346,
                  // height: 444,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      _otherImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final imageUrl = entry.value;
                        return GestureDetector(
                          onTap: () => _swapImageWithMain(index),
                          child: Image.network(
                            imageUrl,
                            width:
                                106, // Set a fixed width to control image size
                            height: 122,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 106,
                                  height: 122,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: 24),
                SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CralikaFont(
                      text: product!.name,

                      fontWeight: FontWeight.w400, // 400 weight
                      fontSize: 24.5, // 32px
                      lineHeight:
                          36 /
                          32, // Line height (36px) divided by font size (32px)
                      letterSpacing: 32 * 0.04, // 4% of 32px
                      color: Color(0xFF414141),
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
                      text: product!.price.toString(),

                      fontWeight: FontWeight.w400, // 400 weight
                      fontSize: 14, // 32px
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
                        fontSize: 14, // 32px
                        lineHeight: 1.0,
                        letterSpacing: 1 * 0.04, // 4% of 32px
                        color: Color(0xFF414141),
                        softWrap: true,
                      ),
                    ),

                    SizedBox(height: 44),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRoutes.cartDetails(product!.id));
                      },
                      child: BarlowText(
                        text: "ADD TO CART",
                        color: Color(0xFF3E5B84),
                        fontWeight: FontWeight.w600, // 400 weight
                        fontSize: 14, // 32px
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
                              context.go(AppRoutes.logIn);
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
                            color: Color(0xFF3E5B84),
                            fontWeight: FontWeight.w600, // 400 weight
                            fontSize: 14, // 32px
                            lineHeight: 1.0,
                            letterSpacing: 1 * 0.04, // 4% of 32px
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          SizedBox(
            width: MediaQuery.of(context).size.width,

            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/home_page/background.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF2472e3).withOpacity(0.9),
                    BlendMode.srcATop,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 53,
                  right: 53,
                  top: 32,
                  bottom: 32,
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
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (relatedProducts.isNotEmpty)
                Column(
                  children: [
                    CralikaFont(
                      text: "Other Products\nyou may like",
                      textAlign: TextAlign.right,
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      lineHeight: 27 / 24,
                      letterSpacing: 0.96,
                      color: Color(0xFF414141),
                    ),
                    SizedBox(height: 27),
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
                        fontSize: 14,
                        lineHeight: 1.0,
                        letterSpacing: 0.64,
                        color: Color(0xFF3E5B84),
                        backgroundColor: Color(0xFFb9d6ff),
                      ),
                    ),
                  ],
                ),
              SizedBox(width: 27),
              relatedProducts.isEmpty
                  ? NoProductYet()
                  : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(1, (index) {
                        final relatedProduct = displayedProducts[0];
                        return FutureBuilder<int?>(
                          future: fetchStockQuantity(
                            relatedProduct.id.toString(),
                          ),
                          builder: (context, snapshot) {
                            final quantity = snapshot.data;
                            final isOutOfStock = quantity == 0;

                            return Padding(
                              padding: EdgeInsets.only(right: 14.0),
                              child: SizedBox(
                                height: 300,
                                width: 170,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRect(
                                          child: GestureDetector(
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
                                            child: Image.network(
                                              relatedProduct.thumbnail,
                                              height: 196,
                                              width: 170,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                        Positioned.fill(
                                          child: GestureDetector(
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
                                            child: Image.network(
                                              relatedProduct.thumbnail,
                                              height: 196,
                                              width: 170,
                                              fit: BoxFit.cover,
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
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              bool isMobile =
                                                  constraints.maxWidth < 800;

                                              if (isOutOfStock) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: SvgPicture.asset(
                                                        "assets/home_page/outofstock.svg",
                                                        height: 24,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Builder(
                                                    builder: (context) {
                                                      final List<Widget>
                                                      badges = [];

                                                      if (relatedProduct
                                                              .isMakerChoice ==
                                                          1) {
                                                        badges.add(
                                                          SvgPicture.asset(
                                                            "assets/home_page/maker_choice.svg",
                                                            height:
                                                                isMobile
                                                                    ? 40
                                                                    : 32,
                                                          ),
                                                        );
                                                      }

                                                      if (quantity != null &&
                                                          quantity < 2) {
                                                        if (badges.isNotEmpty)
                                                          badges.add(
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          );
                                                        badges.add(
                                                          SvgPicture.asset(
                                                            "assets/home_page/fewPiecesMobile.svg",
                                                            height:
                                                                isMobile
                                                                    ? 28
                                                                    : 32,
                                                          ),
                                                        );
                                                      }

                                                      if (relatedProduct
                                                              .discount !=
                                                          0) {
                                                        if (badges.isNotEmpty)
                                                          badges.add(
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          );
                                                        badges.add(
                                                          ElevatedButton(
                                                            onPressed: null,
                                                            style: ElevatedButton.styleFrom(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        30,
                                                                    vertical:
                                                                        0, // Reduced vertical padding
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
                                                                  Colors.white,
                                                              elevation: 0,
                                                              side:
                                                                  BorderSide
                                                                      .none,
                                                              minimumSize:
                                                                  const Size(
                                                                    0,
                                                                    33,
                                                                  ), // Optional: Set a smaller minimum height
                                                            ),
                                                            child: Text(
                                                              "${relatedProduct.discount}% OFF",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    GoogleFonts.barlow()
                                                                        .fontFamily,
                                                                fontSize:
                                                                    10, // Reduced font size
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                letterSpacing:
                                                                    0.48,
                                                              ),
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
                                                  FutureBuilder<bool>(
                                                    future:
                                                        SharedPreferencesHelper.isInWishlist(
                                                          relatedProduct.id
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
                                                        onTap:
                                                            isOutOfStock
                                                                ? null
                                                                : () async {
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
                                                                  setState(
                                                                    () {},
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
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    CralikaFont(
                                      text: relatedProduct.name,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Rs. ${relatedProduct.price.toStringAsFixed(2)}",
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
                                    BarlowText(
                                      text: "ADD TO CART",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      lineHeight: 1.2,
                                      letterSpacing: 0.56,
                                      color:
                                          isOutOfStock
                                              ? const Color(
                                                0xFF3E5B84,
                                              ).withOpacity(0.5)
                                              : const Color(0xFF3E5B84),
                                      onTap:
                                          isOutOfStock
                                              ? null
                                              : () {
                                                context.go(
                                                  AppRoutes.cartDetails(
                                                    relatedProduct.id,
                                                  ),
                                                );
                                              },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                  fontWeight: FontWeight.w400,
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
