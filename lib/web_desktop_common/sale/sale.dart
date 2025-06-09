import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/web_desktop_common/sale/sale_gridview_compoennt.dart';
import 'package:kireimics/component/no_result_found/no_product_yet.dart';
import 'package:kireimics/web_desktop_common/sale/sale_navigation.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../catalog_sale_gridview/catalog_sale_navigation.dart';
import '../collection/collection.dart';
import 'sale_controller.dart';

class Sale extends StatelessWidget {
  final Function(String)? onWishlistChanged;
  const Sale({super.key, this.onWishlistChanged});

  @override
  Widget build(BuildContext context) {
    final SaleController saleController = Get.put(SaleController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Obx(() {
      if (saleController.filteredProductList.isNotEmpty &&
          !saleController.isCollectionView.value) {
        saleController.initializeStates(
          saleController.filteredProductList.length,
        );
      } else if (saleController.isCollectionView.value &&
          saleController.collectionList.isNotEmpty) {
        saleController.initializeStates(saleController.collectionList.length);
      }

      return Expanded(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isLargeScreen ? 545 : 453,
                      right: isLargeScreen ? 172 : 0, // Updated line
                    ),
                    child: Container(
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
                        padding: const EdgeInsets.only(
                          top: 41,
                          right: 90,
                          left: 46,
                          bottom: 41,
                        ),
                        child: BarlowText(
                          text: saleController.currentDescription.value,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
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
                          saleController.isCollectionView.value
                              ? "${saleController.collectionList.length} ${(saleController.collectionList.length == 1 || saleController.collectionList.length == 0) ? 'Collection' : 'Collections'}"
                              : "${saleController.filteredProductList.length} ${(saleController.filteredProductList.length == 1 || saleController.filteredProductList.length == 0) ? 'Product' : 'Products'}",
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
                        SaleNavigation(
                          selectedCategoryId:
                              saleController.selectedCategoryId.value,
                          onCategorySelected: saleController.updateCategory,
                          fetchAllProducts: saleController.fetchAllProducts,
                          context: context,
                        ),
                        Row(
                          children: [
                            if (saleController.isCollectionView.value)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  saleController.showSortMenu.value =
                                      !saleController.showSortMenu.value;
                                },
                                child: BarlowText(
                                  text: "Sort / New",
                                  color: const Color(0xFF30578E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),

                            if (!saleController.isCollectionView.value)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  saleController.showSortMenu.value =
                                      !saleController.showSortMenu.value;
                                },
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
                            if (!saleController.isCollectionView.value)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  saleController.showFilterMenu.value =
                                      !saleController.showFilterMenu.value;
                                },
                                child: BarlowText(
                                  text:
                                      "Filter / ${saleController.currentFilter.value}",
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
                saleController.isLoading.value
                    ? Padding(
                      padding: EdgeInsets.only(
                        left: isLargeScreen ? 389 : 292,
                        top: 80,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : saleController.isCollectionView.value &&
                        saleController.collectionList.isEmpty
                    ? Padding(
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
                    : saleController.filteredProductList.isEmpty &&
                        !saleController.isCollectionView.value
                    ? Padding(
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
                        child:
                            saleController.isCollectionView.value
                                ? CollectionGrid(
                                  collectionList: saleController.collectionList,
                                )
                                : SaleProductGrid(
                                  productList:
                                      saleController.filteredProductList,
                                  onWishlistChanged: onWishlistChanged,
                                  isHoveredList: saleController.isHoveredList,
                                  onHoverChanged:
                                      saleController.updateHoverState,
                                ),
                      ),
                    ),
                SizedBox(height: 40),
              ],
            ),
            Obx(
              () =>
                  saleController.showSortMenu.value
                      ? Positioned(
                        right: isLargeScreen ? 300 : 120,
                        top: 230,
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildSortOptions(saleController),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            Obx(
              () =>
                  saleController.showFilterMenu.value
                      ? Positioned(
                        right: isLargeScreen ? 250 : 80,
                        top: 230,
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildFilterOptions(saleController),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildSortOptions(SaleController controller) {
    final isCollectionView =
        controller.isCollectionView.value; // Fixed condition

    final options =
        isCollectionView
            ? [
              {
                'label': 'Newest',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.fetchCollectionList(
                    controller.selectedCategoryId.value,
                  );
                },
              },
              {
                'label': 'Oldest',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.fetchCollectionListSort(
                    controller.selectedCategoryId.value,
                  );
                },
              },
            ]
            : [
              {
                'label': 'Price: Low to High',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.sortProductsLowToHigh();
                },
              },
              {
                'label': 'Price: High to Low',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.sortProductsHighToLow();
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
                color: const Color(0xFF30578E),
                hoverBackgroundColor: const Color(0xFFb9d6ff),
                enableHoverBackground: true,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildFilterOptions(SaleController controller) {
    final options = [
      {
        'label': 'All',
        'onTap': () {
          controller.showFilterMenu.value = false;
          controller.resetFilters();
        },
      },
      {
        'label': "Maker's Choice",
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (!controller.isCollectionView.value) {
            controller.filterMakersChoice();
          }
        },
      },
      {
        'label': 'Few Pieces Left',
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (!controller.isCollectionView.value) {
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
                color: const Color(0xFF30578E),
                hoverBackgroundColor: const Color(0xFFb9d6ff),
                enableHoverBackground: true,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
