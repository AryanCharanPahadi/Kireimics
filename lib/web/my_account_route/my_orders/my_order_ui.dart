import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../../../component/no_result_found/no_order_yet.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/title_service.dart';
import '../../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../../web_desktop_common/view_details_cart/view_detail/view_details_cart.dart';

class MyOrderUiWeb extends StatefulWidget {
  const MyOrderUiWeb({super.key});

  @override
  State<MyOrderUiWeb> createState() => _MyOrderUiWebState();
}

class _MyOrderUiWebState extends State<MyOrderUiWeb> {
  List<Map<String, dynamic>> orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    TitleService.setTitle("Kireimics | View Your Orders");

    getOrderData();
  }

  Future<void> getOrderData() async {
    setState(() {
      _isLoading = true;
    });

    String? userId = await SharedPreferencesHelper.getUserId();

    var response = await ApiHelper.getOrderDetails(userId.toString());

    if (response != null &&
        response['error'] == false &&
        response['data'] != null) {
      List<Map<String, dynamic>> fetchedOrders = [];

      for (var order in response['data']) {
        String createdAt = order['created_at'] ?? '';
        String formattedPlacedDate = _formatDate(createdAt);

        String status = 'Unknown';
        String? deliveredDateFormatted;

        try {
          var awbResponse = await ApiHelper.awbCodeDetails(
            awbCode: order['awb_code'],
          );

          if (awbResponse != null &&
              awbResponse['error'] == false &&
              awbResponse['tracking_data'] != null &&
              awbResponse['tracking_data']['tracking_data'] != null &&
              awbResponse['tracking_data']['tracking_data']['shipment_track'] !=
                  null &&
              awbResponse['tracking_data']['tracking_data']['shipment_track']
                  .isNotEmpty) {
            final trackingInfo =
                awbResponse['tracking_data']['tracking_data']['shipment_track'][0];
            status = trackingInfo['current_status'] ?? 'Unknown';

            if (trackingInfo['delivered_date'] != null &&
                trackingInfo['delivered_date'].toString().isNotEmpty) {
              deliveredDateFormatted = _formatDate(
                trackingInfo['delivered_date'].toString(),
              );
            }
          }
        } catch (_) {}

        fetchedOrders.add({
          'orderNumber': order['order_id'] ?? 'Unknown',
          'awb_code': order['awb_code'] ?? 'Unknown',
          'placedDate': formattedPlacedDate,
          'deliveredDate': deliveredDateFormatted,
          'status': status,
        });
      }

      setState(() {
        orders = fetchedOrders;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    if (status.toLowerCase() == 'delivered') {
      return Color(0xFF268FA2);
    } else if (status.toLowerCase() == 'canceled') {
      return Colors.red;
    } else {
      return const Color(0xFF414141);
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('E, dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width > 1400 ? 389 : 292,
          top: 24,
          right:
              MediaQuery.of(context).size.width > 1400
                  ? MediaQuery.of(context).size.width * 0.15
                  : MediaQuery.of(context).size.width * 0.07,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CralikaFont(
              text: "My Orders",
              fontWeight: FontWeight.w400,
              fontSize: 32,
              lineHeight: 36 / 32,
              letterSpacing: 1.28,
              color: const Color(0xFF414141),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                _navItem("My Account", AppRoutes.myAccount),
                const SizedBox(width: 32),
                _navItem("My Orders", AppRoutes.myOrder),
                const SizedBox(width: 32),
                _navItem("Wishlist", AppRoutes.wishlist),
              ],
            ),
            const SizedBox(height: 32),
            CralikaFont(
              text: "${orders.length} Orders",
              fontWeight: FontWeight.w600,
              fontSize: 20,
              lineHeight: 36 / 32,
              letterSpacing: 1.28,
              color: const Color(0xFF414141),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: RotatingSvgLoader(
                      assetPath: 'assets/footer/footerbg.svg',
                    ),
                  ),
                )
                : orders.isEmpty
                ? Center(
                  child: CartEmpty(
                    cralikaText: "No Orders Yet!",
                    barlowText:
                        "Browse our catalog and complete your purchase. All your orders will appear here.",
                  ),
                )
                : Column(
                  children:
                      orders.map((order) => _buildOrderItem(order)).toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String title, String route) {
    return BarlowText(
      text: title,
      color: const Color(0xFF30578E),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      lineHeight: 1.0,
      route: route,
      enableUnderlineForActiveRoute: true,
      decorationColor: const Color(0xFF30578E),
      onTap: () {
        context.go(route);
      },
      hoverTextColor: const Color(0xFF2876E4),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            top: 13,
            bottom: 36,
            right: 16,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BarlowText(
                    text:
                        "Placed On: ${order['placedDate']}" +
                        (order['deliveredDate'] != null
                            ? " / Delivered On: ${order['deliveredDate']}"
                            : ""),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    lineHeight: 1.4,
                    letterSpacing: 0,
                    color: const Color(0xFF636363),
                  ),

                  BarlowText(
                    text: order['status'],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    lineHeight: 1.4,
                    letterSpacing: 0,
                    color: getStatusColor(order['status']),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        "assets/icons/shopping_bag.svg",
                        height: 27,
                        width: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarlowText(
                        text: "${order['orderNumber']}",
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        lineHeight: 1.0,
                        letterSpacing: 0,
                        color: const Color(0xFF414141),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return ViewDetailsCart(
                                orderId:
                                    order['orderNumber']
                                        .toString(), // passing the order ID
                              );
                              ;
                            },
                          );
                        },
                        child: BarlowText(
                          text: "VIEW DETAILS",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          letterSpacing: 0,
                          color: const Color(0xFF30578E),
                          backgroundColor: const Color(0xFFb9d6ff),
                          hoverTextColor: const Color(0xFF2876E4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
