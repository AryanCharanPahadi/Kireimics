import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/no_result_found/no_product_yet.dart';
import 'package:kireimics/mobile/collection/collection.dart';
import 'package:kireimics/web_desktop_common/sale/sale_controller.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';
import '../../web_desktop_common/catalog_sale_gridview/catalog_sale_navigation.dart';

class SaleMobile extends StatelessWidget {
  final Function(String)? onWishlistChanged;
  const SaleMobile({super.key, this.onWishlistChanged});

  @override
  Widget build(BuildContext context) {
    final SaleController saleController = Get.put(SaleController());

    return Obx(() {
      // Initialize wishlist states based on the current view
      if (saleController.filteredProductList.isNotEmpty &&
          !saleController.isCollectionView.value) {
        saleController.initializeStates(
          saleController.filteredProductList.length,
        );
      } else if (saleController.isCollectionView.value &&
          saleController.collectionList.isNotEmpty) {
        saleController.initializeStates(saleController.collectionList.length);
      }

      return Stack(
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
                        text: saleController.currentDescription.value,
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
                          saleController.isCollectionView.value
                              ? "${saleController.collectionList.length} ${(saleController.collectionList.length == 1 || saleController.collectionList.length == 0) ? 'Collection' : 'Collections'}"
                              : "${saleController.filteredProductList.length} ${(saleController.filteredProductList.length == 1 || saleController.filteredProductList.length == 0) ? 'Product' : 'Products'}",
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: CatalogNavigation(
                    selectedCategoryId: saleController.selectedCategoryId.value,
                    onCategorySelected: saleController.updateCategory,
                    fetchAllProducts: saleController.fetchAllProducts,
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
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          saleController.showSortMenu.value =
                              !saleController.showSortMenu.value;
                        },
                        child: BarlowText(
                          text: "Sort / New",
                          color: Color(0xFF3E5B84),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.04 * 16,
                        ),
                      ),
                      SizedBox(width: 16),
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
                            color: Color(0xFF3E5B84),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            lineHeight: 1.0,
                            letterSpacing: 0.04 * 16,
                          ),
                        ),
                    ],
                  ),
                ),
                saleController.isLoading.value
                    ? Padding(
                      padding: const EdgeInsets.only(
                        left: 22,
                        top: 20,
                        right: 22,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : saleController.isCollectionView.value
                    ? saleController.collectionList.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.only(
                            left: 22,
                            top: 20,
                            right: 22,
                          ),
                          child: NoProductYet(),
                        )
                        : Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: CollectionMobile(
                            collectionList: saleController.collectionList,
                          ),
                        )
                    : saleController.filteredProductList.isEmpty
                    ? Padding(
                      padding: const EdgeInsets.only(
                        left: 22,
                        top: 20,
                        right: 22,
                      ),
                      child: NoProductYet(),
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
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: () {
                                    double width =
                                        MediaQuery.of(context).size.width;
                                    if (width > 320 && width <= 410) {
                                      return 0.53;
                                    } else if (width > 410 && width <= 500) {
                                      return 0.59;
                                    } else if (width > 500 && width <= 600) {
                                      return 0.62;
                                    } else if (width > 600 && width <= 700) {
                                      return 0.65;
                                    } else if (width > 700 && width <= 800) {
                                      return 0.67;
                                    } else {
                                      return 0.50;
                                    }
                                  }(),
                                ),
                            itemCount:
                                saleController.filteredProductList.length,
                            itemBuilder: (context, index) {
                              final product =
                                  saleController.filteredProductList[index];
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
                                future: saleController.fetchStockQuantity(
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

                                                  return Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          final List<Widget>
                                                          badges = [];

                                                          if (product
                                                                  .isMakerChoice ==
                                                              1) {
                                                            badges.add(
                                                              SvgPicture.asset(
                                                                "assets/home_page/maker_choice.svg",
                                                                height:
                                                                    isMobile
                                                                        ? 40
                                                                        : 32,
                                                              ),
                                                            );
                                                          }

                                                          if (quantity !=
                                                                  null &&
                                                              quantity < 2) {
                                                            if (badges
                                                                .isNotEmpty)
                                                              badges.add(
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                              );
                                                            badges.add(
                                                              SvgPicture.asset(
                                                                "assets/home_page/fewPiecesMobile.svg",
                                                                height:
                                                                    isMobile
                                                                        ? 28
                                                                        : 32,
                                                              ),
                                                            );
                                                          }

                                                          if (product
                                                                  .discount !=
                                                              0) {
                                                            if (badges
                                                                .isNotEmpty)
                                                              badges.add(
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                              );
                                                            badges.add(
                                                              ElevatedButton(
                                                                onPressed: null,
                                                                style: ElevatedButton.styleFrom(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        30,
                                                                    vertical:
                                                                        0, // Reduced vertical padding
                                                                  ),
                                                                  backgroundColor:
                                                                      const Color(
                                                                        0xFFF46856,
                                                                      ),
                                                                  disabledBackgroundColor:
                                                                      const Color(
                                                                        0xFFF46856,
                                                                      ),
                                                                  disabledForegroundColor:
                                                                      Colors
                                                                          .white,
                                                                  elevation: 0,
                                                                  side:
                                                                      BorderSide
                                                                          .none,
                                                                  minimumSize:
                                                                      const Size(
                                                                        0,
                                                                        33,
                                                                      ), // Optional: Set a smaller minimum height
                                                                ),
                                                                child: Text(
                                                                  "${product.discount}% OFF",
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        GoogleFonts.barlow()
                                                                            .fontFamily,
                                                                    fontSize:
                                                                        10, // Reduced font size
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    letterSpacing:
                                                                        0.48,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }

                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: badges,
                                                          );
                                                        },
                                                      ),
                                                      Spacer(),
                                                      GestureDetector(
                                                        onTap:
                                                            isOutOfStock
                                                                ? null
                                                                : () {
                                                                  saleController
                                                                      .toggleWishlist(
                                                                        index,
                                                                        product
                                                                            .id
                                                                            .toString(),
                                                                        onWishlistChanged,
                                                                      );
                                                                },
                                                        child: SvgPicture.asset(
                                                          saleController
                                                                  .wishlistStates[index]
                                                              ? 'assets/home_page/IconWishlist.svg'
                                                              : 'assets/home_page/IconWishlistEmpty.svg',
                                                          width:
                                                              isMobile
                                                                  ? 20
                                                                  : 24,
                                                          height:
                                                              isMobile
                                                                  ? 18
                                                                  : 20,
                                                        ),
                                                      ),
                                                    ],
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
                                                color: Color(0xFF3E5B84),
                                                maxLines: 1,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Rs. ${product.price.toStringAsFixed(2)}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.barlow(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  height: 1.2,
                                                  color: const Color(
                                                    0xFF3E5B84,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              GestureDetector(
                                                onTap:
                                                    isOutOfStock
                                                        ? null
                                                        : () {
                                                          context.go(
                                                            AppRoutes.cartDetails(
                                                              product.id,
                                                            ),
                                                          );
                                                        },
                                                child: Text(
                                                  "ADD TO CART",
                                                  style: GoogleFonts.barlow(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    height: 1.2,
                                                    letterSpacing: 0.56,
                                                    color:
                                                        isOutOfStock
                                                            ? const Color(
                                                              0xFF3E5B84,
                                                            ).withOpacity(0.5)
                                                            : const Color(
                                                              0xFF3E5B84,
                                                            ),
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
          Obx(
            () =>
                saleController.showSortMenu.value
                    ? Positioned(
                      right: 50,
                      top: 350,
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
                      right: 16,
                      top: 350,
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
      );
    });
  }

  List<Widget> _buildSortOptions(SaleController controller) {
    final isCollectionView = controller.isCollectionView.value;

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
                  controller.initializeStates(controller.collectionList.length);
                },
              },
              {
                'label': 'Oldest',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.fetchCollectionListSort(
                    controller.selectedCategoryId.value,
                  );
                  controller.initializeStates(controller.collectionList.length);
                },
              },
            ]
            : [
              {
                'label': 'Price: Low to High',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.sortProductsLowToHigh();
                  controller.initializeStates(
                    controller.filteredProductList.length,
                  );
                },
              },
              {
                'label': 'Price: High to Low',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.sortProductsHighToLow();
                  controller.initializeStates(
                    controller.filteredProductList.length,
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
                fontSize: 14,
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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: option['onTap'] as void Function(),
              child: BarlowText(
                text: option['label'] as String,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF3E5B84),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
