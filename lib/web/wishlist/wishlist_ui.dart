import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/cart_loader.dart';
import '../../component/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/routes.dart';
import '../../component/shared_preferences.dart';
import '../cart/cart_panel.dart';
import '../home_page_web/gridview/animation_gridview.dart';

class WishlistUiWeb extends StatefulWidget {
  const WishlistUiWeb({super.key});

  @override
  State<WishlistUiWeb> createState() => _WishlistUiWebState();
}

class _WishlistUiWebState extends State<WishlistUiWeb> {
  List<Product> productList = [];
  bool isLoading = true;
  String errorMessage = "";
  List<bool> _isHoveredList = [];
  List<bool> _wishlistStates = [];

  void _initializeStates(int count) {
    if (_isHoveredList.length != count) {
      _isHoveredList = List.filled(count, false);
    }
    if (_wishlistStates.length != count) {
      _wishlistStates = List.filled(count, false);
    }
  }

  @override
  void initState() {
    super.initState();
    initWishlist();
  }

  Future<void> initWishlist() async {
    try {
      List<String> storedIds = await SharedPreferencesHelper.getWishlist();
      List<Product> fetchedProducts = [];

      for (String id in storedIds) {
        // Convert the String ID to int before passing to fetchProductById
        final int? productId = int.tryParse(id);
        if (productId != null) {
          final product = await ApiHelper.fetchProductById(productId);
          if (product != null) {
            fetchedProducts.add(product);
          }
        }
      }

      setState(() {
        productList = fetchedProducts;
        _isHoveredList.addAll(List.filled(fetchedProducts.length, false));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load wishlist";
        isLoading = false;
      });
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final isInWishlist = await SharedPreferencesHelper.isInWishlist(productId);

    if (isInWishlist) {
      await SharedPreferencesHelper.removeFromWishlist(productId);
    } else {
      await SharedPreferencesHelper.addToWishlist(productId);
    }

    // Refresh the wishlist
    await initWishlist();
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

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 292, top: 24, right: 140),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CralikaFont(
                  text: "Wishlist",
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  lineHeight: 36 / 32,
                  letterSpacing: 1.28,
                  color: const Color(0xFF414141),
                ),
                const SizedBox(height: 13),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BarlowText(
                      text: "My Account",
                      color: const Color(0xFF3E5B84),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      route: AppRoutes.myAccount,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF3E5B84),
                      onTap: () {
                        context.go(AppRoutes.myAccount);
                      },
                    ),
                    const SizedBox(width: 32),

                    BarlowText(
                      text: "My Orders",
                      color: const Color(0xFF3E5B84),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.myOrder,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF3E5B84),
                      onTap: () {
                        context.go(AppRoutes.myOrder);
                      },
                    ),
                    const SizedBox(width: 32),

                    BarlowText(
                      text: "Wishlist",
                      color: const Color(0xFF3E5B84),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                      route: AppRoutes.wishlist,
                      enableUnderlineForActiveRoute: true,
                      decorationColor: const Color(0xFF3E5B84),
                      onTap: () {
                        context.go(AppRoutes.wishlist);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CralikaFont(
                      text: "${productList.length} Items Added",
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      lineHeight: 36 / 32,
                      letterSpacing: 1.28,
                      color: const Color(0xFF414141),
                    ),
                    const SizedBox(height: 24),

                    if (productList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 200),
                        child: Column(
                          children: [
                            SvgPicture.asset("assets/icons/notFound.svg"),
                            SizedBox(height: 20),
                            CralikaFont(text: "No product added!"),
                            SizedBox(height: 10),
                            BarlowText(
                              text:
                                  "Browse our catalog and heart the items you like! They will appear here.",
                              fontSize: 18,
                              textAlign: TextAlign.center, // Add this line
                            ),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () {
                                context.go(AppRoutes.catalog);
                              },
                              child: BarlowText(
                                text: "BROWSE OUR CATALOG",
                                backgroundColor: Color(0xFFb9d6ff),
                                color: Color(0xFF3E5B84),
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 23,
                                mainAxisSpacing: 23,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            final product = productList[index];

                            return MouseRegion(
                              onEnter:
                                  (_) => setState(
                                    () => _isHoveredList[index] = true,
                                  ),
                              onExit:
                                  (_) => setState(
                                    () => _isHoveredList[index] = false,
                                  ),
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
                                            child: AnimatedZoomImage(
                                              imageUrl:
                                                  product.thumbnail ??
                                                  "assets/home_page/gridview_img.jpeg",
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          top: imageHeight * 0.04,
                                          left: imageWidth * 0.05,
                                          right: imageWidth * 0.05,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: null,
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        imageHeight * 0.025,
                                                    horizontal:
                                                        imageWidth * 0.08,
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
                                                  "10% OFF",
                                                  style: TextStyle(
                                                    fontSize: imageWidth * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                              GestureDetector(
                                                onTap: () async {
                                                  await toggleWishlist(
                                                    product.id.toString(),
                                                  );
                                                },
                                                child: SvgPicture.asset(
                                                  'assets/home_page/IconWishlist.svg',
                                                  width: imageWidth * 0.10,
                                                  height: imageHeight * 0.05,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: imageHeight * 0.02,
                                          left: imageWidth * 0.02,
                                          right: imageWidth * 0.02,
                                          child: AnimatedOpacity(
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            opacity:
                                                _isHoveredList[index]
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
                                                    text:
                                                        product.name ??
                                                        "Product Name",
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                    fontSize: imageWidth * 0.05,
                                                    lineHeight: 1.2,
                                                    letterSpacing:
                                                        imageWidth * 0.002,
                                                  ),
                                                  SizedBox(
                                                    height: imageHeight * 0.03,
                                                  ),
                                                  BarlowText(
                                                    text:
                                                        "Rs. ${product.price ?? '0'}",
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        imageWidth * 0.040,
                                                    lineHeight: 1.0,
                                                  ),
                                                  SizedBox(
                                                    height: imageHeight * 0.03,
                                                  ),
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          context.go(
                                                            AppRoutes.productDetails(
                                                              product.id,
                                                            ),
                                                          );
                                                        },
                                                        child: BarlowText(
                                                          text: "VIEW",
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              imageWidth *
                                                              0.040,
                                                          lineHeight: 1.0,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            imageWidth * 0.02,
                                                      ),
                                                      BarlowText(
                                                        text: " / ",
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            imageWidth * 0.040,
                                                        lineHeight: 1.0,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            imageWidth * 0.02,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            barrierColor:
                                                                Colors
                                                                    .transparent,
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              cartNotifier
                                                                  .refresh();
                                                              return CartPanelOverlay(
                                                                productId:
                                                                    product.id,
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: BarlowText(
                                                          text: "ADD TO CART",
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              imageWidth *
                                                              0.040,
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
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
