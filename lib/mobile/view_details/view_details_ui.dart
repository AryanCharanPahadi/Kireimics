import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:intl/intl.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';

class ViewDetailsUiMobile extends StatefulWidget {
  const ViewDetailsUiMobile({super.key});

  @override
  State<ViewDetailsUiMobile> createState() => _ViewDetailsUiMobileState();
}

class _ViewDetailsUiMobileState extends State<ViewDetailsUiMobile> {
  String? orderId;
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  String? errorMessage;
  Map<int, String> productNames = {};
  Map<int, String> productImg = {};
  bool showLoginBox = true;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    orderId = uri.queryParameters['orderId'];
    getOrderData();
  }

  Future<void> getOrderData() async {
    try {
      var response = await ApiHelper.getOrderDetailsByOrderId(
        orderId.toString(),
      );
      print('API Response: $response');

      if (response != null &&
          response['error'] == false &&
          response['data'] != null &&
          response['data'].isNotEmpty) {
        final order = response['data'][0];

        if (order['product_details'] is String) {
          order['product_details'] = jsonDecode(order['product_details']);
        }

        String status = 'Unknown';
        String? deliveredDateFormatted;
        String? trackUrl;
        String? expectedDelivery;

        try {
          var awbResponse = await ApiHelper.awbCodeDetails(
            awbCode: order['awb_code'],
          );
          print('AWB Response: $awbResponse');

          if (awbResponse != null &&
              awbResponse['error'] == false &&
              awbResponse['tracking_data'] != null &&
              awbResponse['tracking_data']['tracking_data'] != null) {
            final trackingData = awbResponse['tracking_data']['tracking_data'];

            print('Tracking Data: $trackingData');

            if (trackingData['shipment_track'] != null &&
                trackingData['shipment_track'].isNotEmpty) {
              final trackingInfo = trackingData['shipment_track'][0];

              status = trackingInfo['current_status'] ?? 'Unknown';
              trackUrl = trackingData['track_url'];

              if (trackingData.containsKey('etd') &&
                  trackingData['etd'] != null &&
                  trackingData['etd'].toString().isNotEmpty) {
                try {
                  final eddDate = DateTime.parse(trackingData['etd']);
                  expectedDelivery = DateFormat(
                    'EEE, d MMM yyyy',
                  ).format(eddDate);
                } catch (e) {
                  print('Error parsing EDD: $e');
                  expectedDelivery = 'N/A';
                }
              } else {
                expectedDelivery = 'N/A';
              }

              if (trackingInfo['delivered_date'] != null &&
                  trackingInfo['delivered_date'].toString().isNotEmpty) {
                try {
                  final deliveredDate = DateTime.parse(
                    trackingInfo['delivered_date'],
                  );
                  deliveredDateFormatted = DateFormat(
                    'EEE, d MMM yyyy',
                  ).format(deliveredDate);
                } catch (e) {
                  print('Error parsing delivered date: $e');
                  deliveredDateFormatted = 'N/A';
                }
              } else {
                deliveredDateFormatted = 'N/A';
              }
            } else {
              print('No shipment track data available');
              expectedDelivery = 'N/A';
              deliveredDateFormatted = 'N/A';
            }
          } else {
            print('Invalid AWB response structure');
            expectedDelivery = 'N/A';
            deliveredDateFormatted = 'N/A';
          }
        } catch (e) {
          print('AWB API error: $e');
          expectedDelivery = 'N/A';
          deliveredDateFormatted = 'N/A';
        }

        order['status'] = status;
        order['delivered_date'] = deliveredDateFormatted;
        order['track_url'] = trackUrl;
        order['expected_delivery'] = expectedDelivery;

        setState(() {
          orderData = order;
          isLoading = false;
        });

        print(
          'Final orderData status: ${orderData!['status']}, Track URL: ${orderData!['track_url']}, EDD: ${orderData!['expected_delivery']}, Delivered Date: ${orderData!['delivered_date']}',
        );

        await fetchProductNames();
      } else {
        setState(() {
          errorMessage = 'No valid response or data is empty';
          isLoading = false;
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch order details: $e';
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  Future<void> fetchProductNames() async {
    try {
      for (var product in orderData!['product_details']) {
        final productId = int.tryParse(product['product_id']) ?? 0;
        if (productId == 0) {
          print('Invalid product_id: ${product['product_id']}');
          continue;
        }
        final productDetails = await ApiHelper.fetchProductDetailsById(
          productId,
        );
        if (productDetails != null) {
          setState(() {
            productNames[productId] = productDetails.name;
            productImg[productId] = productDetails.thumbnail;
          });
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Color getStatusColor(String status) {
    if (status.toLowerCase() == 'delivered') {
      return Colors.green;
    } else if (status.toLowerCase() == 'canceled') {
      return Colors.red;
    } else {
      return const Color(0xFF414141);
    }
  }

  Future<void> _launchTrackUrl(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch tracking URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            BarlowText(
              text: errorMessage!,
              color: Colors.red,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              lineHeight: 1.4,
              letterSpacing: 0.0,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                getOrderData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30578E),
              ),
              child: const BarlowText(
                text: "Retry",
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (orderData == null) {
      return const Center(
        child: BarlowText(
          text: "No order data available",
          color: Color(0xFF414141),
          fontWeight: FontWeight.w400,
          fontSize: 16,
          lineHeight: 1.4,
          letterSpacing: 0.0,
          textAlign: TextAlign.center,
        ),
      );
    }

    String formattedDate = 'N/A';
    if (orderData!['created_at'] != null) {
      try {
        final date = DateTime.parse(orderData!['created_at']);
        formattedDate = DateFormat('EEE, d MMM yyyy').format(date);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    final expectedDelivery = orderData!['expected_delivery'] ?? 'N/A';
    final deliveredDate = orderData!['delivered_date'] ?? 'N/A';
    String deliveryText = "Placed On: $formattedDate";

    if (orderData!['status'].toLowerCase() == 'delivered' &&
        deliveredDate != 'N/A') {
      deliveryText += " / Delivered On: $deliveredDate";
    } else if (orderData!['status'].toLowerCase() != 'canceled' &&
        expectedDelivery != 'N/A') {
      deliveryText += " / Expected Delivery: $expectedDelivery";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.myOrder);
            },
            child: SvgPicture.asset(
              "assets/icons/closeIcon.svg",
              height: 18,
              width: 18,
            ),
          ),
          const SizedBox(height: 20),
          CralikaFont(
            text: "Order Details",
            color: const Color(0xFF414141),
            fontWeight: FontWeight.w400,
            fontSize: 24.0,
            lineHeight: 1.0,
            letterSpacing: 0.128,
          ),
          const SizedBox(height: 27),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BarlowText(
                text: "${orderData!['order_id']}",
                color: const Color(0xFF414141),
                fontWeight: FontWeight.w400,
                fontSize: 16,
                lineHeight: 1.0,
                letterSpacing: 0.0,
              ),
              Builder(
                builder: (context) {
                  print('Status in build: ${orderData!['status']}');
                  if (orderData!['status'].toLowerCase() != 'delivered') {
                    return GestureDetector(
                      onTap: () => _launchTrackUrl(orderData!['track_url']),
                      child: BarlowText(
                        text: "TRACK ORDER",
                        color: const Color(0xFF30578E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        lineHeight: 1.0,
                        letterSpacing: 0.64,
                        backgroundColor: const Color(0xFFb9d6ff),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          BarlowText(
            text: deliveryText,
            color: const Color(0xFF414141),
            fontWeight: FontWeight.w400,
            fontSize: 14,
            lineHeight: 1.4,
            letterSpacing: 0.0,
          ),
          const SizedBox(height: 12),
          BarlowText(
            text: "${orderData!['status']}",
            color: getStatusColor(orderData!['status']),
            fontWeight: FontWeight.w600,
            fontSize: 14,
            lineHeight: 1.4,
            letterSpacing: 0.0,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: orderData!['product_details'].length,
              itemBuilder: (context, index) {
                final product = orderData!['product_details'][index];
                final productId = int.tryParse(product['product_id']) ?? 0;
                final productName = productNames[productId] ?? 'Loading...';
                final thumbnailUrl =
                    productImg[productId] ?? 'https://via.placeholder.com/150';
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            thumbnailUrl,
                            height: 130,
                            width: 107,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/home_page/gridview_img.jpeg',
                                height: 130,
                                width: 107,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: BarlowText(
                                        text: productName,
                                        maxLines: 2,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        lineHeight: 1.0,
                                        letterSpacing: 0.0,
                                        color: const Color(0xFF414141),
                                        softWrap: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    BarlowText(
                                      text: "Rs ${product['price']}",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight: 1.0,
                                      letterSpacing: 0.0,
                                      color: const Color(0xFF414141),
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                BarlowText(
                                  text: "x ${product['quantity']}",
                                  color: const Color(0xFF414141),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                                const SizedBox(height: 47),
                                BarlowText(
                                  text: "VIEW DETAILS",
                                  color: const Color(0xFF30578E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  onTap: () {
                                    if (productId != 0) {
                                      context.go(
                                        AppRoutes.productDetails(productId),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Invalid product ID'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0xFF30578E)),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CralikaFont(
                      text: "Total Paid",
                      color: const Color(0xFF414141),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      lineHeight: 1.8,
                      letterSpacing: 0.8,
                    ),
                    BarlowText(
                      text: "Rs. ${orderData!['amount']}",
                      color: const Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      lineHeight: 1.0,
                      letterSpacing: 0.0,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BarlowText(
                      text: "Item Total",
                      color: const Color(0xFF414141),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      lineHeight: 1.8,
                      letterSpacing: 0.8,
                    ),
                    BarlowText(
                      text: "Rs. ${orderData!['item_total']}",
                      color: const Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 1.0,
                      letterSpacing: 0.0,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BarlowText(
                      text: "Shipping & Taxes",
                      color: const Color(0xFF414141),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      lineHeight: 1.8,
                      letterSpacing: 0.8,
                    ),
                    BarlowText(
                      text:
                          "Rs. ${double.parse(orderData!['shipping_taxes'].toString()).toStringAsFixed(2)}",
                      color: const Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 1.0,
                      letterSpacing: 0.0,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BarlowText(
                      text: "Payment Method",
                      color: const Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 1.0,
                      letterSpacing: 0.0,
                      textAlign: TextAlign.right,
                    ),
                    BarlowText(
                      text: orderData!['payment_mode'].toUpperCase(),
                      color: const Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 1.0,
                      letterSpacing: 0.0,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 27),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDDEAFF).withOpacity(0.6),
                        offset: const Offset(20, 20),
                        blurRadius: 20,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFDDEAFF),
                      width: 1,
                    ),
                  ),
                  height: 83,
                  width: 444,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 13,
                      bottom: 13,
                      right: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDEAFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/icons/question.svg",
                              height: 27,
                              width: 25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BarlowText(
                              text: "Need help with this order?",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              lineHeight: 1.0,
                              color: const Color(0xFF000000),
                            ),
                            GestureDetector(
                              child: BarlowText(
                                text: "CONTACT US",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                lineHeight: 1.5,
                                color: const Color(0xFF30578E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 16,
          child: Text(
            hintText,
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: const Color(0xFF414141),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            hintText: '',
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: const Color(0xFF414141),
            ),
            contentPadding: const EdgeInsets.only(top: 16),
          ),
          style: const TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
