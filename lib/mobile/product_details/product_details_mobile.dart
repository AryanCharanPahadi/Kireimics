import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/routes.dart';

class ProductDetailsMobile extends StatefulWidget {
  final int productId;

  const ProductDetailsMobile({Key? key, required this.productId})
    : super(key: key);
  @override
  State<ProductDetailsMobile> createState() => _ProductDetailsMobileState();
}

class _ProductDetailsMobileState extends State<ProductDetailsMobile> {
  Product? product;
  bool isLoading = true;
  String errorMessage = "";
  List<Product> relatedProducts = [];
  int _currentIndex = 0; // Tracks the starting index of displayed products
  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  void _showNextProducts() {
    setState(() {
      if (relatedProducts.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % relatedProducts.length;
      }
    });
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

  final List<bool> _isHoveredList = List.generate(3, (_) => false);
  final List<bool> _wishlistStates = List.filled(6, false);

  Future<void> fetchProduct() async {
    try {
      final fetchedProduct = await ApiHelper.fetchProductById(widget.productId);
      if (fetchedProduct != null) {
        setState(() {
          product = fetchedProduct;
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
                  product!.thumbnail, // Use product image path
                  width: 346,
                  height: 444,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
                Row(
                  children:
                      product!.otherImages.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Image.network(
                            imageUrl,
                            width: 106,
                            height: 122,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 106,
                                  height: 122,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image),
                                ),
                          ),
                        );
                      }).toList(),
                ),
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
                      text: product!.price,

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
                    BarlowText(
                      text: "ADD TO CART",
                      color: Color(0xFF3E5B84),
                      fontWeight: FontWeight.w600, // 400 weight
                      fontSize: 16, // 32px
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04, // 4% of 32px
                      backgroundColor: Color(0xFFb9d6ff),
                    ),
                    SizedBox(height: 24),
                    BarlowText(
                      text: "WISHLIST",
                      color: Color(0xFF3E5B84),
                      fontWeight: FontWeight.w600, // 400 weight
                      fontSize: 16, // 32px
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04, // 4% of 32px
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
          CralikaFont(text: "Other Products you may like"),
          SizedBox(height: 10),

          Column(
            children: [
              relatedProducts.isEmpty
                  ? Center(
                    child: Text(
                      "No product found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(displayedProducts.length, (
                        index,
                      ) {
                        final relatedProduct = displayedProducts[index];
                        return Padding(
                          padding: EdgeInsets.only(right: 14.0),
                          child: MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                _isHoveredList[index] = true;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                _isHoveredList[index] = false;
                              });
                            },
                            child: SizedBox(
                              height: 260,
                              width: 260,
                              child: Stack(
                                children: [
                                  // Product Image
                                  ClipRect(
                                    child: GestureDetector(
                                      onTap: () {
                                        context.go(
                                          AppRoutes.productDetails(
                                            relatedProduct.id,
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        relatedProduct.thumbnail,
                                        height: 260,
                                        width: 260,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Discount Badge & Wishlist
                                  Positioned(
                                    top: 10,
                                    left: 6,
                                    right: 6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            backgroundColor: const Color(
                                              0xFFF46856,
                                            ),
                                            disabledBackgroundColor:
                                                const Color(0xFFF46856),
                                            disabledForegroundColor:
                                                Colors.white,
                                            elevation: 0,
                                            side: BorderSide.none,
                                          ),
                                          child: Text(
                                            "${relatedProduct.discount}% OFF",
                                            style: TextStyle(
                                              fontFamily:
                                                  GoogleFonts.barlow()
                                                      .fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.48,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _wishlistStates[index] =
                                                  !_wishlistStates[index];
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            _wishlistStates[index]
                                                ? 'assets/home_page/IconWishlist.svg'
                                                : 'assets/home_page/IconWishlistEmpty.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Hover Info
                                  Positioned(
                                    bottom: 9,
                                    left: 8,
                                    right: 7,
                                    child: AnimatedOpacity(
                                      duration: Duration(milliseconds: 300),
                                      opacity:
                                          _isHoveredList[index] ? 1.0 : 0.0,
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
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CralikaFont(
                                              text: relatedProduct.name,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 15,
                                              lineHeight: 1.2,
                                              letterSpacing: 4,
                                            ),
                                            SizedBox(height: 8),
                                            BarlowText(
                                              text:
                                                  "Rs. ${relatedProduct.price}",
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              lineHeight: 1.0,
                                            ),
                                            SizedBox(height: 14),
                                            Row(
                                              children: [
                                                BarlowText(
                                                  text: "VIEW",
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  lineHeight: 1.0,
                                                ),
                                                SizedBox(width: 5),
                                                BarlowText(
                                                  text: " / ",
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  lineHeight: 1.0,
                                                ),
                                                SizedBox(width: 5),
                                                GestureDetector(
                                                  onTap: () {
                                                    // Add to cart logic
                                                  },
                                                  child: BarlowText(
                                                    text: "ADD TO CART",
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                    lineHeight: 1.0,
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
                          ),
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
