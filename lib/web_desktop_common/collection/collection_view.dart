import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/no_result_found/no_product_yet.dart';

import '../catalog_sale_gridview/catalog_sale_gridview.dart';

import 'collection_controller.dart';
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

class _CollectionProductPageState extends State<CollectionProductPage>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    final controller = Get.put(CollectionViewController());
    // Fetch products based on the current filter or category
    if (controller.currentFilter.value == 'All') {
      controller.fetchProducts(widget.productIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CollectionViewController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Obx(() {
      // Initialize animations and states when products change
      if (controller.collectionController.products.isNotEmpty) {
        _initializeAnimations(controller.collectionController.products.length);
        controller.initializeStates(
          controller.collectionController.products.length,
        );
      }

      return Expanded(
        child: Stack(
          children: [
            Column(
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
                        color: const Color(0xFF3E5B84),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        lineHeight: 1.0,
                        letterSpacing: 0.04 * 16,
                        onTap: () {
                          context.go(AppRoutes.catalog);
                        },
                      ),
                      const SizedBox(width: 9),
                      SvgPicture.asset(
                        'assets/icons/right_icon.svg',
                        width: 24,
                        height: 24,
                        color: const Color(0xFF3E5B84),
                      ),
                      const SizedBox(width: 9),
                      BarlowText(
                        text: "Collections",
                        color: const Color(0xFF3E5B84),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        lineHeight: 1.0,
                        route: AppRoutes.checkOut,
                        enableUnderlineForActiveRoute: true,
                        decorationColor: const Color(0xFF3E5B84),
                        onTap: () {},
                      ),

                      const SizedBox(width: 9),
                      SvgPicture.asset(
                        'assets/icons/right_icon.svg',
                        width: 24,
                        height: 24,
                        color: const Color(0xFF3E5B84),
                      ),
                      const SizedBox(width: 9),
                      BarlowText(
                        text:
                            controller.productList.isNotEmpty
                                ? controller.productList[0].collectionName ??
                                    'No Collection'
                                : 'No Collection',
                        color: const Color(0xFF3E5B84),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        lineHeight: 1.0,
                        onTap: () {},
                        decoration: TextDecoration.underline,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(left: isLargeScreen ? 545 : 453),
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
                              text: controller.currentDescription.value,
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
                          "${controller.productList.length} ${controller.productList.length == 1 || controller.productList.isEmpty ? 'Product' : 'Products'}",
                      fontWeight: FontWeight.w400,
                      fontSize: 28,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
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
                          selectedCategoryId:
                              controller.selectedCategoryId.value,
                          onCategorySelected:
                              controller
                                  .onCategorySelected, // Matches the signature with productIds
                          context: context,
                          productIds: widget.productIds, // Pass productIds
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                controller.showSortMenu.value =
                                    !controller.showSortMenu.value;
                              },
                              child: BarlowText(
                                text: "Sort / New",
                                color: const Color(0xFF3E5B84),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 24),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                controller.showFilterMenu.value =
                                    !controller.showFilterMenu.value;
                              },
                              child: BarlowText(
                                text:
                                    "Filter / ${controller.currentFilter.value}",
                                color: const Color(0xFF3E5B84),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                controller.isLoading.value
                    ? Padding(
                      padding: EdgeInsets.only(
                        left: isLargeScreen ? 389 : 292,
                        top: 80,
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : controller.productList.isEmpty
                    ? Padding(
                      padding: EdgeInsets.only(
                        left: isLargeScreen ? 389 : 292,
                        top: 80,
                      ),
                      child: Center(
                        child: CartEmpty(
                          cralikaText: "No products here yet!",
                          barlowText:
                              "Try another category, hopefully you'll find something you like there!",
                        ),
                      ),
                    )
                    : SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right:
                              isLargeScreen
                                  ? MediaQuery.of(context).size.width * 0.15
                                  : MediaQuery.of(context).size.width * 0.07,
                          left: isLargeScreen ? 389 : 292,
                          top: 30,
                        ),
                        child: CategoryProductGrid(
                          productList: controller.productList,
                          onWishlistChanged: widget.onWishlistChanged,
                          isHoveredList: controller.isHoveredList,
                          onHoverChanged: controller.onHoverChanged,
                        ),
                      ),
                    ),

                SizedBox(height: 40),
              ],
            ),
            Obx(
              () =>
                  controller.showSortMenu.value
                      ? Positioned(
                        right: isLargeScreen ? 300 : 120,
                        top: 295,
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildSortOptions(controller),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),

            Obx(
              () =>
                  controller.showFilterMenu.value
                      ? Positioned(
                        right: isLargeScreen ? 300 : 90,
                        top: 295,
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildFilterOptions(controller),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  void _initializeAnimations(int count) {
    _controllers = List.generate(
      count,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  List<Widget> _buildSortOptions(CollectionViewController controller) {
    final options = [
      {
        'label': 'Price: Low to High',
        'onTap': () {
          controller.showSortMenu.value = false;
          controller.productList.sort((a, b) => a.price.compareTo(b.price));
          controller.collectionController.products.assignAll(
            controller.productList,
          );
        },
      },
      {
        'label': 'Price: High to Low',
        'onTap': () {
          controller.showSortMenu.value = false;
          controller.productList.sort((a, b) => b.price.compareTo(a.price));
          controller.collectionController.products.assignAll(
            controller.productList,
          );
        },
      },
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
              onTap: option['onTap'] as void Function(),
              child: BarlowText(
                text: option['label'] as String,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF3E5B84),
                hoverBackgroundColor: const Color(0xFFb9d6ff),
                enableHoverBackground: true,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildFilterOptions(CollectionViewController controller) {
    final options = [
      {
        'label': 'All',
        'onTap': () {
          controller.showFilterMenu.value = false;
          controller.fetchProducts(widget.productIds);

          controller.currentFilter.value = 'All';
        },
      },
      {
        'label': "Maker's Choice",
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (controller.currentCategoryName.value.toLowerCase() !=
              'collections') {
            controller.filterMakersChoice();
          }
        },
      },
      {
        'label': 'Few Pieces Left',
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (controller.currentCategoryName.value.toLowerCase() !=
              'collections') {
            controller.filterFewPiecesLeft();
          }
        },
      },
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
              onTap: option['onTap'] as void Function(),
              child: BarlowText(
                text: option['label'] as String,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF3E5B84),
                hoverBackgroundColor: const Color(0xFFb9d6ff),
                enableHoverBackground: true,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
