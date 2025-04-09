import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/categories/categories_controller.dart'
    show CatalogController;
import '../../component/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/routes.dart';
import '../../web/catalog/category_navigation.dart';
import '../../web/contact_us/contact_us_controller.dart';

class CatalogMobileComponent extends StatefulWidget {
  const CatalogMobileComponent({super.key});

  @override
  State<CatalogMobileComponent> createState() => _CatalogMobileComponentState();
}

class _CatalogMobileComponentState extends State<CatalogMobileComponent> {
  final CatalogController categoriesController = Get.put(CatalogController());
  List<Product> productList = [];
  bool isLoading = false;
  int _selectedCategoryId = 1; // Default to first category
  final List<bool> _isHoveredList = List.generate(
    9,
    (_) => false,
  ); // Track hover state for each item
  final List<bool> _wishlistStates = List.filled(9, false);

  Future<void> fetchAllProducts() async {
    setState(() {
      isLoading = true;
    });

    final products = await ApiHelper.fetchProducts(); // assuming this exists
    setState(() {
      productList = products;
      isLoading = false;
    });
  }

  String _currentDescription =
      "/Craftsmanship is catalog involves many steps..."; // Default text

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    _initializeDescription();
  }

  Future<void> fetchProductsByCategoryId(int catId) async {
    setState(() {
      isLoading = true;
    });

    final products = await ApiHelper.fetchProductByCatId(catId);

    // Update description for the selected category
    final selectedCategory = categoriesController.categories.firstWhere(
      (cat) => cat['id'] == catId,
      orElse: () => {'description': _currentDescription},
    );

    setState(() {
      productList = products;
      _currentDescription = selectedCategory['description'] as String;
      isLoading = false;
    });
  }

  Future<void> _initializeDescription() async {
    // Wait for categories to load if needed
    await categoriesController.isLoading.value
        ? await Future.delayed(const Duration(milliseconds: 100))
        : null;

    // Find the default category and set its description
    final defaultCategory = categoriesController.categories.firstWhere(
      (cat) => cat['id'] == _selectedCategoryId,
      orElse:
          () => {
            'description': "/Craftsmanship is catalog involves many steps...",
          },
    );

    setState(() {
      _currentDescription = defaultCategory['description'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/home_page/background.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color(0xFFffb853).withOpacity(0.9),
                  BlendMode.srcATop,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: 342,
                child: BarlowText(
                  text:
                      _currentDescription, // Use the variable here instead of hardcoded text

                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  lineHeight: 30 / 14,
                  letterSpacing: 0.56,
                  color: Color(0xFF414141),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 22),
              child: CralikaFont(
                text: "${productList.length.toString()} Products",
                fontWeight: FontWeight.w400,
                fontSize: 21,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: CategoryNavigation(
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (id, name, desc) {
                setState(() {
                  _selectedCategoryId = id;
                  _currentDescription = desc;
                });
                if (name.toLowerCase() == 'all') {
                  fetchAllProducts();
                } else if (name.toLowerCase() == 'collections') {
                  context.go(AppRoutes.collection);
                } else {
                  fetchProductsByCategoryId(id);
                }
              },
              fetchAllProducts: fetchAllProducts,
              context: context,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: Divider(color: Color(0xFF3E5B84), height: 1),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BarlowText(
                  text: "Sort / New",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
                SizedBox(width: 16),
                BarlowText(
                  text: "Filter / All",
                  color: Color(0xFF3E5B84),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.0,
                  letterSpacing: 0.04 * 16,
                ),
              ],
            ),
          ),
          productList.isEmpty
              ? Padding(
                padding: const EdgeInsets.only(left: 22, top: 20, right: 22),
                child: Column(
                  children: [
                    SvgPicture.asset("assets/icons/notFound.svg"),
                    SizedBox(height: 20),
                    CralikaFont(text: "No results found!"),
                    SizedBox(height: 10),
                    Center(
                      child: BarlowText(
                        text:
                            "Looks like the product you're looking for is not available. Please try a different keyword, or check the spelling!",
                        fontSize: 18,
                        textAlign:
                            TextAlign
                                .center, // Ensure text itself is center-aligned
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        // Reset to the default category (ID 1) and fetch all products
                        setState(() {
                          _selectedCategoryId = 1;
                        });
                        fetchAllProducts();
                        // Also reset the description to the default
                        _initializeDescription();
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
              : Padding(
                padding: const EdgeInsets.only(top: 32),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.50,
                          ),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        final product = productList[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 196,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () {
                                        context.go(
                                          AppRoutes.productDetails(product.id),
                                        );
                                      },
                                      child: Image.network(
                                        product.thumbnail,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 6,
                                    right: 6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Define your onPressed functionality here
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 10,
                                            ),
                                            backgroundColor:
                                                index == 1 || index == 2
                                                    ? Color(0xFFF46856)
                                                    : Colors
                                                        .white, // White background for "Few Pieces Left"
                                            elevation: 0,
                                            side:
                                                index == 1 || index == 2
                                                    ? BorderSide
                                                        .none // No border for "50% OFF"
                                                    : BorderSide(
                                                      color: Color(0xFFF46856),
                                                      width: 1,
                                                    ), // Red border for "Few Pieces Left"
                                          ),
                                          child: Text(
                                            index == 1 || index == 2
                                                ? '${product.discount}% OFF'
                                                : 'Few Pieces Left',
                                            style: GoogleFonts.barlow(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              letterSpacing: 0.48,
                                              color:
                                                  index == 1 || index == 2
                                                      ? Colors.white
                                                      : Color(0xFFF46856),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                            width: 33.99,
                                            height: 19.33,
                                          ),
                                        ),
                                      ],
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
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontFamily: "Cralika",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        height: 1.2,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Rs. ${product.price}",
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

                                    Text(
                                      "ADD TO CART",
                                      style: GoogleFonts.barlow(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        height: 1.2,
                                        letterSpacing: 0.56,
                                        color: const Color(0xFF3E5B84),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
