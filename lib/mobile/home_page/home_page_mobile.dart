import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/mobile/component/aquacollection_card.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/custom_text_form_field/custom_text_form_field.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../component/let_connect.dart';

class HomePageMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final Function(String)? onErrorWishlistChanged; // Callback to notify parent
  const HomePageMobile({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });
  @override
  State<HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<HomePageMobile> {
  final ProductController controller = Get.put(ProductController());

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _anotherMessageController =
      TextEditingController();
  FocusNode _messageFocusNode = FocusNode();
  FocusNode _anotherMessageFocusNode = FocusNode();
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  void _submitForm() {
    // Check validation in order of priority
    if (_nameController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter your name');
      return;
    }

    if (_emailController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter your email');
      return;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      widget.onErrorWishlistChanged?.call('Please enter a valid email');
      return;
    }

    if (_messageController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter a message');
      return;
    }

    // If all validations pass
    widget.onWishlistChanged?.call('Form submitted successfully!');

    // Clear the fields
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    _anotherMessageController.clear();
  }

  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Initialize wishlist states when widget loads
    _initializeWishlistStates();
  }

  Future<void> _initializeWishlistStates() async {
    // This will be called after products are loaded
    if (mounted) setState(() {});
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
    return Column(
      children: [
        AquaCollectionCard(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Divider(color: Color(0xFF30578E)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(child: Text("Error: ${controller.errorMessage}"));
            }

            if (controller.products.isEmpty) {
              return const Center(child: Text("No products found"));
            }

            if (controller.products.isNotEmpty) {
              _initializeStates(controller.products.length);
            }

            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    final screenWidth = MediaQuery.of(context).size.width;

                    // Calculate responsive dimensions
                    final imageWidth = (screenWidth / 2) - 24;
                    final imageHeight = imageWidth * 1.2;

                    // For screens wider than 800px, cap the dimensions
                    final maxWidth = 800;
                    final cappedWidth =
                        screenWidth > maxWidth
                            ? (maxWidth / 2) - 24
                            : imageWidth;
                    final cappedHeight =
                        screenWidth > maxWidth
                            ? ((maxWidth / 2) - 24) * 1.2
                            : imageHeight;

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

                                        if (isOutOfStock) {
                                          // Only show out-of-stock image and wishlist icon
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
                                                alignment:
                                                    Alignment.centerRight,
                                                child: FutureBuilder<bool>(
                                                  future:
                                                      SharedPreferencesHelper.isInWishlist(
                                                        product.id.toString(),
                                                      ),
                                                  builder: (context, snapshot) {
                                                    final isInWishlist =
                                                        snapshot.data ?? false;

                                                    return GestureDetector(
                                                      onTap: () async {
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
                                                        width:
                                                            isMobile ? 20 : 24,
                                                        height:
                                                            isMobile ? 18 : 20,
                                                      ),
                                                    );
                                                  },
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

                                                if (product.isMakerChoice ==
                                                    1) {
                                                  badges.add(
                                                    SvgPicture.asset(
                                                      "assets/home_page/maker_choice.svg",
                                                      height:
                                                          isMobile ? 40 : 32,
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
                                                    ElevatedButton(
                                                      onPressed:
                                                          () {}, // Replace with your logic
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                        Colors
                                                            .white,
                                                        foregroundColor:
                                                        const Color(
                                                          0xFFF46856,
                                                        ),
                                                        minimumSize:
                                                        const Size(
                                                          110,
                                                          32,
                                                        ),
                                                        maximumSize:
                                                        const Size(
                                                          110,
                                                          32,
                                                        ),
                                                        padding:
                                                        const EdgeInsets.fromLTRB(
                                                          14,
                                                          7,
                                                          14,
                                                          7,
                                                        ),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            79,
                                                          ),
                                                          side: const BorderSide(
                                                            color: Color(
                                                              0xFFF46856,
                                                            ),
                                                            width: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Few Pieces Left",
                                                        style: TextStyle(
                                                          fontFamily:
                                                          GoogleFonts.barlow()
                                                              .fontFamily,
                                                          fontSize:
                                                          10,
                                                          fontWeight:
                                                          FontWeight
                                                              .w600,
                                                          color: const Color(
                                                            0xFFF46856,
                                                          ),
                                                          letterSpacing:
                                                          0.48,
                                                        ),
                                                        textAlign:
                                                        TextAlign
                                                            .center,
                                                      ),
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
                                                      onPressed:
                                                          () {}, // Replace with your logic
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                        Color(
                                                          0xFFF46856,
                                                        ),
                                                        foregroundColor:
                                                        const Color(
                                                          0xFFF46856,
                                                        ),
                                                        minimumSize:
                                                        const Size(
                                                          110,
                                                          32,
                                                        ),
                                                        maximumSize:
                                                        const Size(
                                                          110,
                                                          32,
                                                        ),
                                                        padding:
                                                        const EdgeInsets.fromLTRB(
                                                          14,
                                                          7,
                                                          14,
                                                          7,
                                                        ),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            79,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "${product.discount}% OFF",
                                                        style: TextStyle(
                                                          fontFamily:
                                                          GoogleFonts.barlow()
                                                              .fontFamily,
                                                          fontSize:
                                                          10,
                                                          fontWeight:
                                                          FontWeight
                                                              .w600,
                                                          color:
                                                          Colors
                                                              .white,
                                                          letterSpacing:
                                                          0.48,
                                                        ),
                                                        textAlign:
                                                        TextAlign
                                                            .center,
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
                                                  onTap: () async {
                                                    if (isInWishlist) {
                                                      await SharedPreferencesHelper.removeFromWishlist(
                                                        product.id.toString(),
                                                      );
                                                      widget.onWishlistChanged
                                                          ?.call(
                                                            'Product Removed From Wishlist',
                                                          );
                                                    } else {
                                                      await SharedPreferencesHelper.addToWishlist(
                                                        product.id.toString(),
                                                      );
                                                      widget.onWishlistChanged
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
                                              ? () async {
                                                bool isLoggedIn =
                                                    await _isLoggedIn();

                                                if (isLoggedIn) {
                                                  widget.onWishlistChanged?.call(
                                                    "We'll notify you when this product is back in stock.",
                                                  );
                                                } else {
                                                  context.go(AppRoutes.logIn);
                                                }
                                              }
                                              : () {
                                                context.go(
                                                  AppRoutes.cartDetails(
                                                    product.id,
                                                  ),
                                                );
                                              },
                                      child: Text(
                                        isOutOfStock
                                            ? "NOTIFY ME"
                                            : "ADD TO CART",
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
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 550,
          margin: const EdgeInsets.only(top: 27),
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
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Center(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Ensures left alignment
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 300,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Ensures left alignment
                      children: [
                        CralikaFont(
                          text: "Let's Connect!",
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          lineHeight: 1.5,
                          letterSpacing: 0.96,
                          color: Color(0xFFFFFFFF),
                        ),
                        SizedBox(height: 7.0),
                        BarlowText(
                          text:
                              "Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful!",
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          lineHeight: 1.0,
                          letterSpacing: 0.0,
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Ensures left alignment
                      children: [
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            hintText: "YOUR NAME",
                            maxLength: 20,
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            hintText: "YOUR EMAIL",
                            isEmail: true,
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            hintText: "MESSAGE",
                            controller: _messageController,
                            isMessageField: true,
                            focusNode: _messageFocusNode,
                            nextFocusNode: _anotherMessageFocusNode,
                            nextController:
                                _anotherMessageController, // REQUIRED
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            hintText: "",
                            controller: _anotherMessageController,
                            focusNode: _anotherMessageFocusNode,
                            maxLength: 100,
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: 300,

                          child: Align(
                            alignment:
                                Alignment
                                    .centerRight, // Aligns the submit button to the left
                            child: GestureDetector(
                              onTap: () {
                                _submitForm();
                              },
                              child: BarlowText(
                                text: "SUBMIT",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                lineHeight: 1.0,
                                letterSpacing: 0.64,
                                backgroundColor: Color(0xFFb9d6ff),
                                enableHoverBackground: true,
                                color: Color(0xFF30578E),
                                hoverTextColor: Color(0xFFb9d6ff),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
