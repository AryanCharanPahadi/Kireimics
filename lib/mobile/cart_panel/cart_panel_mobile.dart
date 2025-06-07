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

class CartPanelMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Updated callback
  final int? productId;

  const CartPanelMobile({
    Key? key,
    required this.productId,
    this.onWishlistChanged,
  }) : super(key: key);

  @override
  State<CartPanelMobile> createState() => _CartPanelMobileState();
}

class _CartPanelMobileState extends State<CartPanelMobile> {
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

  @override
  void initState() {
    super.initState();
    initCart();
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
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF30578E)));
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 33),
            CralikaFont(
              text: "My Cart",
              color: Color(0xFF414141),
              fontWeight: FontWeight.w400,
              fontSize: 24.0,
              lineHeight: 1.0,
              letterSpacing: 0.128,
            ),
            SizedBox(height: 19),
            if (productList.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: CartEmpty(),
              )
            else
              ...productList.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                final quantity = quantityList[index];
                final stock = stockQuantities[index];
                final isOutOfStock = stock == null || stock == 0;

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Image.network(
                                product.thumbnail,
                                height: 123,
                                width: 107,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 17),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: SizedBox(
                              height: 123,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                      SizedBox(width: 8),
                                      BarlowText(
                                        text:
                                            isOutOfStock
                                                ? "Out of Stock"
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
                                  if (!isOutOfStock)
                                    Row(
                                      children: [
                                        ValueListenableBuilder<int>(
                                          valueListenable: quantity,
                                          builder: (context, value, _) {
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: Color(0xFF30578E),
                                                  ),
                                                  onPressed:
                                                      value > 1
                                                          ? () {
                                                            quantity.value--;
                                                            setState(() {});
                                                          }
                                                          : null,
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
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
                                                    color: Color(0xFF30578E),
                                                  ),
                                                  onPressed:
                                                      stock != null &&
                                                              value < stock
                                                          ? () {
                                                            quantity.value++;
                                                            setState(() {});
                                                          }
                                                          : null,
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await SharedPreferencesHelper.removeProductId(
                                            product.id,
                                          );
                                          widget.onWishlistChanged?.call(
                                            'Product Removed From Cart',
                                          );
                                          setState(() {
                                            productList.removeAt(index);
                                            quantityList.removeAt(index);
                                            stockQuantities.removeAt(index);
                                          });
                                        },
                                        child: BarlowText(
                                          text: "REMOVE",
                                          color: Color(0xFF30578E),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (index != productList.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Color(0xFF30578E)),
                      ),
                  ],
                );
              }).toList(),
            SizedBox(height: 20),
            if (productList.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CralikaFont(
                        text: "Subtotal",
                        color: Color(0xFF414141),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        lineHeight: 1.0,
                      ),
                    ],
                  ),
                  SizedBox(height: 11),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 157,
                        child: BarlowText(
                          text: "(Taxes & shipping calculated at checkout)",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
                      BarlowText(
                        text: "Rs ${calculateTotal().toStringAsFixed(2)}",
                        color: Color(0xFF414141),
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        lineHeight: 1.0,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 27),
              Divider(color: Color(0xFFB9D6FF)),
              SizedBox(height: 22),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BarlowText(
                      text: "Rs ${calculateTotal().toStringAsFixed(2)}",
                      color: Color(0xFF414141),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      lineHeight: 1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          final subtotal = calculateTotal();
                          context.go(
                            '${AppRoutes.checkOut}?subtotal=${subtotal.toStringAsFixed(2)}',
                          );
                        },
                        child: BarlowText(
                          text: "PROCEED TO CHECKOUT",
                          color: Color(0xFF30578E),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          lineHeight: 1.0,
                          letterSpacing: 1 * 0.04,
                          backgroundColor: Color(0xFFb9d6ff),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
