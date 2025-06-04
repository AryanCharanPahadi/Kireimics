import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../../component/product_details/product_details_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../component/animation_gridview.dart';
import '../cart/cart_panel.dart';

class ProductGridView extends StatefulWidget {
  final Function(String)? onWishlistChanged;
  final ProductController productController;

  const ProductGridView({
    super.key,
    required this.productController,
    this.onWishlistChanged,
  });

  @override
  State<ProductGridView> createState() => _ProductGridViewState();
}

class _ProductGridViewState extends State<ProductGridView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
    return Obx(() {
      if (widget.productController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (widget.productController.errorMessage.isNotEmpty) {
        return Center(
          child: Text("Error: ${widget.productController.errorMessage}"),
        );
      }

      if (widget.productController.products.isEmpty) {
        return const Center(child: Text("No products found"));
      }

      return Container(
        width: 1301,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 4 : 3,
            crossAxisSpacing: 23,
            mainAxisSpacing: 23,
            childAspectRatio: 0.9,
          ),
          itemCount: widget.productController.products.length,
          itemBuilder: (context, index) {
            return ProductGridItem(
              product: widget.productController.products[index],
              onWishlistChanged: widget.onWishlistChanged,
            );
          },
        ),
      );
    });
  }
}

class ProductGridItem extends StatefulWidget {
  final dynamic product;
  final Function(String)? onWishlistChanged;

  const ProductGridItem({
    super.key,
    required this.product,
    this.onWishlistChanged,
  });

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final ProductController _productController = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    _productController.initWishlistStatus(widget.product.id.toString());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: fetchStockQuantity(widget.product.id.toString()),
      builder: (context, snapshot) {
        final quantity = snapshot.data;
        final isOutOfStock = quantity == 0;

        return MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _controller.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _controller.reverse();
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
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _animation.value,
                              child: GestureDetector(
                                onTap:
                                    isOutOfStock
                                        ? null
                                        : () {
                                          context.go(
                                            AppRoutes.productDetails(
                                              widget.product.id,
                                            ),
                                          );
                                        },
                                child: AnimatedZoomImage(
                                  imageUrl: widget.product.thumbnail,
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
                          ), // Shadow overlay
                        ),
                      ),
                    // Rest of your Positioned widgets and UI remain unchanged
                    Positioned(
                      top: imageHeight * 0.04,
                      left: imageWidth * 0.05,
                      right: imageWidth * 0.05,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = constraints.maxWidth;

                          // Responsive scaling for 800–1400px
                          double getResponsiveValue(double min, double max) {
                            if (screenWidth <= 800) return min;
                            if (screenWidth >= 1400) return max;
                            return min +
                                ((max - min) *
                                    ((screenWidth - 800) / (1400 - 800)));
                          }

                          double paddingVertical = getResponsiveValue(6, 10);

                          if (isOutOfStock) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SvgPicture.asset(
                                    "assets/home_page/outofstock.svg",
                                    height: 25,
                                    width: 25,
                                  ),
                                ),
                                FutureBuilder<bool>(
                                  future: SharedPreferencesHelper.isInWishlist(
                                    widget.product.id.toString(),
                                  ),
                                  builder: (context, snapshot) {
                                    final isInWishlist = snapshot.data ?? false;
                                    return GestureDetector(
                                      onTap: () async {
                                        if (isInWishlist) {
                                          await SharedPreferencesHelper.removeFromWishlist(
                                            widget.product.id.toString(),
                                          );
                                          widget.onWishlistChanged?.call(
                                            'Product Removed From Wishlist',
                                          );
                                        } else {
                                          await SharedPreferencesHelper.addToWishlist(
                                            widget.product.id.toString(),
                                          );
                                          widget.onWishlistChanged?.call(
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
                          }

                          // Normal UI when product is in stock
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(
                                builder: (context) {
                                  final List<Widget> badges = [];

                                  if (widget.product.isMakerChoice == 1) {
                                    badges.add(
                                      SvgPicture.asset(
                                        "assets/home_page/maker_choice.svg",
                                        height: 65,
                                      ),
                                    );
                                  }

                                  if (quantity != null && quantity < 2) {
                                    if (badges.isNotEmpty)
                                      badges.add(SizedBox(height: 10));
                                    badges.add(
                                      SvgPicture.asset(
                                        "assets/home_page/fewPiecesLeft.svg",
                                        height: 25,
                                        width: 25,
                                      ),
                                    );
                                  }

                                  if (widget.product.discount != 0) {
                                    if (badges.isNotEmpty)
                                      badges.add(SizedBox(height: 10));
                                    badges.add(
                                      ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: paddingVertical,
                                            horizontal: 30,
                                          ),
                                          backgroundColor: const Color(
                                            0xFFF46856,
                                          ),
                                          disabledBackgroundColor: const Color(
                                            0xFFF46856,
                                          ),
                                          disabledForegroundColor: Colors.white,
                                          elevation: 0,
                                          side: BorderSide.none,
                                        ),
                                        child: Text(
                                          "${widget.product.discount}% OFF",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: badges,
                                  );
                                },
                              ),
                              Spacer(),
                              FutureBuilder<bool>(
                                future: SharedPreferencesHelper.isInWishlist(
                                  widget.product.id.toString(),
                                ),
                                builder: (context, snapshot) {
                                  final isInWishlist = snapshot.data ?? false;

                                  return GestureDetector(
                                    onTap: () async {
                                      if (isInWishlist) {
                                        await SharedPreferencesHelper.removeFromWishlist(
                                          widget.product.id.toString(),
                                        );
                                        widget.onWishlistChanged?.call(
                                          'Product Removed From Wishlist',
                                        );
                                      } else {
                                        await SharedPreferencesHelper.addToWishlist(
                                          widget.product.id.toString(),
                                        );
                                        widget.onWishlistChanged?.call(
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
                      bottom: imageHeight * 0.02,
                      left: imageWidth * 0.02,
                      right: imageWidth * 0.02,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isHovered ? 1.0 : 0.0, // Show on hover
                        child: Container(
                          width: imageWidth * 0.95,
                          height: imageHeight * 0.35,
                          padding: EdgeInsets.symmetric(
                            horizontal: imageWidth * 0.05,
                            vertical: imageHeight * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF30578E).withOpacity(0.8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CralikaFont(
                                text: widget.product.name,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 16,
                                lineHeight: 1.2,
                                letterSpacing: imageWidth * 0.002,
                                maxLines: 2,
                              ),
                              SizedBox(height: imageHeight * 0.01),
                              BarlowText(
                                text:
                                    "Rs. ${widget.product.price.toStringAsFixed(2)}",
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                lineHeight: 1.0,
                              ),
                              SizedBox(height: imageHeight * 0.04),
                              if (isOutOfStock)
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context.go(
                                          AppRoutes.productDetails(
                                            widget.product.id,
                                          ),
                                        );
                                      },
                                      child: BarlowText(
                                        text: "VIEW",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        lineHeight: 1.0,
                                        enableHoverBackground: true,
                                        hoverBackgroundColor: Colors.white,
                                        hoverTextColor: Color(0xFF30578E),
                                      ),
                                    ),
                                    SizedBox(width: imageWidth * 0.02),
                                    Text(
                                      "/",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: imageWidth * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        widget.onWishlistChanged?.call(
                                          "We'll notify you when this product is back in stock.",
                                        );
                                      },
                                      child: BarlowText(
                                        text: "NOTIFY ME",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        lineHeight: 1.0,
                                        enableHoverBackground: true,
                                        hoverBackgroundColor: Colors.white,
                                        hoverTextColor: Color(0xFF30578E),
                                      ),
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
                                            widget.product.id,
                                          ),
                                        );
                                      },
                                      child: BarlowText(
                                        text: "VIEW",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        lineHeight: 1.0,
                                        enableHoverBackground: true,
                                        hoverBackgroundColor: Colors.white,
                                        hoverTextColor: Color(0xFF30578E),
                                      ),
                                    ),
                                    SizedBox(width: imageWidth * 0.02),
                                    Text(
                                      "/",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            GoogleFonts.barlow().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: imageWidth * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            cartNotifier.refresh();
                                            return CartPanel(
                                              productId: widget.product.id,
                                            );
                                          },
                                        );
                                        widget.onWishlistChanged?.call(
                                          'Product Added To Cart',
                                        );
                                      },
                                      child: BarlowText(
                                        text: "ADD TO CART",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        lineHeight: 1.0,
                                        enableHoverBackground: true,
                                        hoverBackgroundColor: Colors.white,
                                        hoverTextColor: Color(0xFF30578E),
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
  }
}
