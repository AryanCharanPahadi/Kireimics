import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/mobile/collection/collection.dart';
import 'package:kireimics/web_desktop_common/sale/sale_controller.dart';
import 'package:kireimics/web_desktop_common/sale/sale_navigation.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../web_desktop_common/sale/sale_modal.dart';
import '../component/badges_mobile.dart';

class SaleMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged;
  const SaleMobile({super.key, this.onWishlistChanged});

  @override
  State<SaleMobile> createState() => _SaleMobileState();
}

class _SaleMobileState extends State<SaleMobile> {
  String? _selectedFilter = 'All'; // Initialize with 'All' by default
  String _selectedDescription =
      '/ Browse our collection of handcrafted pottery, where each one-of-a-kind piece adds charm to your home while serving a purpose you\'ll appreciate every day /';
  int _selectedCategoryId = 1; // Default to "All" category ID
  String _selectedCategoryName = 'All'; // Track category name
  List<SaleModal> _productsSale = []; // Store fetched products
  List<SaleModal> _originalProductsSale = []; // Store original product list
  bool _isLoading = false; // Track loading state
  List<bool> _isHoveredList = []; // Track hover state for grid items
  bool _showSortOptions = false; // Track if sort options are visible
  bool _showFilterOptions = false; // Track if filter options are visible
  final _sortFilterKey = GlobalKey(); // Key for sort/filter widgets

  @override
  void initState() {
    super.initState();
    _handleInitialCategory();
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

  // Handle clicks outside the sort/filter options
  void _handleOutsideClick(PointerDownEvent event) {
    final renderBox =
        _sortFilterKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final Rect widgetRect = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width,
        size.height,
      );

      if (!widgetRect.contains(event.position)) {
        setState(() {
          _showSortOptions = false;
          _showFilterOptions = false;
        });
      }
    }
  }

  void _handleInitialCategory() {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    final catId = uri.queryParameters['cat_id'];

    if (catId != null && catId.isNotEmpty) {
      final categoryId = int.tryParse(catId);
      if (categoryId != null) {
        setState(() {
          _selectedCategoryId = categoryId;
        });
        _fetchProductsByCategory(categoryId);
        return;
      }
    }
    // Default to "All" if no category specified
    _fetchProductsForAllCategory();
  }

  Future<void> _fetchProductsForAllCategory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final allProducts = await ApiHelper.fetchProductsSale();
      setState(() {
        _productsSale = allProducts;
        _originalProductsSale = List.from(
          allProducts,
        ); // Store filtered list as original
        _isHoveredList = List<bool>.filled(allProducts.length, false);
        _isLoading = false;
        _selectedFilter = null; // Reset filter
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
    }
  }

  Future<void> _fetchProductsByCategory(int catId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final allProducts = await ApiHelper.fetchProductByCatIdSale(catId);
      setState(() {
        _productsSale = allProducts;
        _originalProductsSale = List.from(
          allProducts,
        ); // Store filtered list as original
        _isHoveredList = List<bool>.filled(allProducts.length, false);
        _isLoading = false;
        _selectedFilter = null; // Reset filter
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
    }
  }

  void _onHoverChanged(int index, bool isHovered) {
    setState(() {
      _isHoveredList[index] = isHovered;
    });
  }

  void onCategorySelected(int id, String name, String desc) {
    setState(() {
      _selectedDescription = desc;
      _selectedCategoryId = id;
      _selectedCategoryName = name;
      _showSortOptions = false;
      _showFilterOptions = false;
      _selectedFilter = null; // Reset filter when category changes
    });

    if (name.toLowerCase() == 'all') {
      _fetchProductsForAllCategory();
    } else {
      _fetchProductsByCategory(id);
    }
  }

  void _toggleSortOptions() {
    setState(() {
      _showSortOptions = !_showSortOptions;
      if (_showSortOptions) _showFilterOptions = false;
    });
  }

  void _toggleFilterOptions() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
      if (_showFilterOptions) _showSortOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: _handleOutsideClick,

          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage(
                            "assets/home_page/background.png",
                          ),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            const Color(0xFFf36250).withOpacity(0.9),
                            BlendMode.srcATop,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          width: 342,
                          child: BarlowText(
                            text: _selectedDescription,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            lineHeight: 30 / 14,
                            letterSpacing: 0.56,
                            color: Color(0xFFFFFFFF),
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
                          text:
                              _isLoading
                                  ? 'Loading...'
                                  : '${_productsSale.length} Product${_productsSale.length == 1
                                      ? ''
                                      : _productsSale.length == 0
                                      ? ''
                                      : 's'}',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: SaleNavigation(
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: onCategorySelected,
                        context: context,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      child: Divider(color: Color(0xFF30578E), height: 1),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _toggleSortOptions,

                            child: BarlowText(
                              text: "Sort / New",
                              color: Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              lineHeight: 1.0,
                              letterSpacing: 0.04 * 16,
                            ),
                          ),
                          SizedBox(width: 16),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _toggleFilterOptions,

                            child: BarlowText(
                              text: "Filter / ${_selectedFilter ?? 'All'}",
                              color: Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              lineHeight: 1.0,
                              letterSpacing: 0.04 * 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _isLoading
                        ? Padding(
                          padding: const EdgeInsets.only(
                            left: 22,
                            top: 20,
                            right: 22,
                          ),
                          child: Center(
                            child: RotatingSvgLoader(
                              assetPath: 'assets/footer/footerbg.svg',
                            ),
                          ),
                        )
                        : _productsSale.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.only(
                            left: 22,
                            top: 20,
                            right: 22,
                          ),
                          child: Center(
                            child: CartEmpty(
                              cralikaText: "No products here yet!",
                              hideBrowseButton: true,
                              barlowText:
                                  "Try another category, hopefully you'll\nfind something you like there!",
                            ),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing:
                                          24, // Increased vertical spacing
                                      childAspectRatio: () {
                                        double width =
                                            MediaQuery.of(context).size.width;
                                        if (width > 320 && width <= 410) {
                                          return 0.48;
                                        } else if (width > 410 &&
                                            width <= 500) {
                                          return 0.53;
                                        } else if (width > 500 &&
                                            width <= 600) {
                                          return 0.56;
                                        } else if (width > 600 &&
                                            width <= 700) {
                                          return 0.62;
                                        } else if (width > 700 &&
                                            width <= 800) {
                                          return 0.65;
                                        } else {
                                          return 0.50;
                                        }
                                      }(),
                                    ),
                                itemCount: _productsSale.length,
                                itemBuilder: (context, index) {
                                  final product = _productsSale[index];
                                  final screenWidth =
                                      MediaQuery.of(context).size.width;

                                  final imageWidth = (screenWidth / 2) - 24;
                                  final imageHeight = imageWidth * 1.2;
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
                                    future: fetchStockQuantity(
                                      product.id.toString(),
                                    ),
                                    builder: (context, snapshot) {
                                      final quantity = snapshot.data;
                                      final isOutOfStock = quantity == 0;
                                      if (isOutOfStock) {
                                        return Container();
                                      }
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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

                                                Positioned(
                                                  top: 10,
                                                  left: 10,
                                                  right: 10,
                                                  child: LayoutBuilder(
                                                    builder: (
                                                      context,
                                                      constraints,
                                                    ) {
                                                      bool isMobile =
                                                          constraints.maxWidth <
                                                          800;

                                                      return ProductBadgesRow(
                                                        isOutOfStock:
                                                            isOutOfStock,
                                                        isMobile: isMobile,
                                                        quantity: quantity,
                                                        product: product,
                                                        onWishlistChanged:
                                                            widget
                                                                .onWishlistChanged,

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
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,

                                                      children: [
                                                        // Original price with strikethrough
                                                        if (product.discount !=
                                                            0)
                                                          Text(
                                                            "Rs. ${product.price.toStringAsFixed(2)}",
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xFF30578E,
                                                              ).withOpacity(
                                                                0.7,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              height: 1.2,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              decorationColor:
                                                                  Color(
                                                                    0xFF30578E,
                                                                  ).withOpacity(
                                                                    0.7,
                                                                  ),
                                                              fontFamily:
                                                                  GoogleFonts.barlow()
                                                                      .fontFamily,
                                                            ),
                                                          ),

                                                        // Vertical divider
                                                        if (product.discount !=
                                                            0)
                                                          SizedBox(width: 6),
                                                        // Discounted price
                                                        BarlowText(
                                                          text:
                                                              product.discount !=
                                                                      0
                                                                  ? "Rs. ${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}"
                                                                  : "Rs. ${product.price.toStringAsFixed(2)}",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          lineHeight: 1.2,
                                                          color: const Color(
                                                            0xFF30578E,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],

                                                  const SizedBox(height: 8),
                                                  GestureDetector(
                                                    onTap:() async {
                                                      // 1. Call the wishlist changed callback immediately
                                                      widget.onWishlistChanged?.call(
                                                        'Product Added To Cart',
                                                      );

                                                      // 2. Store the product ID in SharedPreferences
                                                      await SharedPreferencesHelper.addProductId(
                                                        product.id,
                                                      );

                                                      // 3. Refresh the cart state
                                                      cartNotifier.refresh();

                                                      // Note: Removed the Future.delayed and showDialog parts
                                                    },
                                                    child:BarlowText(
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
                          ),
                        ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showSortOptions)
          Positioned(
            right: 50,
            top: 320,
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFFE7E7E7), // #E7E7E7
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000), // #0000000F (6% opacity black)
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(20, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSortOptions(),
              ),
            ),
          ),
        if (_showFilterOptions)
          Positioned(
            right: 16,
            top: 320,
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFFE7E7E7), // #E7E7E7
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000), // #0000000F (6% opacity black)
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(20, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFilterOptions(),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSortOptions() {
    final options = [
      {
        'label': 'Price Low - High',
        'onTap': () => _handleSortSelected('Price Low - High'),
      },
      {
        'label': 'Price High - Low',
        'onTap': () => _handleSortSelected('Price High - Low'),
      },
      {'label': 'New', 'onTap': () => _handleSortSelected('New')},
    ];

    return options.map((option) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                (option['onTap'] as Function)();
                setState(() {
                  _showSortOptions = false;
                });
              },
              child: BarlowText(
                text: option['label'] as String,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF30578E),
                hoverTextColor: const Color(0xFF2876E4),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildFilterOptions() {
    final options = [
      {'label': 'All', 'onTap': () => _handleFilterSelected('All')},
      {
        'label': "Maker's Choice",
        'onTap': () => _handleFilterSelected("Maker's Choice"),
      },

    ];

    return options.map((option) {
      final label = option['label'] as String;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () {
                (option['onTap'] as Function)();
                setState(() => _showFilterOptions = false);
              },
              child: BarlowText(
                text: label,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF30578E),
                hoverTextColor: const Color(0xFF2876E4),
                enableUnderlineForCurrentFilter: true,
                currentFilterValue: _selectedFilter ?? 'All',
                decorationColor: const Color(0xFF30578E),
                activeUnderlineDecoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _handleSortSelected(String sortOption) {
    setState(() {
      if (sortOption == 'Price Low - High') {
        _productsSale.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
      } else if (sortOption == 'Price High - Low') {
        _productsSale.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
      } else if (sortOption == 'New') {
        _productsSale = List.from(
          _originalProductsSale,
        ); // Restore original list
        _isHoveredList = List<bool>.filled(_productsSale.length, false);
      }
    });
  }

  void _handleFilterSelected(String filterOption) {
    setState(() {
      _selectedFilter = filterOption; // Update selected filter
      if (filterOption == 'All') {
        _productsSale = List.from(
          _originalProductsSale,
        ); // Restore original list
        _isHoveredList = List<bool>.filled(_productsSale.length, false);
      } else if (filterOption == "Maker's Choice") {
        _productsSale =
            _originalProductsSale
                .where((product) => product.isMakerChoice == 1)
                .toList();
        _isHoveredList = List<bool>.filled(_productsSale.length, false);
      } else if (filterOption == 'Few Pieces Left') {
        _productsSale =
            _originalProductsSale
                .where((product) => product.quantity! <= 2)
                .toList();
        _isHoveredList = List<bool>.filled(_productsSale.length, false);
      }
    });
  }
}
