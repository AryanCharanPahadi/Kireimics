import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/app_routes/routes.dart';
import '../../../component/categories/categories_controller.dart';
import '../../../component/product_details/product_details_controller.dart'
    show ProductController;
import '../../../component/product_details/product_details_modal.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';

class CatalogViewAllMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final int catId;

  const CatalogViewAllMobile({
    super.key,
    this.onWishlistChanged,
    required this.catId,
  });

  @override
  State<CatalogViewAllMobile> createState() => _CatalogViewAllMobileState();
}

class _CatalogViewAllMobileState extends State<CatalogViewAllMobile> {
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );
  List<Product> productList = [];
  bool isLoading = false;
  List<bool> _isHoveredList = [];
  List<bool> _wishlistStates = [];
  List<AnimationController> _controllers = [];

  void _initializeStates(int count) {
    if (_isHoveredList.length != count) {
      _isHoveredList = List.filled(count, false);
    }
    if (_wishlistStates.length != count) {
      _wishlistStates = List.filled(count, false);
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
      print("Error fetching stock: $e");
      return null;
    }
  }

  final ProductController controller = Get.put(ProductController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 14, right: 14),
      child: Obx(() {
        if (productList.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              BarlowText(
                text: "${productList.length} PRODUCT FOUND",
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF414141),
              ),
              SizedBox(height: 40),
              Center(child: SvgPicture.asset("assets/icons/notFound.svg")),
              SizedBox(height: 20),
              Center(child: CralikaFont(text: "No results found!")),
              SizedBox(height: 10),
              Center(
                child: BarlowText(
                  text:
                      "Looks like the product you're looking for is not available. Please try a different keyword, or check the spelling!",
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  context.go(AppRoutes.catalog);
                },
                child: Center(
                  child: BarlowText(
                    text: "BROWSE OUR CATALOG",
                    hoverBackgroundColor: Color(0xFFb9d6ff),
                    enableHoverBackground: true,
                    color: Color(0xFF3E5B84),
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          );
        }
        if (controller.products.isNotEmpty) {
          _initializeStates(controller.products.length);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            CralikaFont(
              text: "${productList.length} PRODUCT FOUND",
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3E5B84),
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
                  mainAxisSpacing: 5,
                  childAspectRatio: () {
                    double width = MediaQuery.of(context).size.width;
                    if (width > 320 && width <= 410) {
                      return 0.53;
                    } else if (width > 410 && width <= 500) {
                      return 0.59;
                    } else if (width > 500 && width <= 600) {
                      return 0.62;
                    } else if (width > 600 && width <= 700) {
                      return 0.65;
                    } else if (width > 700 && width <= 800) {
                      return 0.67;
                    } else {
                      return 0.50;
                    }
                  }(),
                ),
                itemCount: productList.length,
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
                  final product = productList[index];

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
                                    child: Image.network(
                                      product.thumbnail,
                                      width: cappedWidth,
                                      height: cappedHeight,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isOutOfStock)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
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
                                        // Only return the Out of Stock image, nothing else
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
                                                  SvgPicture.asset(
                                                    "assets/home_page/fewPiecesMobile.svg",
                                                    height: isMobile ? 28 : 32,
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
                                                    onPressed: null,
                                                    style: ElevatedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 30,
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
                                                      side: BorderSide.none,
                                                      minimumSize: const Size(
                                                        0,
                                                        33,
                                                      ), // Optional: Set a smaller minimum height
                                                    ),
                                                    child: Text(
                                                      "${product.discount}% OFF",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            GoogleFonts.barlow()
                                                                .fontFamily,
                                                        fontSize:
                                                            10, // Reduced font size
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                        letterSpacing: 0.48,
                                                      ),
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
                                    color: Color(0xFF3E5B84),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  BarlowText(
                                    text:
                                        "Rs. ${product.price.toStringAsFixed(2)}",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    lineHeight: 1.2,
                                    color: const Color(0xFF3E5B84),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap:
                                        isOutOfStock
                                            ? null
                                            : () {
                                              context.go(
                                                AppRoutes.cartDetails(
                                                  product.id,
                                                ),
                                              );
                                            },
                                    child: BarlowText(
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
