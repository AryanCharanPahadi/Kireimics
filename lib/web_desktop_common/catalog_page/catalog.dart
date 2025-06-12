import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../catalog_sale_gridview/catalog_controller1.dart';
import '../catalog_sale_gridview/catalog_sale_gridview.dart';
import '../catalog_sale_gridview/catalog_sale_navigation.dart';
import '../collection/collection.dart' show CollectionGrid;

class CatalogPage extends StatelessWidget {
  final Function(String)? onWishlistChanged;
  const CatalogPage({super.key, this.onWishlistChanged});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CatalogPageController());

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Obx(() {
      if (controller.catalogController.products.isNotEmpty &&
          controller.currentCategoryName.value.toLowerCase() != 'collections') {
        controller.initializeStates(
          controller.catalogController.products.length,
        );
      } else if (controller.collectionList.isNotEmpty &&
          controller.currentCategoryName.value.toLowerCase() == 'collections') {
        controller.initializeStates(controller.collectionList.length);
      }
      final isCollectionView =
          controller.currentCategoryName.value.toLowerCase() == 'collections';
      return Expanded(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
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
                        ), // Removed right padding here to avoid double-padding
                        child: BarlowText(
                          text: controller.currentDescription.value,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF414141),
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
                          controller.currentCategoryName.value.toLowerCase() ==
                                  'collections'
                              ? "${controller.collectionList.length} ${controller.collectionList.length == 1 ? 'Collection' : 'Collections'}"
                              : "${controller.productList.length} ${controller.productList.length == 1 || controller.productList.length == 0 ? 'Product' : 'Products'}",
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
                        CatalogNavigation(
                          selectedCategoryId:
                              controller.selectedCategoryId.value,
                          onCategorySelected: controller.onCategorySelected,
                          fetchAllProducts: controller.fetchAllProducts,
                          context: context,
                        ),
                        Row(
                          children: [
                            if (isCollectionView)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  controller.showSortMenu.value =
                                      !controller.showSortMenu.value;
                                },
                                child: BarlowText(
                                  text: "Sort / New",
                                  color: const Color(0xFF30578E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            if (!isCollectionView)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  controller.showSortMenu.value =
                                      !controller.showSortMenu.value;
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
                            if (!isCollectionView)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  controller.showFilterMenu.value =
                                      !controller.showFilterMenu.value;
                                },
                                child: BarlowText(
                                  text:
                                      "Filter / ${controller.currentFilter.value}",
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
                controller.isLoading.value
                    ? Padding(
                      padding: EdgeInsets.only(
                        left: isLargeScreen ? 389 : 292,
                        top: 80,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : controller.currentCategoryName.value.toLowerCase() ==
                            'collections' &&
                        controller.collectionList.isEmpty
                    ? Padding(
                      padding: EdgeInsets.only(
                        left: isLargeScreen ? 613 : 516,
                        top: 80,
                      ),
                      child: CartEmpty(
                        hideBrowseButton:true,
                        cralikaText: "No products here yet!",

                        barlowText:
                            "Try another category, hopefully you'll find something you like there!",
                      ),
                    )
                    : controller.productList.isEmpty &&
                        controller.currentCategoryName.value.toLowerCase() !=
                            'collections'
                    ? Padding(
                      padding: EdgeInsets.only(
                        left: isLargeScreen ? 613 : 516,
                        top: 80,
                      ),
                      child: SizedBox(
                        width: 344,
                        child: CartEmpty(
                          hideBrowseButton:true,

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
                        child:
                            controller.currentCategoryName.value
                                        .toLowerCase() ==
                                    'collections'
                                ? CollectionGrid(
                                  collectionList: controller.collectionList,
                                )
                                : CategoryProductGrid(
                                  productList: controller.productList,
                                  onWishlistChanged: onWishlistChanged,
                                  isHoveredList: controller.isHoveredList,
                                  onHoverChanged: controller.onHoverChanged,
                                ),
                      ),
                    ),
                // SizedBox(height: 40),
              ],
            ),
            Obx(
                  () => controller.showSortMenu.value
                  ? Positioned(
                right: isLargeScreen ? 300 : 120,
                top: 230,
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
                    children: _buildSortOptions(controller),
                  ),
                ),
              )
                  : SizedBox.shrink(),
            )
            ,

            Obx(
                  () => controller.showFilterMenu.value
                  ? Positioned(
                right: isLargeScreen ? 250 : 80,
                top: 230,
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
                    children: _buildFilterOptions(controller),
                  ),
                ),
              )
                  : SizedBox.shrink(),
            )

          ],
        ),
      );
    });
  }

  List<Widget> _buildSortOptions(CatalogPageController controller) {
    final isCollectionView =
        controller.currentCategoryName.value.toLowerCase() == 'collections';
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
              // Add more collection-specific sort options if needed
            ]
            : [
              // Existing product sort options
              {
                'label': 'Price Low - High',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.productList.sort(
                    (a, b) => a.price.compareTo(b.price),
                  );
                  controller.catalogController.products.assignAll(
                    controller.productList,
                  );
                },
              },
              {
                'label': 'Price High - Low',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.productList.sort(
                    (a, b) => b.price.compareTo(a.price),
                  );
                  controller.catalogController.products.assignAll(
                    controller.productList,
                  );
                },
              },   {
                'label': 'New',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.productList.sort(
                    (a, b) => b.price.compareTo(a.price),
                  );
                  controller.catalogController.products.assignAll(
                    controller.productList,
                  );
                },
              },
            ];

    return options.map((option) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                hoverTextColor: const Color(0xFF2876E4),

              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildFilterOptions(CatalogPageController controller) {
    final options = [
      {
        'label': 'All',
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (controller.currentCategoryName.value.toLowerCase() ==
              'collections') {
            controller.collectionList.assignAll(
              controller.collectionAllProducts,
            );
          } else {
            controller.productList.assignAll(controller.allProducts);
            controller.catalogController.products.assignAll(
              controller.productList,
            );
          }
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
        mainAxisAlignment: MainAxisAlignment.center,
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
                hoverTextColor: const Color(0xFF2876E4),

              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
