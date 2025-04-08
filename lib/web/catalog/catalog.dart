import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/custom_text.dart';
import 'package:kireimics/component/routes.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/categories/categories_controller.dart';
import '../../component/product_details/product_details_modal.dart';
import 'category_navigation.dart';

class CategoryListDetails extends StatefulWidget {
  const CategoryListDetails({super.key});

  @override
  State<CategoryListDetails> createState() => _CategoryListDetailsState();
}

class _CategoryListDetailsState extends State<CategoryListDetails> {
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            // height: 142,
            child: Padding(
              padding: const EdgeInsets.only(left: 453),
              child: Container(
                // color: Colors.yellow,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage("assets/home_page/background.png"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFFf36250).withOpacity(0.9),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 41,
                    right: 90,
                    left: 46,
                    bottom: 41,
                  ),
                  child: BarlowText(
                    text:
                        _currentDescription, // Use the variable here instead of hardcoded text

                    fontSize: 20,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            // height: 142,
            child: Padding(
              padding: const EdgeInsets.only(left: 292),
              child: Container(
                // color: Colors.green,
                child: CralikaFont(
                  text: "${productList.length.toString()} Products",
                  fontWeight: FontWeight.w400,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.only(
                left: 292,
                right: MediaQuery.of(context).size.width * 0.07,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Replace the CategoryNavigation widget in your build method with:
                  CategoryNavigation(
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
                  Row(
                    children: [
                      BarlowText(
                        text: "Sort / New",
                        color: const Color(0xFF3E5B84),
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          productList.isEmpty
              ? Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Padding(
                  padding: const EdgeInsets.only(left: 296, top: 80),
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/icons/notFound.svg"),
                      SizedBox(height: 20),
                      CralikaFont(text: "No results found!"),
                      SizedBox(height: 10),
                      BarlowText(
                        text:
                            "Looks like the product you're looking for is not available. Please try a different keyword, or check the spelling!",
                        fontSize: 18,
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
                ),
              )
              : SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    right:
                        MediaQuery.of(context).size.width *
                        0.07, // 7% of screen width
                    left: 292,
                    top: 30,
                  ),

                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            (_) => setState(() => _isHoveredList[index] = true),
                        onExit:
                            (_) =>
                                setState(() => _isHoveredList[index] = false),
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
                                    top:
                                        imageHeight *
                                        0.04, // 4% of image height
                                    left:
                                        imageWidth * 0.05, // 5% of image width
                                    right:
                                        imageWidth * 0.05, // 5% of image width
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
                                              vertical:
                                                  imageHeight *
                                                  0.025, // Adjusts dynamically
                                              horizontal:
                                                  imageWidth *
                                                  0.08, // Adjusts dynamically
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
                                            style: TextStyle(
                                              fontSize:
                                                  imageWidth *
                                                  0.04, // Adjusts font size dynamically
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  index == 1 || index == 2
                                                      ? Colors.white
                                                      : Color(0xFFF46856),
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
                                            width:
                                                imageWidth *
                                                0.10, // 12% of image width
                                            height:
                                                imageHeight *
                                                0.05, // 6% of image height
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom:
                                        imageHeight *
                                        0.02, // 2% of image height
                                    left:
                                        imageWidth * 0.02, // 2% of image width
                                    right:
                                        imageWidth * 0.02, // 2% of image width
                                    child: AnimatedOpacity(
                                      duration: Duration(milliseconds: 300),
                                      opacity:
                                          _isHoveredList[index] ? 1.0 : 0.0,
                                      child: Container(
                                        width: imageWidth * 0.95,
                                        height: imageHeight * 0.35,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              imageWidth * 0.05, // 5% of width
                                          vertical:
                                              imageHeight *
                                              0.02, // 2% of height
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF3E5B84,
                                          ).withOpacity(0.8), // 50% opacity
                                        ),

                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              product.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Cralika',
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    imageWidth *
                                                    0.05, // Responsive font size
                                                height: 1.2, // Line height
                                                letterSpacing:
                                                    imageWidth *
                                                    0.002, // Responsive letter spacing
                                              ),
                                            ),
                                            SizedBox(
                                              height: imageHeight * 0.04,
                                            ), // Responsive spacing
                                            Text(
                                              "Rs. ${product.price}",

                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    GoogleFonts.barlow()
                                                        .fontFamily,
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    imageWidth *
                                                    0.040, // Responsive font size
                                                height: 1.2,
                                              ),
                                            ),
                                            SizedBox(
                                              height: imageHeight * 0.04,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "VIEW",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                        GoogleFonts.barlow()
                                                            .fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        imageWidth *
                                                        0.040, // Responsive font size
                                                    height: 1.0,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: imageWidth * 0.02,
                                                ),
                                                Text(
                                                  "/",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                        GoogleFonts.barlow()
                                                            .fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        imageWidth * 0.040,
                                                    height: 1.0,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: imageWidth * 0.02,
                                                ),
                                                Text(
                                                  "ADD TO CART",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                        GoogleFonts.barlow()
                                                            .fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        imageWidth *
                                                        0.040, // Responsive font size
                                                    height: 1.0,
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
              ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
