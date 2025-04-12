import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/custom_text.dart';
import '../../component/product_details/product_details_modal.dart';
import '../../component/routes.dart';
import '../../component/shared_preferences.dart';

class CartPanelOverlay extends StatefulWidget {
  final int? productId;

  const CartPanelOverlay({Key? key, required this.productId}) : super(key: key);

  @override
  State<CartPanelOverlay> createState() => _CartPanelOverlayState();
}

class _CartPanelOverlayState extends State<CartPanelOverlay> {
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

    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.transparent)),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 504,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(), // OR context.pop() if using GoRouter
                      child: BarlowText(
                        text: "Close",
                        color: Color(0xFF3E5B84),
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.64,
                      ),
                    ),
                    SizedBox(height: 33),
                    CralikaFont(
                      text: "My Cart",
                      color: Color(0xFF414141),
                      fontWeight: FontWeight.w600,
                      fontSize: 32.0,
                      lineHeight: 1.0,
                      letterSpacing: 0.128,
                    ),
                    SizedBox(height: 25),
                    if (productList.isEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              SvgPicture.asset("assets/icons/notFound.svg"),
                              SizedBox(height: 20),
                              CralikaFont(text: "No orders yet!"),
                              SizedBox(height: 10),
                              BarlowText(
                                text:
                                    "What are you waiting for? Browse our wide range of products and bring home something new to love!",
                                fontSize: 18,
                                textAlign: TextAlign.center, // Add this line
                              ),
                              SizedBox(height: 15),
                              GestureDetector(
                                onTap: () {
                                  context.go(AppRoutes.catalog);
                                },
                                child: BarlowText(
                                  text: "BROWSE OUR CATALOG",
                                  backgroundColor: Color(0xFFb9d6ff),
                                  color: Color(0xFF3E5B84),
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            final product = productList[index];
                            final quantity = quantityList[index];

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
                                          children: [
                                            Row(
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
                                                SizedBox(width: 12),
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
                                            SizedBox(height: 14),
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
                                                      onPressed: () {
                                                        if (value > 1) {
                                                          quantity.value--;
                                                          setState(() {});
                                                        }
                                                      },
                                                      padding: EdgeInsets.zero,
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
                                                      onPressed: () {
                                                        quantity.value++;
                                                        setState(() {});
                                                      },
                                                      padding: EdgeInsets.zero,
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
                                                });
                                              },
                                              child: BarlowText(
                                                text: "Remove",
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
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

                    /// ✅ Fixed Subtotal Section at the Bottom
                    if (productList.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CralikaFont(
                                  text: "Subtotal",
                                  color: Color(0xFF414141),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  lineHeight: 1.0,
                                ),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  lineHeight: 1.0,
                                ),
                              ],
                            ),
                            SizedBox(height: 27),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                // In your PROCEED TO CHECKOUT button's onTap:
                                // In your PROCEED TO CHECKOUT button's onTap:
                                onTap: () {
                                  final subtotal = calculateTotal();
                                  context.go(
                                    '${AppRoutes.checkOut}?subtotal=${subtotal.toStringAsFixed(2)}',
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
