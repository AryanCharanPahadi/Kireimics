import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../../../component/api_helper/api_helper.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/utilities/utility.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../../component/rotating_svg_loader.dart';

class ViewDetailsCart extends StatefulWidget {
  final String? orderId;

  const ViewDetailsCart({super.key, this.orderId});

  @override
  State<ViewDetailsCart> createState() => _ViewDetailsCartState();
}

class _ViewDetailsCartState extends State<ViewDetailsCart> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  String? errorMessage;
  Map<int, String> productNames = {};
  Map<int, String> productImg = {};

  @override
  void initState() {
    super.initState();
    getOrderData();
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

  Future<void> getOrderData() async {
    try {
      var response = await ApiHelper.getOrderDetailsByOrderId(
        widget.orderId.toString(),
      );
      // print('API Response: $response');

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
          // print('AWB Response: $awbResponse');

          if (awbResponse != null &&
              awbResponse['error'] == false &&
              awbResponse['tracking_data'] != null &&
              awbResponse['tracking_data']['tracking_data'] != null) {
            final trackingData = awbResponse['tracking_data']['tracking_data'];

            // Debug entire trackingData
            // print('Tracking Data: $trackingData');

            if (trackingData['shipment_track'] != null &&
                trackingData['shipment_track'].isNotEmpty) {
              final trackingInfo = trackingData['shipment_track'][0];

              status = trackingInfo['current_status'] ?? 'Unknown';
              trackUrl = trackingData['track_url'];

              // Debug EDD access
              // print('EDD key exists: ${trackingData.containsKey('etd')}');
              // print('EDD value: ${trackingData['etd']}');
              // print('EDD type: ${trackingData['etd']?.runtimeType}');

              if (trackingData.containsKey('etd') &&
                  trackingData['etd'] != null &&
                  trackingData['etd'].toString().isNotEmpty) {
                try {
                  final eddDate = DateTime.parse(trackingData['etd']);
                  expectedDelivery = DateFormat(
                    'EEE, d MMM yyyy',
                  ).format(eddDate);
                  // print('Parsed EDD: $expectedDelivery');
                } catch (e) {
                  // print('Error parsing EDD: $e');
                  expectedDelivery = 'N/A';
                }
              } else {
                // print('EDD is null, missing, or empty');
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
                  // print('Parsed Delivered Date: $deliveredDateFormatted');
                } catch (e) {
                  // print('Error parsing delivered date: $e');
                  deliveredDateFormatted = 'N/A';
                }
              } else {
                // print('Delivered date is null or empty');
                deliveredDateFormatted = 'N/A';
              }
            } else {
              // print('No shipment track data available');
              expectedDelivery = 'N/A';
              deliveredDateFormatted = 'N/A';
            }
          } else {
            // print('Invalid AWB response structure');
            expectedDelivery = 'N/A';
            deliveredDateFormatted = 'N/A';
          }
        } catch (e) {
          // print('AWB API error: $e');
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

        await fetchProductNames();
      } else {
        setState(() {
          errorMessage = 'No valid response or data is empty';
          isLoading = false;
        });
        // print(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch order details: $e';
        isLoading = false;
      });
      // print(errorMessage);
    }
  }

  Future<void> fetchProductNames() async {
    try {
      for (var product in orderData!['product_details']) {
        final productId = int.tryParse(product['product_id']) ?? 0;
        if (productId == 0) {
          // print('Invalid product_id: ${product['product_id']}');
          continue;
        }
        final productDetails = await ApiHelper.fetchProductDetailsByIdShowAll(
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
      // print('Error fetching product details: $e');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
    final isLargeScreen2 = screenWidth > 1900;

    if (isLoading) {
      return Center(
        child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
      );
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    String formattedDate = 'N/A';
    if (orderData!['created_at'] != null) {
      try {
        final date = DateTime.parse(orderData!['created_at']);
        formattedDate = DateFormat('EEE, d MMM yyyy').format(date);
      } catch (e) {
        // print('Error parsing date: $e');
      }
    }

    final expectedDelivery = orderData!['expected_delivery'] ?? 'N/A';
    final deliveredDate = orderData!['delivered_date'] ?? 'N/A';
    String deliveryText = "Placed On: $formattedDate";

    // Conditionally build delivery text based on status
    if (orderData!['status'].toLowerCase() == 'delivered' &&
        deliveredDate != 'N/A') {
      deliveryText += " / Delivered On: $deliveredDate";
    } else if (orderData!['status'].toLowerCase() != 'canceled' &&
        expectedDelivery != 'N/A') {
      deliveryText += " / Expected Delivery: $expectedDelivery";
    }

    return Stack(
      children: [
        const BlurredBackdrop(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isLargeScreen ? 550 : 504,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const BarlowText(
                        text: "Close",
                        color: Color(0xFF30578E),
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.64,
                        hoverTextColor: Color(0xFF2876E4),
                      ),
                    ),
                    const SizedBox(height: 33),
                    const CralikaFont(
                      text: "View Details",
                      color: Color(0xFF414141),
                      fontWeight: FontWeight.w400,
                      fontSize: 32.0,
                      lineHeight: 1.0,
                      letterSpacing: 0.128,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BarlowText(
                          text: "${orderData!['order_id']}",
                          color: const Color(0xFF414141),
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          lineHeight: 1.0,
                          letterSpacing: 0.0,
                        ),
                        Builder(
                          builder: (context) {
                            // print('Status in build: ${orderData!['status']}');
                            if (orderData!['status'].toLowerCase() !=
                                'delivered') {
                              return GestureDetector(
                                onTap:
                                    () => _launchTrackUrl(
                                      orderData!['track_url'],
                                    ),
                                child: const BarlowText(
                                  text: "TRACK ORDER",
                                  color: Color(0xFF30578E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  lineHeight: 1.0,
                                  letterSpacing: 0.64,
                                  backgroundColor: Color(0xFFb9d6ff),
                                  hoverTextColor: Color(0xFF2876E4),
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
                          final productId =
                              int.tryParse(product['product_id']) ?? 0;
                          final productName =
                              productNames[productId] ?? 'Loading...';
                          final thumbnailUrl =
                              productImg[productId] ??
                              'https://via.placeholder.com/150';

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
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: BarlowText(
                                                  text: productName,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  lineHeight: 1.0,
                                                  letterSpacing: 0.0,
                                                  color: const Color(
                                                    0xFF414141,
                                                  ),
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
                                          const SizedBox(height: 30),
                                          BarlowText(
                                            text: "x ${product['quantity']}",
                                            color: const Color(0xFF414141),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                          const SizedBox(height: 35),
                                          BarlowText(
                                            text: "VIEW DETAILS",
                                            color: const Color(0xFF30578E),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            hoverBackgroundColor: const Color(
                                              0xFFb9d6ff,
                                            ),
                                            enableHoverBackground: true,
                                            decorationColor: const Color(
                                              0xFF30578E,
                                            ),
                                            hoverTextColor: const Color(
                                              0xFF2876E4,
                                            ),
                                            hoverDecorationColor: const Color(
                                              0xFF2876E4,
                                            ),
                                            onTap: () {
                                              if (productId != 0) {
                                                context.go(
                                                  AppRoutes.productDetails(
                                                    productId,
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
                              const CralikaFont(
                                text: "Total Paid",
                                color: Color(0xFF414141),
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                lineHeight: 1.8,
                                letterSpacing: 0.8,
                              ),
                              BarlowText(
                                text: "Rs. ${orderData!['amount']}",
                                color: const Color(0xFF414141),
                                fontWeight: FontWeight.w400,
                                fontSize: 24,
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
                              const BarlowText(
                                text: "Item Total",
                                color: Color(0xFF414141),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                lineHeight: 1.8,
                                letterSpacing: 0.8,
                              ),
                              BarlowText(
                                text: "Rs. ${orderData!['item_total']}",
                                color: const Color(0xFF414141),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
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
                              const BarlowText(
                                text: "Shipping & Taxes",
                                color: Color(0xFF414141),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                lineHeight: 1.8,
                                letterSpacing: 0.8,
                              ),
                              BarlowText(
                                text:
                                    "Rs. ${double.parse(orderData!['shipping_taxes'].toString()).toStringAsFixed(2)}",
                                color: const Color(0xFF414141),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
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
                              const BarlowText(
                                text: "Payment Method",
                                color: Color(0xFF414141),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                lineHeight: 1.0,
                                letterSpacing: 0.0,
                                textAlign: TextAlign.right,
                              ),
                              BarlowText(
                                text: orderData!['payment_mode'].toUpperCase(),
                                color: const Color(0xFF414141),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                lineHeight: 1.0,
                                letterSpacing: 0.0,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Conditionally position the contact container
                    if (!isLargeScreen) ...[
                      const SizedBox(height: 43),
                      buildContactContainer(context),
                      const SizedBox(height: 44),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        // Positioned contact container for wide screens
        if (isLargeScreen2)
          Positioned(
            bottom: 20,
            right: 44,
            child: Container(
              width: 504,
              child: Padding(
                padding: const EdgeInsets.only(left: 22.0),
                child: buildContactContainer(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildContactContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDDEAFF).withOpacity(0.6),
            offset: const Offset(20, 20),
            blurRadius: 20,
          ),
        ],
        border: Border.all(color: const Color(0xFFDDEAFF), width: 1),
      ),
      height: 83,
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
                const BarlowText(
                  text: "Need help with this order?",
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  lineHeight: 1.0,
                  color: Color(0xFF000000),
                ),
                GestureDetector(
                  onTap: () {
                    context.go(AppRoutes.contactUs);
                  },
                  child: const BarlowText(
                    text: "CONTACT US",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    lineHeight: 1.5,
                    color: Color(0xFF30578E),
                    hoverBackgroundColor: Color(0xFFb9d6ff),
                    enableHoverBackground: true,
                    decorationColor: Color(0xFF30578E),
                    hoverTextColor: Color(0xFF2876E4),
                    hoverDecorationColor: Color(0xFF2876E4),
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
