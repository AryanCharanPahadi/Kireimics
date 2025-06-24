import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/product_details/product_details_modal.dart';
import '../catalog_sale_gridview/catalog_sale_gridview.dart';
import '../catalog_sale_gridview/catalog_sale_navigation.dart';
import '../../component/api_helper/api_helper.dart';
import '../collection/collection.dart';
import '../collection/collection_modal.dart';
import '../component/rotating_svg_loader.dart';

class CatalogPage extends StatefulWidget {
  final Function(String)? onWishlistChanged;

  const CatalogPage({super.key, this.onWishlistChanged});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? _selectedFilter = 'All'; // Initialize with 'All' by default

  String _selectedDescription =
      '/ Browse our collection of handcrafted pottery, where each one-of-a-kind piece adds charm to your home while serving a purpose you\'ll appreciate every day /';
  int _selectedCategoryId = 1; // Default to "All" category ID
  String _selectedCategoryName = 'All'; // Track category name
  List<Product> _products = []; // Store fetched products
  List<Product> _originalProducts = []; // Store original product list
  List<CollectionModal> _collections = []; // Store fetched collections
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
      if (catId.toLowerCase() == 'collections') {
        setState(() {
          _selectedCategoryId = -1; // Use a special ID for collections
          _selectedCategoryName = 'Collections';
          _selectedDescription =
          '/ Discover our curated collections of handcrafted pottery, each telling a unique story /'; // Customize description
        });
        _fetchCollections();
        return;
      } else {
        final categoryId = int.tryParse(catId);
        if (categoryId != null) {
          setState(() {
            _selectedCategoryId = categoryId;
            _selectedCategoryName = 'Category $categoryId'; // Update with actual name if available
            // Optionally fetch category name and description from API
          });
          _fetchProductsByCategory(categoryId);
          return;
        }
      }
    }
    // Default to "All" if no category specified
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
        _originalProducts = List.from(filteredProducts); // Store original list
        _collections = []; // Clear collections
        _isHoveredList = List<bool>.filled(filteredProducts.length, false);
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
      final products = await ApiHelper.fetchProductByCatId(catId);
      final filteredProducts =
          products.where((product) => product.isCollection == 0).toList();
      setState(() {
        _products = filteredProducts;
        _originalProducts = List.from(products); // Store original list
        _collections = []; // Clear collections
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

  Future<void> _fetchCollections() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final collections = await ApiHelper.fetchCollectionBanner();
      print('Fetched Collections Data: $collections'); // Print the raw data

      setState(() {
        _collections = collections;
        _products = []; // Clear products
        _originalProducts = []; // Clear original products
        _isHoveredList = List<bool>.filled(collections.length, false);
        _isLoading = false;
        _selectedFilter = null; // Reset filter
      });

      // Print details of each collection
      collections.forEach((collection) {
        print('Collection: ${collection.toString()}');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching collections: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load collections: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load collections: $e')));
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
      _selectedFilter = null; // Reset filter when category changes
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Expanded(
      child: Stack(
        children: [
          // This Listener will catch clicks outside the sort/filter options
          Listener(
            onPointerDown: _handleOutsideClick,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Description
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isLargeScreen ? 545 : 453,
                      right: isLargeScreen ? 172 : 0,
                    ),
                    child: Container(
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
                          right: 90,
                          top: 41,
                          left: 46,
                          bottom: 41,
                        ),
                        child: BarlowText(
                          text: _selectedDescription,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF414141),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Item Count (Products or Collections)
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
                              ? '${_collections.length} Collection${_collections.length == 1
                                  ? ''
                                  : _collections.length == 0
                                  ? ''
                                  : 's'}'
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
                const SizedBox(height: 15),
                // Category Navigation
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
                        CatalogNavigation(
                          selectedCategoryId: _selectedCategoryId,
                          onCategorySelected: onCategorySelected,
                          context: context,
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleSortOptions,
                              child: BarlowText(
                                text: "Sort / New",
                                color: const Color(0xFF30578E),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                enableUnderlineForActiveRoute: true,
                                decorationColor: Color(0xFF30578E),
                                hoverTextColor: const Color(0xFF2876E4),
                              ),
                            ),
                            SizedBox(width: 24),
                            if (!isCollectionView)
                              GestureDetector(
                                onTap: _toggleFilterOptions,
                                child: BarlowText(
                                  text: "Filter / ${_selectedFilter ?? 'All'}",
                                  color: const Color(0xFF30578E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  enableUnderlineForActiveRoute: true,
                                  decorationColor: Color(0xFF30578E),
                                  hoverTextColor: const Color(0xFF2876E4),
                                ),
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
                    : _selectedCategoryName.toLowerCase() == 'collections'
                    ? _collections.isNotEmpty
                        ? Padding(
                          padding: EdgeInsets.only(
                            right:
                                isLargeScreen
                                    ? MediaQuery.of(context).size.width * 0.15
                                    : MediaQuery.of(context).size.width * 0.07,
                            left: isLargeScreen ? 389 : 292,
                            top: 30,
                          ),
                          child: CollectionGrid(collectionList: _collections),
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
        _fetchCollections(); // This fetches the default (newest first)
      } else if (sortOption == 'Oldest') {
        _fetchSortedCollections('asc'); // Assuming 'asc' is oldest first
      }
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
                .where((product) => product.quantity! <= 2 && product.quantity! > 0)
                .toList();

        _isHoveredList = List<bool>.filled(_products.length, false);
      }
    });
  }
}
