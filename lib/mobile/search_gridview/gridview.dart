import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../web_desktop_common/notify_me/notify_me.dart';
import '../component/badges_mobile.dart';

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
          return const Center(
            child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text("Error: ${controller.errorMessage}"));
        }

        final resultCount = controller.filteredProducts.length;
        final resultText =
            resultCount == 1
                ? '1 Result'
                : resultCount == 0
                ? '0 Result'
                : '$resultCount Results';

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
              fontSize: 24,
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

                                      return ProductBadgesRow(
                                        isOutOfStock: isOutOfStock,
                                        isMobile: isMobile,
                                        quantity: quantity,
                                        product: product,
                                        onWishlistChanged:
                                            widget.onWishlistChanged,

                                        index: index,
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
                                            ? null
                                            : () async {
                                              widget.onWishlistChanged?.call(
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
                                                  widget.onWishlistChanged,
                                              onErrorWishlistChanged: (error) {
                                                widget.onWishlistChanged?.call(
                                                  error,
                                                );
                                              },
                                            )
                                            : BarlowText(
                                          text:   "ADD TO CART",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
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
