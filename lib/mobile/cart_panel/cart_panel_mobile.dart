import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/routes.dart';
import '../../component/shared_preferences.dart';

class CartPanelMobile extends StatefulWidget {
  final int? productId;

  const CartPanelMobile({Key? key, required this.productId}) : super(key: key);

  @override
  State<CartPanelMobile> createState() => _CartPanelMobileState();
}

class _CartPanelMobileState extends State<CartPanelMobile> {
  List<Product> productList = [];
  List<ValueNotifier<int>> quantityList = [];
  bool isLoading = true;
  String errorMessage = "";
  double calculateTotal() {
    double total = 0.0;
    for (int i = 0; i < productList.length; i++) {
      final priceString = productList[i].price.toString().replaceAll(',', '');
      final price = double.tryParse(priceString) ?? 0.0;
      total += price * quantityList[i].value;
    }
    return total;
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

      for (int id in storedIds) {
        final product = await ApiHelper.fetchProductById(id);
        if (product != null) {
          fetchedProducts.add(product);
        }
      }

      setState(() {
        productList = fetchedProducts;
        quantityList = List.generate(
          fetchedProducts.length,
          (_) => ValueNotifier<int>(1),
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
              fontWeight: FontWeight.w600,
              fontSize: 32.0,
              lineHeight: 1.0,
              letterSpacing: 0.128,
            ),
            SizedBox(height: 19),

            // List of Cart Items with Divider
            ...productList.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              final quantity = quantityList[index];

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First container with the image
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
                      // Second container with text and controls
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: SizedBox(
                            height: 123,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First row: name and price
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CralikaFont(
                                        text: product.name,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        lineHeight: 1.0,
                                        letterSpacing: 0.0,
                                        color: Color(0xFF414141),
                                        softWrap: true,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    CralikaFont(
                                      text: "Rs ${product.price}",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight: 1.0,
                                      letterSpacing: 0.0,
                                      color: Color(0xFF414141),
                                      softWrap: true,
                                    ),
                                  ],
                                ),

                                // Second row: quantity controls
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
                                                color: Color(0xFF3E5B84),
                                              ),
                                              onPressed: () {
                                                if (value > 1) {
                                                  quantity.value--;
                                                  setState(() {});
                                                }
                                              },
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
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Color(0xFF3E5B84),
                                              ),
                                              onPressed: () {
                                                quantity.value++;
                                                setState(() {});
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                // Third row: Remove button
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await SharedPreferencesHelper.removeProductId(
                                          product.id,
                                        );
                                        setState(() {
                                          productList.removeAt(index);
                                          quantityList.removeAt(index);
                                        });
                                      },
                                      child: BarlowText(
                                        text: "Remove",
                                        color: Color(0xFF3E5B84),
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

                  // Divider after each product except last
                  if (index != productList.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: Color(0xFF3E5B84)),
                    ),
                ],
              );
            }).toList(),

            SizedBox(height: 20),

            /// Subtotal Section
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
                      fontWeight: FontWeight.w600,
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
                    CralikaFont(
                      text: "Rs ${calculateTotal().toStringAsFixed(2)}",
                      color: Color(0xFF414141),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.0,
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 27),
            Divider(color: Color(0xFFB9D6FF)),
            SizedBox(height: 22),

            /// Checkout Section
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CralikaFont(
                    text: "Rs ${calculateTotal().toStringAsFixed(2)}",
                    color: Color(0xFF414141),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 40,
                    child: BarlowText(
                      text: "PROCEED TO CHECKOUT",
                      color: Color(0xFF3E5B84),
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      lineHeight: 1.0,
                      letterSpacing: 1 * 0.04,
                      backgroundColor: Color(0xFFb9d6ff),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
