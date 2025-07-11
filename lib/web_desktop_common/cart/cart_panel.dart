import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/no_result_found/no_order_yet.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/utilities/utility.dart';
import '../../web/checkout/checkout_controller.dart';
import '../component/rotating_svg_loader.dart';

class CartPanel extends StatefulWidget {
  final int? productId;

  const CartPanel({Key? key, this.productId}) : super(key: key);

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  List<Product> productList = [];
  List<ValueNotifier<int>> quantityList = [];
  List<int?> stockQuantities = []; // New list to track stock quantities
  bool isLoading = true;
  String errorMessage = "";

  double calculateTotal() {
    double total = 0.0;
    for (int i = 0; i < productList.length; i++) {
      if (stockQuantities[i] != null && stockQuantities[i]! > 0) {
        final priceString = productList[i].price.toString().replaceAll(',', '');
        final price = double.tryParse(priceString) ?? 0.0;
        final discount =
            productList[i].discount ?? 0.0; // Ensure discount is not null
        final discountedPrice = price * (1 - discount / 100);
        total += discountedPrice * quantityList[i].value;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    initCart();
    preloadCheckoutData(); // New method to preload data
  }

  Future<void> preloadCheckoutData() async {
    try {
      await checkoutController.loadAddressData();
      String? savedPincode = checkoutController.zipController.text.trim();
      if (savedPincode != null && savedPincode.isNotEmpty) {
        await checkoutController.fetchPincodeData(savedPincode);
      }
    } catch (e) {
      // print('Error preloading checkout data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose all ValueNotifier instances to prevent memory leaks
    for (var quantity in quantityList) {
      quantity.dispose();
    }
    super.dispose();
  }

  final CheckoutController checkoutController = Get.put(CheckoutController());

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
      // print("Error fetching stock: $e");
      return null;
    }
  }

  Future<void> initCart() async {
    try {
      if (widget.productId != null) {
        await SharedPreferencesHelper.addProductId(widget.productId!);
      }

      List<int> storedIds = await SharedPreferencesHelper.getAllProductIds();
      List<Product> fetchedProducts = [];
      List<int?> fetchedStockQuantities = [];

      for (int id in storedIds) {
        final product = await ApiHelper.fetchProductDetailsById(id);
        if (product != null) {
          fetchedProducts.add(product);
          // Fetch stock quantity for this product
          final stock = await fetchStockQuantity(id.toString());
          fetchedStockQuantities.add(stock);
        }
      }

      setState(() {
        productList = fetchedProducts;
        stockQuantities = fetchedStockQuantities;
        quantityList = List.generate(
          fetchedProducts.length,
          (index) => ValueNotifier<int>(
            stockQuantities[index] != null && stockQuantities[index]! > 0
                ? 1
                : 0,
          ),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load cart";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    if (isLoading) {
      return Center(
        child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return Stack(
      children: [
        BlurredBackdrop(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isLargeScreen ? 700 : 504,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final router = GoRouter.of(context);
                        final currentRoute =
                            router.routeInformationProvider.value.uri
                                .toString();

                        if (currentRoute.contains(AppRoutes.checkOut)) {
                          await checkoutController.loadUserData();
                          await checkoutController.loadAddressData();
                          await checkoutController.getShippingTax();
                        }
                        Navigator.of(context).pop();
                      },
                      child: BarlowText(
                        text: "Close",
                        color: Color(0xFF30578E),
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.64,
                        hoverTextColor: const Color(0xFF2876E4),
                      ),
                    ),
                    SizedBox(height: 33),
                    CralikaFont(
                      text: "My Cart",
                      color: Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 24.0,
                      lineHeight: 1.0,
                      letterSpacing: 0.128,
                    ),
                    SizedBox(height: 25),
                    if (productList.isEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: CartEmpty(),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            final product = productList[index];
                            final quantity = quantityList[index];
                            final stock = stockQuantities[index];
                            final isOutOfStock = stock == null || stock == 0;

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        product.thumbnail,
                                        height: 123,
                                        width: 107,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: BarlowText(
                                                    text: product.name,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    lineHeight: 1.0,
                                                    letterSpacing: 0.0,
                                                    color:
                                                        isOutOfStock
                                                            ? Colors.grey
                                                            : Color(0xFF414141),
                                                    softWrap: true,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                BarlowText(
                                                  text:
                                                      isOutOfStock
                                                          ? "Out of Stock"
                                                          : product.discount > 0
                                                          ? "Rs ${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}"
                                                          : "Rs ${product.price.toStringAsFixed(2)}",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  lineHeight: 1.0,
                                                  letterSpacing: 0.0,
                                                  color:
                                                      isOutOfStock
                                                          ? Colors.red
                                                          : Color(0xFF414141),
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 14),
                                            if (!isOutOfStock)
                                              ValueListenableBuilder<int>(
                                                valueListenable: quantity,
                                                builder: (context, value, _) {
                                                  return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.remove,
                                                          color: Color(
                                                            0xFF30578E,
                                                          ),
                                                        ),
                                                        onPressed:
                                                            value > 1
                                                                ? () {
                                                                  quantity
                                                                      .value--;
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                }
                                                                : null,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            BoxConstraints(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8.0,
                                                            ),
                                                        child: Text(
                                                          value.toString(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.add,
                                                          color: Color(
                                                            0xFF30578E,
                                                          ),
                                                        ),
                                                        onPressed:
                                                            stock != null &&
                                                                    value <
                                                                        stock
                                                                ? () {
                                                                  quantity
                                                                      .value++;
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                }
                                                                : null,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            BoxConstraints(),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            SizedBox(height: 35),
                                            GestureDetector(
                                              onTap: () async {
                                                await SharedPreferencesHelper.removeProductId(
                                                  product.id,
                                                );
                                                setState(() {
                                                  productList.removeAt(index);
                                                  quantityList.removeAt(index);
                                                  stockQuantities.removeAt(
                                                    index,
                                                  );
                                                });
                                                await cartNotifier.refresh();
                                              },
                                              child: BarlowText(
                                                text: "REMOVE",
                                                color: Color(0xFF30578E),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                decorationColor: const Color(
                                                  0xFF30578E,
                                                ),
                                                hoverTextColor: const Color(
                                                  0xFF2876E4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Color(0xFF30578E)),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ),
                    if (productList.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset("assets/icons/Subtotal.svg"),
                              ],
                            ),
                            SizedBox(height: 11),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BarlowText(
                                  text:
                                      "(Taxes & shipping calculated at checkout)",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  lineHeight: 1.0,
                                  letterSpacing: 0,
                                ),
                                BarlowText(
                                  text:
                                      "Rs ${calculateTotal().toStringAsFixed(2)}",
                                  color: Color(0xFF414141),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  lineHeight: 1.0,
                                ),
                              ],
                            ),
                            SizedBox(height: 27),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  final router = GoRouter.of(context);
                                  final currentRoute =
                                      router.routeInformationProvider.value.uri
                                          .toString();

                                  final subtotal = calculateTotal();
                                  final productIds = productList
                                      .map((product) => product.id.toString())
                                      .join(',');
                                  final productNames = productList
                                      .map(
                                        (product) =>
                                            Uri.encodeComponent(product.name),
                                      )
                                      .join(',');
                                  final productPrices = productList
                                      .asMap()
                                      .map((index, product) {
                                        final priceString = product.price
                                            .toString()
                                            .replaceAll(',', '');
                                        final price =
                                            double.tryParse(priceString) ?? 0.0;
                                        final discount =
                                            product.discount ?? 0.0;
                                        final effectivePrice =
                                            discount > 0
                                                ? price * (1 - discount / 100)
                                                : price;
                                        return MapEntry(
                                          index,
                                          effectivePrice.toStringAsFixed(2),
                                        );
                                      })
                                      .values
                                      .join(',');
                                  final quantities = quantityList
                                      .map(
                                        (quantity) => quantity.value.toString(),
                                      )
                                      .join(',');
                                  final lengths = productList
                                      .map(
                                        (product) => product.length.toString(),
                                      )
                                      .join(',');
                                  final heights = productList
                                      .map(
                                        (product) => product.height.toString(),
                                      )
                                      .join(',');
                                  final breadths = productList
                                      .map(
                                        (product) => product.breadth.toString(),
                                      )
                                      .join(',');
                                  final weights = productList
                                      .map(
                                        (product) => product.weight.toString(),
                                      )
                                      .join(',');

                                  // Update checkout controller
                                  checkoutController
                                      .productIds
                                      .value = productIds.split(',');
                                  checkoutController
                                      .quantities
                                      .value = quantities.split(',');
                                  checkoutController.heights.value = heights
                                      .split(',');
                                  checkoutController.weights.value = weights
                                      .split(',');
                                  checkoutController.breadths.value = breadths
                                      .split(',');
                                  checkoutController.lengths.value = lengths
                                      .split(',');
                                  checkoutController.calculateDimensions();

                                  final newCheckoutRoute =
                                      '${AppRoutes.checkOut}?'
                                      '&productIds=$productIds'
                                      '&quantities=$quantities';

                                  if (currentRoute.contains(
                                    AppRoutes.checkOut,
                                  )) {
                                    await checkoutController.loadUserData();
                                    await checkoutController.loadAddressData();
                                    await checkoutController.getShippingTax();
                                    router.replace(newCheckoutRoute);

                                    Navigator.of(context).pop();
                                  } else {
                                    context.go(newCheckoutRoute);
                                  }
                                },
                                child: BarlowText(
                                  text: "PROCEED TO CHECKOUT",
                                  color: Color(0xFF30578E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  lineHeight: 1.0,
                                  letterSpacing: 1 * 0.04,
                                  backgroundColor: Color(0xFFb9d6ff),
                                  hoverTextColor: Color(0xFF2876E4),
                                  decorationColor: const Color(0xFF30578E),
                                  hoverDecorationColor: Color(0xFF2876E4),
                                ),
                              ),
                            ),
                            SizedBox(height: 27),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
