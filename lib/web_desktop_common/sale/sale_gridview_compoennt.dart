import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/cart_length/cart_loader.dart';
import 'package:kireimics/component/product_details/product_details_modal.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/component/shared_preferences/shared_preferences.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/web_desktop_common/sale/sale_modal.dart';
import 'package:kireimics/web_desktop_common/sale/wishlistBadgesSAle.dart';

import '../../component/api_helper/api_helper.dart';
import '../cart/cart_panel.dart';
import '../component/badges_web_desktop.dart';
import '../component/height_weight.dart';

class SaleProductGrid extends StatelessWidget {
  final List<SaleModal> productList;
  final Function(String)? onWishlistChanged;
  final List<bool> isHoveredList;
  final Function(int, bool) onHoverChanged;

  const SaleProductGrid({
    super.key,
    required this.productList,
    this.onWishlistChanged,
    required this.isHoveredList,
    required this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;



    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLargeScreen ? 4 : 3,
        crossAxisSpacing: 23,
        mainAxisSpacing: 23,
        childAspectRatio: 0.9,
      ),
      itemCount: productList.length,
      itemBuilder: (context, index) {
        final product = productList[index];
        return SaleProductGridItem(
          product: product,
          index: index,
          isHovered: isHoveredList[index],
          onHoverChanged: onHoverChanged,
          onWishlistChanged: onWishlistChanged,
          isLargeScreen: isLargeScreen,
        );
      },
    );
  }
}

class SaleProductGridItem extends StatefulWidget {
  final SaleModal product;
  final int index;
  final bool isHovered;
  final Function(int, bool) onHoverChanged;
  final Function(String)? onWishlistChanged;
  final bool isLargeScreen;

  const SaleProductGridItem({
    super.key,
    required this.product,
    required this.index,
    required this.isHovered,
    required this.onHoverChanged,
    this.onWishlistChanged,
    required this.isLargeScreen,
  });

  @override
  State<SaleProductGridItem> createState() => _SaleProductGridItemState();
}

class _SaleProductGridItemState extends State<SaleProductGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Smooth hover transition
    );

    _animation = Tween<double>(
      begin: 1.0, // Normal scale
      end: 1.1, // Zoom in on hover
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Initialize animation based on initial hover state
    if (widget.isHovered) {
      _controller.forward();
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
  void didUpdateWidget(covariant SaleProductGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation when hover state changes
    if (widget.isHovered != oldWidget.isHovered) {
      if (widget.isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
        if (isOutOfStock) {
          return Container();
        }
        return MouseRegion(
          onEnter:
              isOutOfStock
                  ? null
                  : (_) => widget.onHoverChanged(widget.index, true),
          onExit:
              isOutOfStock
                  ? null
                  : (_) => widget.onHoverChanged(widget.index, false),
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
                              child: Image.network(
                                widget.product.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

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

                          double paddingVertical = getResponsiveValue(6, 12);

                          // Normal UI when product is in stock
                          return WishlistBadgeRowSale(
                            product: widget.product,
                            isOutOfStock: isOutOfStock,
                            quantity: quantity,
                            onWishlistChanged: widget.onWishlistChanged,
                            paddingVertical: paddingVertical,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: imageHeight * 0.02,
                      left: imageWidth * 0.02,
                      right: imageWidth * 0.02,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: widget.isHovered && !isOutOfStock ? 1.0 : 0.0,
                        child: Container(
                          width: ResponsiveUtil(
                            context,
                          ).getResponsiveWidth(imageWidth),
                          height: ResponsiveUtil(
                            context,
                          ).getResponsiveHeight(imageHeight),
                          padding: EdgeInsets.symmetric(
                            horizontal: imageWidth * 0.05,
                            vertical: imageHeight * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF30578E).withOpacity(0.8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CralikaFont(
                                text: widget.product.name,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                lineHeight: 1.2,
                                letterSpacing: imageWidth * 0.002,
                                maxLines: 2,
                              ),
                              SizedBox(height: imageHeight * 0.01),
                              if (!isOutOfStock) ...[
                                Row(
                                  children: [
                                    // Original price with strikethrough
                                    if (widget.product.discount != 0)
                                      Text(
                                        "Rs. ${widget.product.price.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          height: 1.2,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Colors.white
                                              .withOpacity(
                                                0.7,
                                              ), // Match strikethrough color
                                          fontFamily:
                                              GoogleFonts.barlow()
                                                  .fontFamily, // Match Barlow font
                                        ),
                                      ),
                                    if (widget.product.discount != 0)
                                      SizedBox(width: 8),
                                    // Discounted price
                                    BarlowText(
                                      text:
                                          widget.product.discount != 0
                                              ? "Rs. ${(widget.product.price * (1 - widget.product.discount / 100)).toStringAsFixed(2)}"
                                              : "Rs. ${widget.product.price.toStringAsFixed(2)}",
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      lineHeight: 1.2,
                                    ),
                                  ],
                                ),
                              ],

                              SizedBox(height: imageHeight * 0.04),
                              Row(
                                children: [
                                  GestureDetector(
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
                                  BarlowText(
                                    text: "ADD TO CART",
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    lineHeight: 1.0,
                                    enableHoverBackground: true,
                                    hoverBackgroundColor: Colors.white,
                                    hoverTextColor: Color(0xFF30578E),
                                    onTap: () async {
                                      // 1. Call the wishlist changed callback immediately
                                      widget.onWishlistChanged?.call(
                                        'Product Added To Cart',
                                      );

                                      // 2. Store the product ID in SharedPreferences
                                      await SharedPreferencesHelper.addProductId(
                                        widget.product.id,
                                      );

                                      // 3. Refresh the cart state
                                      cartNotifier.refresh();

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
  }
}
