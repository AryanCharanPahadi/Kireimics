import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/app_routes/routes.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/catalog_sale_gridview/catalog_controller1.dart';
import '../../web_desktop_common/catalog_sale_gridview/catalog_sale_navigation.dart';
import '../../web_desktop_common/collection/collection_modal.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../web_desktop_common/notify_me/notify_me.dart';
import '../collection/collection.dart';
import '../component/badges_mobile.dart';

class CatalogMobileComponent extends StatefulWidget {
  final Function(String)? onWishlistChanged;
  const CatalogMobileComponent({super.key, this.onWishlistChanged});

  @override
  State<CatalogMobileComponent> createState() => _CatalogMobileComponentState();
}

class _CatalogMobileComponentState extends State<CatalogMobileComponent> {
  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  String? _selectedFilter = 'All';
  String _selectedDescription =
      '/ Browse our collection of handcrafted pottery, where each one-of-a-kind piece adds charm to your home while serving a purpose you\'ll appreciate every day /';
  int _selectedCategoryId = 1;
  String _selectedCategoryName = 'All';
  List<Product> _products = [];
  List<Product> _originalProducts = [];
  List<CollectionModal> _collections = [];
  bool _isLoading = false;
  List<bool> _isHoveredList = [];
  bool _showSortOptions = false;
  bool _showFilterOptions = false;
  final _sortFilterKey = GlobalKey();

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
      if (catId.toLowerCase() == 'collections') {
        setState(() {
          _selectedCategoryId = -1;
          _selectedCategoryName = 'Collections';
          _selectedDescription =
          '/ Discover our curated collections of handcrafted pottery, each telling a unique story /';
        });
        _fetchCollections();
        return;
      } else {
        final categoryId = int.tryParse(catId);
        if (categoryId != null) {
          setState(() {
            _selectedCategoryId = categoryId;
            _selectedCategoryName = 'Category $categoryId';
          });
          _fetchProductsByCategory(categoryId);
          return;
        }
      }
    }
    setState(() {
      _selectedCategoryId = 1;
      _selectedCategoryName = 'All';
      _selectedDescription =
      '/ Browse our collection of handcrafted pottery, where each one-of-a-kind piece adds charm to your home while serving a purpose you\'ll appreciate every day /';
    });
    _fetchProductsForAllCategory();
  }

  Future<void> _fetchProductsForAllCategory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await ApiHelper.fetchProducts();
      final filteredProducts =
      products.where((product) => product.isCollection == 0).toList();

      setState(() {
        _products = filteredProducts;
        _originalProducts = List.from(filteredProducts);
        _collections = [];
        _isHoveredList = List<bool>.filled(filteredProducts.length, false);
        _isLoading = false;
        _selectedFilter = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
    }
  }

  Future<void> _fetchProductsByCategory(int catId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await ApiHelper.fetchProductByCatId(catId);
      final filteredProducts =
      products.where((product) => product.isCollection == 0).toList();
      setState(() {
        _products = filteredProducts;
        _originalProducts = List.from(products);
        _collections = [];
        _isHoveredList = List<bool>.filled(products.length, false);
        _isLoading = false;
        _selectedFilter = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
    }
  }

  Future<void> _fetchCollections() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final collections = await ApiHelper.fetchCollectionBanner();
      print('Fetched Collections Data: $collections');

      setState(() {
        _collections = collections;
        _products = [];
        _originalProducts = [];
        _isHoveredList = List<bool>.filled(collections.length, false);
        _isLoading = false;
        _selectedFilter = null;
      });

      collections.forEach((collection) {
        print('Collection: ${collection.toString()}');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching collections: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load collections: $e')));
    }
  }

  Future<void> _fetchSortedCollections(String sortOrder) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final collections = await ApiHelper.fetchCollectionBannerSort();
      print('Fetched Sorted Collections Data: $collections');

      setState(() {
        _collections = collections;
        _isHoveredList = List<bool>.filled(collections.length, false);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching sorted collections: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load collections: $e')));
    }
  }

  void _onHoverChanged(int index, bool isHovered) {
    setState(() {
      _isHoveredList[index] = isHovered;
    });
  }

  void onCategorySelected(int id, String name, String desc) {
    print('Category ID: $id, Name: $name');
    setState(() {
      _selectedDescription = desc;
      _selectedCategoryId = id;
      _selectedCategoryName = name;
      _showSortOptions = false;
      _showFilterOptions = false;
      _selectedFilter = null;
    });

    if (name.toLowerCase() == 'collections') {
      _fetchCollections();
    } else if (name.toLowerCase() == 'all') {
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
    final isCollectionView =
        _selectedCategoryName.toLowerCase() == 'collections';
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
                          text: _isLoading
                              ? 'Loading...'
                              : _selectedCategoryName.toLowerCase() ==
                              'collections'
                              ? '${_collections.length} Collection${_collections.length == 1 ? '' : _collections.length == 0 ? '' : 's'}'
                              : '${_products.length} Product${_products.length == 1 ? '' : _products.length == 0 ? '' : 's'}',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: CatalogNavigation(
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: onCategorySelected,
                        context: context,
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
                          if (!isCollectionView)
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
                      padding:
                      const EdgeInsets.only(left: 22, top: 20, right: 22),
                      child: Center(
                        child: RotatingSvgLoader(
                          assetPath: 'assets/footer/footerbg.svg',
                        ),
                      ),
                    )
                        : isCollectionView
                        ? _collections.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(
                          left: 22, top: 20, right: 22),
                      child: Center(
                        child: CartEmpty(
                          cralikaText: "No Collections here yet!",
                          hideBrowseButton: true,
                          barlowText:
                          "Try another category, hopefully you'll\nfind something you like there!",
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: CollectionMobile(
                        collectionList: _collections,
                      ),
                    )
                        : _products.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(
                          left: 22, top: 20, right: 22),
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
                              horizontal: 14),
                          child: GridView.builder(
                            physics:
                            const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
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

                              final imageWidth =
                                  (screenWidth / 2) - 24;
                              final imageHeight = imageWidth * 1.2;

                              final maxWidth = 800;
                              final cappedWidth = screenWidth > maxWidth
                                  ? (maxWidth / 2) - 24
                                  : imageWidth;
                              final cappedHeight = screenWidth > maxWidth
                                  ? ((maxWidth / 2) - 24) * 1.2
                                  : imageHeight;

                              return FutureBuilder<int?>(
                                future: fetchStockQuantity(
                                    product.id.toString()),
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
                                                    AppRoutes
                                                        .productDetails(
                                                        product.id),
                                                  );
                                                },
                                                child: ColorFiltered(
                                                  colorFilter: isOutOfStock
                                                      ? const ColorFilter
                                                      .matrix([
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
                                                      : const ColorFilter
                                                      .mode(
                                                    Colors
                                                        .transparent,
                                                    BlendMode
                                                        .multiply,
                                                  ),
                                                  child: Image.network(
                                                    product.thumbnail,
                                                    width: cappedWidth,
                                                    height:
                                                    cappedHeight,
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
                                                      constraints
                                                          .maxWidth <
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
                                              top: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              CralikaFont(
                                                text: product.name,
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize: 16,
                                                lineHeight: 1.2,
                                                letterSpacing: 0.64,
                                                color: Color(
                                                    0xFF30578E),
                                                maxLines: 2,
                                              ),
                                              const SizedBox(
                                                  height: 8),
                                              if (!isOutOfStock) ...[
                                                Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    if (product
                                                        .discount !=
                                                        0)
                                                      Text(
                                                        "Rs. ${product.price.toStringAsFixed(2)}",
                                                        style:
                                                        TextStyle(
                                                          color: Color(
                                                              0xFF30578E)
                                                              .withOpacity(
                                                              0.7),
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                          fontSize:
                                                          14,
                                                          height:
                                                          1.2,
                                                          decoration:
                                                          TextDecoration
                                                              .lineThrough,
                                                          decorationColor:
                                                          Color(
                                                              0xFF30578E)
                                                              .withOpacity(
                                                              0.7),
                                                          fontFamily:
                                                          GoogleFonts
                                                              .barlow()
                                                              .fontFamily,
                                                        ),
                                                      ),
                                                    if (product
                                                        .discount !=
                                                        0)
                                                      SizedBox(
                                                          width: 6),
                                                    BarlowText(
                                                      text: product
                                                          .discount !=
                                                          0
                                                          ? "Rs. ${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}"
                                                          : "Rs. ${product.price.toStringAsFixed(2)}",
                                                      fontWeight:
                                                      FontWeight
                                                          .w400,
                                                      fontSize: 14,
                                                      lineHeight:
                                                      1.2,
                                                      color: const Color(
                                                          0xFF30578E),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              if (isOutOfStock) ...[
                                                BarlowText(
                                                  text:
                                                  "Rs. ${product.price.toStringAsFixed(2)}",
                                                  fontWeight:
                                                  FontWeight
                                                      .w400,
                                                  fontSize: 14,
                                                  lineHeight: 1.2,
                                                  color: const Color(
                                                      0xFF30578E),
                                                ),
                                              ],
                                              const SizedBox(
                                                  height: 8),
                                              GestureDetector(
                                                onTap: isOutOfStock
                                                    ? null
                                                    : () async {
                                                  widget
                                                      .onWishlistChanged
                                                      ?.call(
                                                      'Product Added To Cart');
                                                  await SharedPreferencesHelper
                                                      .addProductId(
                                                      product
                                                          .id);
                                                  cartNotifier
                                                      .refresh();
                                                },
                                                child: isOutOfStock
                                                    ? NotifyMeButton(
                                                  productId:
                                                  product.id,
                                                  onWishlistChanged:
                                                  widget
                                                      .onWishlistChanged,
                                                  onErrorWishlistChanged:
                                                      (error) {
                                                    widget
                                                        .onWishlistChanged
                                                        ?.call(
                                                        error);
                                                  },
                                                )
                                                    :BarlowText(
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
            top: 370,
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFFE7E7E7),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
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
            top: 370,
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFFE7E7E7),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
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
    final options = isCollectionView
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
    print('Sorting by: $sortOption');

    if (_selectedCategoryName.toLowerCase() == 'collections') {
      if (sortOption == 'Newest') {
        _fetchCollections();
      } else if (sortOption == 'Oldest') {
        _fetchSortedCollections('asc');
      }
    } else {
      setState(() {
        if (sortOption == 'Price Low - High') {
          _products.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        } else if (sortOption == 'Price High - Low') {
          _products.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        } else if (sortOption == 'New') {
          _products = List.from(_originalProducts);
          _isHoveredList = List<bool>.filled(_products.length, false);
        }
      });
    }
  }

  void _handleFilterSelected(String filterOption) {
    print('Filter option selected: $filterOption');
    setState(() {
      _selectedFilter = filterOption;
      if (filterOption == 'All') {
        _products = List.from(_originalProducts);
        _isHoveredList = List<bool>.filled(_products.length, false);
      } else if (filterOption == "Maker's Choice") {
        _products = _originalProducts
            .where((product) => product.isMakerChoice == 1)
            .toList();
        _isHoveredList = List<bool>.filled(_products.length, false);
      } else if (filterOption == 'Few Pieces Left') {
        _products = _originalProducts
            .where((product) => product.quantity! <= 2 && product.quantity! > 0)
            .toList();
        _isHoveredList = List<bool>.filled(_products.length, false);
      }
    });
  }
}