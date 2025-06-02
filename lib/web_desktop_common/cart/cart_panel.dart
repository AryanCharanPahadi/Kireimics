import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/no_result_found/no_order_yet.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/utilities/utility.dart';

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
        total += price * quantityList[i].value;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    initCart();
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
      return Center(child: CircularProgressIndicator(color: Color(0xFF3E5B84)));
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
                      onTap: () => Navigator.of(context).pop(),
                      child: BarlowText(
                        text: "Close",
                        color: Color(0xFF3E5B84),
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.64,
                        enableHoverUnderline: true,
                        decorationColor: const Color(
                          0xFF3E5B84,
                        ),
                      ),
                    ),
                    SizedBox(height: 33),
                    CralikaFont(
                      text: "My Cart",
                      color: Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 32.0,
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
                                                    fontSize: 20,
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
                                                CralikaFont(
                                                  text:
                                                      isOutOfStock
                                                          ? "Out of Stock"
                                                          : "Rs ${product.price}",
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
                                                            0xFF3E5B84,
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
                                                            0xFF3E5B84,
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
                                              },
                                              child: BarlowText(
                                                text: "REMOVE",
                                                color: Color(0xFF3E5B84),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Color(0xFF3E5B84)),
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
                                CralikaFont(
                                  text:
                                      "Rs ${calculateTotal().toStringAsFixed(2)}",
                                  color: Color(0xFF414141),
                                  fontSize: isLargeScreen ? 27 : 20,
                                  fontWeight: FontWeight.w400,
                                  lineHeight: 1.0,
                                ),
                              ],
                            ),
                            SizedBox(height: 27),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  final subtotal = calculateTotal();
                                  // Create comma-separated strings for product IDs, names, and prices
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
                                      .map(
                                        (product) => product.price
                                            .toString()
                                            .replaceAll(',', ''),
                                      )
                                      .join(',');
                                  // Navigate to checkout with subtotal, product IDs, names, and prices
                                  context.go(
                                    '${AppRoutes.checkOut}?subtotal=${subtotal.toStringAsFixed(2)}&productIds=$productIds&productNames=$productNames&productPrices=$productPrices',
                                  );
                                },
                                child: BarlowText(
                                  text: "PROCEED TO CHECKOUT",
                                  color: Color(0xFF3E5B84),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  lineHeight: 1.0,
                                  letterSpacing: 1 * 0.04,
                                  backgroundColor: Color(0xFFb9d6ff),
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
