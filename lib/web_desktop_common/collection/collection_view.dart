import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/app_routes/routes.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/product_details/product_details_modal.dart';
import '../catalog_sale_gridview/catalog_sale_gridview.dart';
import '../component/rotating_svg_loader.dart';
import 'collection_navigation.dart';

class CollectionProductPage extends StatefulWidget {
  final int productIds;

  final Function(String)? onWishlistChanged;
  const CollectionProductPage({
    super.key,
    this.onWishlistChanged,
    required this.productIds,
  });

  @override
  State<CollectionProductPage> createState() => _CollectionProductPageState();
}

class _CollectionProductPageState extends State<CollectionProductPage> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Expanded(
      child: Stack(
        children: [
          Listener(
            onPointerDown: _handleOutsideClick,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isLargeScreen ? 389 : 292,

                    top: 24,
                    bottom: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BarlowText(
                        text: "Catalog",
                        color: const Color(0xFF30578E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        lineHeight: 1.0,
                        letterSpacing: 0.04 * 16,
                        onTap: () {
                          context.go(AppRoutes.catalog);
                        },
                        decorationColor: const Color(0xFF30578E),
                        hoverTextColor: const Color(0xFF2876E4),
                      ),
                      const SizedBox(width: 9),
                      SvgPicture.asset(
                        'assets/icons/right_icon.svg',
                        width: 24,
                        height: 24,
                        color: const Color(0xFF30578E),
                      ),
                      const SizedBox(width: 9),
                      BarlowText(
                        text: "Collections",
                        color: const Color(0xFF30578E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        lineHeight: 1.0,
                        route: AppRoutes.checkOut,
                        enableUnderlineForActiveRoute: true,
                        decorationColor: const Color(0xFF30578E),
                        hoverTextColor: const Color(0xFF2876E4),
                        onTap: () {
                          context.go(
                            '${AppRoutes.catalog}?cat_id=${'collections'}', // Use URL parameter
                          );
                        },
                      ),

                      const SizedBox(width: 9),
                      SvgPicture.asset(
                        'assets/icons/right_icon.svg',
                        width: 24,
                        height: 24,
                        color: const Color(0xFF30578E),
                      ),
                      const SizedBox(width: 9),
                      BarlowText(
                        text: collectionName,
                        color: const Color(0xFF30578E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        lineHeight: 1.0,
                        onTap: () {},
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF30578E),
                        hoverTextColor: const Color(0xFF2876E4),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isLargeScreen ? 545 : 453,
                      right: isLargeScreen ? 172 : 0, // Updated line
                    ),
                    child: Column(
                      children: [
                        Container(
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
                            padding: const EdgeInsets.only(
                              top: 41,
                              right: 90,
                              left: 46,
                              bottom: 41,
                            ),
                            child: BarlowText(
                              text: _selectedDescription,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF414141),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),

                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(left: isLargeScreen ? 389 : 292),
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
                      fontSize: 32,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  key: _sortFilterKey, // Add key here for click detection

                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isLargeScreen ? 389 : 292,
                      right:
                          isLargeScreen
                              ? MediaQuery.of(context).size.width * 0.15
                              : MediaQuery.of(context).size.width * 0.07,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CollectionNavigation(
                          selectedCategoryId: _selectedCategoryId,
                          onCategorySelected: onCategorySelected,

                          context: context,
                          productIds: widget.productIds, // Pass productIds
                        ),
                        Row(
                          children: [
                            BarlowText(
                              text: "Sort / New",
                              color: const Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              decorationColor: const Color(0xFF30578E),

                              hoverTextColor: const Color(0xFF2876E4),
                              onTap: _toggleSortOptions,
                            ),
                            SizedBox(width: 24),
                            BarlowText(
                              text: "Filter / ${_selectedFilter ?? 'All'}",
                              color: const Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,

                              hoverTextColor: const Color(0xFF2876E4),
                              onTap: _toggleFilterOptions,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Conditional Grid Rendering
                _isLoading
                    ? const Center(
                      child: RotatingSvgLoader(
                        assetPath: 'assets/footer/footerbg.svg',
                      ),
                    )
                    : _products.isNotEmpty
                    ? Padding(
                      padding: EdgeInsets.only(
                        right:
                            isLargeScreen
                                ? MediaQuery.of(context).size.width * 0.15
                                : MediaQuery.of(context).size.width * 0.07,
                        left: isLargeScreen ? 389 : 292,
                        top: 30,
                      ),
                      child: CategoryProductGrid(
                        productList: _products,
                        onWishlistChanged: widget.onWishlistChanged,
                        isHoveredList: _isHoveredList,
                        onHoverChanged: _onHoverChanged,
                      ),
                    )
                    : Padding(
                      padding: EdgeInsets.only(
                        left: isLargeScreen ? 613 : 516,
                        top: 80,
                      ),
                      child: CartEmpty(
                        hideBrowseButton: true,
                        cralikaText: "No products here yet!",
                        barlowText:
                            "Try another category, hopefully you'll find something you like there!",
                      ),
                    ),
              ],
            ),
          ),
          // Sort Options Dropdown
          if (_showSortOptions)
            Positioned(
              right: isLargeScreen ? 300 : 120,
              top: 230,
              child: Material(
                elevation: 4,
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFE7E7E7), width: 1.0),
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
            ),

          // Filter Options Dropdown
          if (_showFilterOptions)
            Positioned(
              right: isLargeScreen ? 250 : 80,
              top: 230,
              child: Material(
                elevation: 4,
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFE7E7E7), width: 1.0),
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
            ),
        ],
      ),
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
