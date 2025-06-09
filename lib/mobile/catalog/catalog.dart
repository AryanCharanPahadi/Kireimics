import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/no_result_found/no_product_yet.dart';
import '../../component/app_routes/routes.dart';
import '../../component/no_result_found/no_order_yet.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/catalog_sale_gridview/catalog_controller1.dart';
import '../../web_desktop_common/catalog_sale_gridview/catalog_sale_navigation.dart';
import '../../web_desktop_common/collection/collection_modal.dart';
import '../collection/collection.dart';

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CatalogPageController());

    return Obx(() {
      // Initialize states are managed by controller
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
                        text: controller.currentDescription.value,
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
                          isCollectionView
                              ? "${controller.collectionList.length} ${(controller.collectionList.length == 1 || controller.collectionList.length == 0) ? 'Collections' : 'Collections'}"
                              : "${controller.productList.length} ${(controller.productList.length == 1 || controller.productList.length == 0) ? 'Products' : 'Products'}",
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: CatalogNavigation(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    selectedCategoryId: controller.selectedCategoryId.value,
                    onCategorySelected: controller.onCategorySelected,
                    fetchAllProducts: controller.fetchAllProducts,
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
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          controller.showSortMenu.value =
                              !controller.showSortMenu.value;
                        },
                        child: BarlowText(
                          text: "Sort / New",
                          color: Color(0xFF30578E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.04 * 16,
                        ),
                      ),
                      SizedBox(width: 16),
                      if (!isCollectionView)
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            controller.showFilterMenu.value =
                                !controller.showFilterMenu.value;
                          },
                          child: BarlowText(
                            text: "Filter / ${controller.currentFilter.value}",
                            color: Color(0xFF30578E),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            lineHeight: 1.0,
                            letterSpacing: 0.04 * 16,
                          ),
                        ),
                    ],
                  ),
                ),
                controller.isLoading.value
                    ? Padding(
                      padding: const EdgeInsets.only(
                        left: 22,
                        top: 20,
                        right: 22,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : isCollectionView
                    ? controller.collectionList.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.only(
                            left: 22,
                            top: 20,
                            right: 22,
                          ),
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
                            collectionList: controller.collectionList,
                          ),
                        )
                    : controller.productList.isEmpty
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
                                      return 0.50;
                                    } else if (width > 410 && width <= 500) {
                                      return 0.55;
                                    } else if (width > 500 && width <= 600) {
                                      return 0.59;
                                    } else if (width > 600 && width <= 700) {
                                      return 0.62;
                                    } else if (width > 700 && width <= 800) {
                                      return 0.65;
                                    } else {
                                      return 0.50;
                                    }
                                  }(),
                                ),
                            itemCount: controller.productList.length,
                            itemBuilder: (context, index) {
                              final product = controller.productList[index];
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
                                future: controller.fetchStockQuantity(
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
                                                onTap:
                                                     () {
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
                                                            Colors.transparent,
                                                            BlendMode.multiply,
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

                                                  if (isOutOfStock) {
                                                    // Only show out-of-stock image and wishlist icon
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment
                                                                  .centerLeft,
                                                          child: SvgPicture.asset(
                                                            "assets/home_page/outofstock.svg",
                                                            height: 24,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment
                                                                  .centerRight,
                                                          child: FutureBuilder<
                                                            bool
                                                          >(
                                                            future:
                                                                SharedPreferencesHelper.isInWishlist(
                                                                  product.id
                                                                      .toString(),
                                                                ),
                                                            builder: (
                                                              context,
                                                              snapshot,
                                                            ) {
                                                              final isInWishlist =
                                                                  snapshot
                                                                      .data ??
                                                                  false;

                                                              return GestureDetector(
                                                                onTap: () async {
                                                                  if (isInWishlist) {
                                                                    await SharedPreferencesHelper.removeFromWishlist(
                                                                      product.id
                                                                          .toString(),
                                                                    );
                                                                    widget
                                                                        .onWishlistChanged
                                                                        ?.call(
                                                                          'Product Removed From Wishlist',
                                                                        );
                                                                  } else {
                                                                    await SharedPreferencesHelper.addToWishlist(
                                                                      product.id
                                                                          .toString(),
                                                                    );
                                                                    widget
                                                                        .onWishlistChanged
                                                                        ?.call(
                                                                          'Product Added To Wishlist',
                                                                        );
                                                                  }
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                },
                                                                child: SvgPicture.asset(
                                                                  isInWishlist
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
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }

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
                                                      FutureBuilder<bool>(
                                                        future:
                                                            SharedPreferencesHelper.isInWishlist(
                                                              product.id
                                                                  .toString(),
                                                            ),
                                                        builder: (
                                                          context,
                                                          snapshot,
                                                        ) {
                                                          final isInWishlist =
                                                              snapshot.data ??
                                                              false;
                                                          return GestureDetector(
                                                            onTap:
                                                                isOutOfStock
                                                                    ? null
                                                                    : () async {
                                                                      if (isInWishlist) {
                                                                        await SharedPreferencesHelper.removeFromWishlist(
                                                                          product
                                                                              .id
                                                                              .toString(),
                                                                        );
                                                                        widget
                                                                            .onWishlistChanged
                                                                            ?.call(
                                                                              'Product Removed From Wishlist',
                                                                            );
                                                                      } else {
                                                                        await SharedPreferencesHelper.addToWishlist(
                                                                          product
                                                                              .id
                                                                              .toString(),
                                                                        );
                                                                        widget
                                                                            .onWishlistChanged
                                                                            ?.call(
                                                                              'Product Added To Wishlist',
                                                                            );
                                                                      }
                                                                      controller.toggleWishlistState(
                                                                        index,
                                                                        !isInWishlist,
                                                                      );
                                                                    },
                                                            child: SvgPicture.asset(
                                                              isInWishlist
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
                                                          );
                                                        },
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
                                                color: Color(0xFF30578E),
                                                maxLines: 2,
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
                                                    0xFF30578E,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              GestureDetector(
                                                onTap:
                                                    isOutOfStock
                                                        ? () async {
                                                          bool isLoggedIn =
                                                              await _isLoggedIn();

                                                          if (isLoggedIn) {
                                                            widget
                                                                .onWishlistChanged
                                                                ?.call(
                                                                  "We'll notify you when this product is back in stock.",
                                                                );
                                                          } else {
                                                            context.go(
                                                              AppRoutes.logIn,
                                                            );
                                                          }
                                                        }
                                                        : () {
                                                          context.go(
                                                            AppRoutes.cartDetails(
                                                              product.id,
                                                            ),
                                                          );
                                                        },
                                                child: Text(
                                                  isOutOfStock
                                                      ? "NOTIFY ME"
                                                      : "ADD TO CART",
                                                  style: GoogleFonts.barlow(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    height: 1.2,
                                                    letterSpacing: 0.56,
                                                    color: const Color(
                                                      0xFF30578E,
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
                controller.showSortMenu.value
                    ? Positioned(
                      right: 50,
                      top: 370,
                      child: Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildSortOptions(
                            controller,
                            isCollectionView,
                          ),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),
          ),
          Obx(
            () =>
                controller.showFilterMenu.value
                    ? Positioned(
                      right: 16,
                      top: 370,
                      child: Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildFilterOptions(
                            controller,
                            isCollectionView,
                          ),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),
          ),
        ],
      );
    });
  }

  List<Widget> _buildSortOptions(
    CatalogPageController controller,
    bool isCollectionView,
  ) {
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
                  controller.productList.sort(
                    (a, b) => a.price.compareTo(b.price),
                  );
                  controller.catalogController.products.assignAll(
                    controller.productList,
                  );
                  controller.initializeStates(controller.productList.length);
                },
              },
              {
                'label': 'Price: High to Low',
                'onTap': () {
                  controller.showSortMenu.value = false;
                  controller.productList.sort(
                    (a, b) => b.price.compareTo(a.price),
                  );
                  controller.catalogController.products.assignAll(
                    controller.productList,
                  );
                  controller.initializeStates(controller.productList.length);
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
                color: const Color(0xFF30578E),
                hoverBackgroundColor: const Color(0xFFb9d6ff),
                enableHoverBackground: true, // Re-added to match Sale widget
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildFilterOptions(
    CatalogPageController controller,
    bool isCollectionView,
  ) {
    final options = [
      {
        'label': 'All',
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (isCollectionView) {
            controller.collectionList.assignAll(
              controller.collectionAllProducts,
            );
          } else {
            controller.productList.assignAll(controller.allProducts);
            controller.catalogController.products.assignAll(
              controller.productList,
            );
            controller.initializeStates(controller.productList.length);
          }
          controller.currentFilter.value = 'All';
        },
      },
      {
        'label': "Maker's Choice",
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (!isCollectionView) {
            controller.filterMakersChoice();
          }
        },
      },
      {
        'label': 'Few Pieces Left',
        'onTap': () {
          controller.showFilterMenu.value = false;
          if (!isCollectionView) {
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
                fontSize: 14,
                color: const Color(0xFF30578E),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
