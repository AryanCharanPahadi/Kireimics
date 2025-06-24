import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/no_result_found/no_product_yet.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/catalog_sale_gridview/catalog_controller1.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../web_desktop_common/notify_me/notify_me.dart';
import '../component/badges_mobile.dart';

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
  bool _isOutOfStock = false; // Track stock status of the main product

  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  @override
  void didUpdateWidget(ProductDetailsMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      setState(() {
        product = null;
        isLoading = true;
        errorMessage = "";
        relatedProducts = [];
        _isOutOfStock = false; // Reset stock status
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
        // Fetch stock quantity for the main product
        final stockQuantity = await fetchStockQuantity(
          widget.productId.toString(),
        );
        setState(() {
          product = fetchedProduct;
          _currentMainImage = fetchedProduct.thumbnail;
          _otherImages = List.from(fetchedProduct.otherImages);
          _isOutOfStock = stockQuantity == 0; // Set stock status
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

    List<Product> displayedProducts = [];
    if (relatedProducts.isNotEmpty) {
      for (int i = 0; i <= 1; i++) {
        int index = (_currentIndex) % relatedProducts.length;
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
                      color: Color(0xFF30578E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      onTap: () {
                        context.go(AppRoutes.catalog);
                      },
                    ),
                    SizedBox(width: 9.0),
                    SvgPicture.asset(
                      'assets/icons/right_icon.svg',
                      width: 20,
                      height: 20,
                      color: Color(0xFF30578E),
                    ),
                    SizedBox(width: 9.0),
                    BarlowText(
                      text: product!.catName,
                      color: Color(0xFF30578E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      onTap: () {
                        context.go(
                          '${AppRoutes.catalog}?cat_id=${product!.catId}', // Use URL parameter
                        );
                      },
                    ),
                    SizedBox(width: 9.0),
                    SvgPicture.asset(
                      'assets/icons/right_icon.svg',
                      width: 20,
                      height: 20,
                      color: Color(0xFF30578E),
                    ),
                    SizedBox(width: 9.0),
                    BarlowText(
                      text: "View Details",
                      color: Color(0xFF30578E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.productDetails(product!.id),
                      enableUnderlineForActiveRoute: true,
                      decorationColor: Color(0xFF30578E),
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Stack(
                  children: [
                    ColorFiltered(
                      colorFilter:
                          _isOutOfStock
                              ? const ColorFilter.matrix(<double>[
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
                        _currentMainImage!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      _otherImages.length < 3
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      _otherImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final imageUrl = entry.value;

                        final imageWidget = GestureDetector(
                          onTap: () => _swapImageWithMain(index),
                          child: Stack(
                            children: [
                              ColorFiltered(
                                colorFilter:
                                    _isOutOfStock
                                        ? const ColorFilter.matrix(<double>[
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
                                  imageUrl,
                                  width: 106,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 106,
                                        height: 122,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );

                        // Add 8-pixel left padding to the first image if less than 3
                        return _otherImages.length < 3 && index == 0
                            ? Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: imageWidget,
                            )
                            : imageWidget;
                      }).toList(),
                ),
                SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CralikaFont(
                      text: product!.name,
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      lineHeight: 36 / 32,
                      letterSpacing: 32 * 0.04,
                      color: Color(0xFF30578E),
                    ),
                    SizedBox(height: 9.0),
                    BarlowText(
                      text: product!.catName,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      color: Color(0xFF30578E),
                      onTap: () {
                        context.go(
                          '${AppRoutes.catalog}?cat_id=${product!.catId}', // Use URL parameter
                        );
                      },
                    ),
                    SizedBox(height: 14),
                    BarlowText(
                      text: product!.price.toString(),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      color: Color(0xFF30578E),
                    ),
                    SizedBox(height: 14),
                    BarlowText(
                      text: product!.dimensions,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      color: Color(0xFF414141),
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: 508,
                      child: BarlowText(
                        text: product!.description,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        lineHeight: 1.0,
                        letterSpacing: 1 * 0.04,
                        color: Color(0xFF414141),
                        softWrap: true,
                      ),
                    ),
                    if (_isOutOfStock) SizedBox(height: 44),
                    if (_isOutOfStock)
                      SvgPicture.asset(
                        "assets/home_page/outofstock.svg",
                        height: 32,
                      ),
                    SizedBox(height: 32),
                    GestureDetector(
                      onTap:
                          _isOutOfStock
                              ? () {
                                widget.onWishlistChanged?.call(
                                  "We'll notify you when this product is back in stock.",
                                );
                              }
                              : () async {
                                // 1. Call the wishlist changed callback immediately
                                widget.onWishlistChanged?.call(
                                  'Product Added To Cart',
                                );

                                // 2. Store the product ID in SharedPreferences
                                await SharedPreferencesHelper.addProductId(
                                  product!.id,
                                );

                                // 3. Refresh the cart state
                                cartNotifier.refresh();

                                // Note: Removed the Future.delayed and showDialog parts
                              },
                      child: BarlowText(
                        text: _isOutOfStock ? "NOTIFY ME" : "ADD TO CART",
                        color: Color(0xFF30578E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        lineHeight: 1.0,
                        letterSpacing: 1 * 0.04,
                        backgroundColor:
                            _isOutOfStock
                                ? Colors.grey[300]
                                : Color(0xFFb9d6ff),
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
                            bool isLoggedIn = await _isLoggedIn();
                            if (!isLoggedIn) {
                              context.go(AppRoutes.logIn);
                              return;
                            }
                            if (isInWishlist) {
                              widget.onWishlistChanged?.call(
                                'Already in wishlist',
                              );
                            } else {
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
                            color: Color(0xFF30578E),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
                            iconPath = 'assets/icons/info.svg';
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
          SizedBox(height: 24),
          if (relatedProducts.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        context.go(
                          '${AppRoutes.catalog}?cat_id=${product!.catId}', // Use URL parameter
                        );
                      },
                      child: BarlowText(
                        text: "BROWSE OUR CATALOG",
                        textAlign: TextAlign.right,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        lineHeight: 1.0,
                        letterSpacing: 0.64,
                        color: Color(0xFF30578E),
                        backgroundColor: Color(0xFFb9d6ff),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 27),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(1, (index) {
                      // Changed to generate only 1 item
                      final relatedProduct =
                          relatedProducts[_currentIndex %
                              relatedProducts.length]; // Use single product
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
                              height: 330,
                              width: 170,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRect(
                                        child: GestureDetector(
                                          onTap: () {
                                            context.go(
                                              AppRoutes.productDetails(
                                                relatedProduct.id,
                                              ),
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
                                              relatedProduct.thumbnail,
                                              height: 196,
                                              width: 170,
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
                                            List<Widget> badges = [];

                                            return ProductBadgesRow(
                                              isOutOfStock: isOutOfStock,
                                              isMobile: isMobile,
                                              quantity: quantity,
                                              product: relatedProduct,
                                              onWishlistChanged:
                                                  widget.onWishlistChanged,
                                              index: index,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  CralikaFont(
                                    text: relatedProduct.name,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF30578E),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  if (!isOutOfStock) ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (relatedProduct.discount != 0)
                                          Text(
                                            "Rs. ${relatedProduct.price.toStringAsFixed(2)}",
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
                                        if (relatedProduct.discount != 0)
                                          SizedBox(width: 6),
                                        BarlowText(
                                          text:
                                              relatedProduct.discount != 0
                                                  ? "Rs. ${(relatedProduct.price * (1 - relatedProduct.discount / 100)).toStringAsFixed(2)}"
                                                  : "Rs. ${relatedProduct.price.toStringAsFixed(2)}",
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
                                          "Rs. ${relatedProduct.price.toStringAsFixed(2)}",
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
                                                relatedProduct.id,
                                              );
                                              cartNotifier.refresh();
                                            },
                                    child:
                                        isOutOfStock
                                            ? NotifyMeButton(
                                              productId: relatedProduct.id,
                                              onWishlistChanged:
                                                  widget.onWishlistChanged,
                                              onErrorWishlistChanged: (error) {
                                                widget.onWishlistChanged?.call(
                                                  error,
                                                );
                                              },
                                            )
                                            : Text(
                                              "ADD TO CART",
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
    required String svgAssetPath,
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
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
