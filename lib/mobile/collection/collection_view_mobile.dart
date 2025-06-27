import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/no_result_found/no_product_yet.dart';
import '../../component/api_helper/api_helper.dart' show ApiHelper;
import '../../component/app_routes/routes.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/shared_preferences/shared_preferences.dart';

import '../../web_desktop_common/collection/collection_controller.dart';
import '../../web_desktop_common/collection/collection_navigation.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../web_desktop_common/notify_me/notify_me.dart';
import '../component/badges_mobile.dart';

class CollectionViewMobile extends StatefulWidget {
  final int productIds;

  final Function(String)? onWishlistChanged;
  const CollectionViewMobile({
    super.key,
    this.onWishlistChanged,
    required this.productIds,
  });

  @override
  State<CollectionViewMobile> createState() => _CollectionViewMobileState();
}

class _CollectionViewMobileState extends State<CollectionViewMobile> {
  String? _selectedFilter = 'All'; // Initialize with 'All' by default

  String _selectedDescription =
      '/ Browse our collection of handcrafted pottery, where each one-of-a-kind piece adds charm to your home while serving a purpose you\'ll appreciate every day /';
  int _selectedCategoryId = 1; // Default to "All" category ID
  String _selectedCategoryName = 'All'; // Track category name
  List<Product> _products = []; // Store fetched products
  List<Product> _originalProducts = []; // Store original product list
  bool _isLoading = false; // Track loading state
  List<bool> _isHoveredList = []; // Track hover state for grid items
  bool _showSortOptions = false; // Track if sort options are visible
  bool _showFilterOptions = false; // Track if filter options are visible
  final _sortFilterKey = GlobalKey(); // Key for sort/filter widgets
  late String collectionName = '';
  @override
  void initState() {
    super.initState();
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    collectionName = uri.queryParameters['collection_name'] ?? 'No Collection';
    _fetchProductsForAll();
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

  void _onHoverChanged(int index, bool isHovered) {
    setState(() {
      _isHoveredList[index] = isHovered;
    });
  }

  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
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

  Future<void> _fetchProductsForAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await ApiHelper.fetchBannerProductById(
        widget.productIds,
      );

      setState(() {
        _products = products;
        _originalProducts = List.from(products); // Store original list
        _isHoveredList = List<bool>.filled(products.length, false);
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

  Future<void> _fetchProductsByCategory(int catId, int productIds) async {
    setState(() {
      _isLoading = true;
    });

    print(
      'Sending request with catId: $catId and productIds: ${widget.productIds}',
    );

    try {
      final products = await ApiHelper.fetchBannerProductByCatIdAndId(
        widget.productIds,
        catId,
      );

      print('Fetched products: ${products.length}');
      print('Raw products For Cat id and Id: $products');

      setState(() {
        _products = products;
        _originalProducts = List.from(products); // Store original list
        _isHoveredList = List<bool>.filled(products.length, false);
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

  void onCategorySelected(int id, String name, String desc, {int? productIds}) {
    print('Category ID: $id, Name: $name, productIds: $productIds');
    setState(() {
      _selectedDescription = desc;
      _selectedCategoryId = id;
      _selectedCategoryName = name;
      _showSortOptions = false;
      _showFilterOptions = false;
      _selectedFilter = null; // Reset filter when category changes
    });

    if (name.toLowerCase() == 'collections') {
      // _fetchCollections();
    } else if (name.toLowerCase() == 'all') {
      _fetchProductsForAll();
    } else {
      _fetchProductsByCategory(id, widget.productIds);
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BarlowText(
                            text: "Catalog",
                            color: Color(0xFF30578E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            lineHeight: 1.0,
                            letterSpacing: 1 * 0.04, // 4% of 32px
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
                            text: "Collections",
                            color: Color(0xFF30578E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            lineHeight: 1.0,
                            onTap: () {
                              context.go(
                                '${AppRoutes.catalog}?cat_id=${'collections'}', // Use URL parameter
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
                            text: collectionName,
                            color: Color(0xFF30578E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            lineHeight: 1.0,
                            decoration: TextDecoration.underline,
                          ),
                        ],
                      ),
                    ),

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
                            text: _selectedDescription,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
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
                          text:
                              _isLoading
                                  ? 'Loading...'
                                  : _selectedCategoryName.toLowerCase() ==
                                      'collections'
                                  ? ''
                                  : '${_products.length} Product${_products.length == 1
                                      ? ''
                                      : _products.length == 0
                                      ? ''
                                      : 's'}',

                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: CollectionNavigation(
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: onCategorySelected,

                        context: context,
                        productIds: widget.productIds, // Pass productIds
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
                        : _products.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.only(
                            left: 22,
                            top: 20,
                            right: 22,
                          ),
                          child: Center(
                            child: CartEmpty(
                              cralikaText: "No Collections here yet!",
                              // hideBrowseButton: true,
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
                                itemCount: _products.length,
                                itemBuilder: (context, index) {
                                  final product = _products[index];
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
                                                    child: ColorFiltered(
                                                      colorFilter:
                                                          isOutOfStock
                                                              ? const ColorFilter.matrix(
                                                                [
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
                                                                ],
                                                              )
                                                              : const ColorFilter.mode(
                                                                Colors
                                                                    .transparent,
                                                                BlendMode
                                                                    .multiply,
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
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  if (!isOutOfStock) ...[
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
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

                                                  if (isOutOfStock) ...[
                                                    BarlowText(
                                                      text:
                                                          "Rs. ${product.price.toStringAsFixed(2)}",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      lineHeight: 1.2,
                                                      color: const Color(
                                                        0xFF30578E,
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 8),
                                                  GestureDetector(
                                                    onTap:
                                                        isOutOfStock
                                                            ? null
                                                            : () async {
                                                              widget
                                                                  .onWishlistChanged
                                                                  ?.call(
                                                                    'Product Added To Cart',
                                                                  );
                                                              await SharedPreferencesHelper.addProductId(
                                                                product.id,
                                                              );
                                                              cartNotifier
                                                                  .refresh();
                                                            },
                                                    child:
                                                        isOutOfStock
                                                            ? NotifyMeButton(
                                                              productId:
                                                                  product.id,
                                                              onWishlistChanged:
                                                                  widget
                                                                      .onWishlistChanged,
                                                              onErrorWishlistChanged: (
                                                                error,
                                                              ) {
                                                                widget
                                                                    .onWishlistChanged
                                                                    ?.call(
                                                                      error,
                                                                    );
                                                              },
                                                            )
                                                            : BarlowText(
                                                              text:
                                                                  "ADD TO CART",
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              lineHeight: 1.0,
                                                              letterSpacing:
                                                                  0.56,
                                                              color:
                                                                  const Color(
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
    final isCollectionView =
        _selectedCategoryName.toLowerCase() == 'collections';
    final options =
        isCollectionView
            ? [
              {'label': 'Newest', 'onTap': () => _handleSortSelected('Newest')},
              {'label': 'Oldest', 'onTap': () => _handleSortSelected('Oldest')},
            ]
            : [
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
                (option['onTap'] as Function)(); // Properly invoke the function
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
                currentFilterValue:
                    _selectedFilter ?? 'All', // Ensure fallback to 'All'
                decorationColor: const Color(0xFF30578E),
                activeUnderlineDecoration:
                    TextDecoration.underline, // Ensure underline is applied
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _handleSortSelected(String sortOption) {
    print('Sorting by: $sortOption');

    if (_selectedCategoryName.toLowerCase() == 'collections') {
      // Handle collection sorting
      if (sortOption == 'Newest') {
      } else if (sortOption == 'Oldest') {}
    } else {
      // Handle product sorting
      setState(() {
        if (sortOption == 'Price Low - High') {
          _products.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        } else if (sortOption == 'Price High - Low') {
          _products.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        } else if (sortOption == 'New') {
          _products = List.from(_originalProducts); // Restore original list
          _isHoveredList = List<bool>.filled(_products.length, false);
        }
      });
    }
  }

  void _handleFilterSelected(String filterOption) {
    print('Filter option selected: $filterOption');
    setState(() {
      _selectedFilter = filterOption; // Update selected filter
      if (filterOption == 'All') {
        _products = List.from(_originalProducts); // Restore original list
        _isHoveredList = List<bool>.filled(_products.length, false);
      } else if (filterOption == "Maker's Choice") {
        _products =
            _originalProducts
                .where((product) => product.isMakerChoice == 1)
                .toList();
        _isHoveredList = List<bool>.filled(_products.length, false);
      } else if (filterOption == 'Few Pieces Left') {
        _products =
            _originalProducts
                .where((product) => product.quantity! < 2)
                .toList();
        _isHoveredList = List<bool>.filled(_products.length, false);
      }
    });
  }
}
