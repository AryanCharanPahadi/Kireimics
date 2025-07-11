// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
// import 'package:intl/intl.dart';
// import 'package:kireimics/component/app_routes/routes.dart';
//
// import '../../../component/api_helper/api_helper.dart' show ApiHelper;
// import '../../../component/shared_preferences/shared_preferences.dart';
// import '../../../component/text_fonts/custom_text.dart';
// import '../../../web_desktop_common/view_details_cart/view_detail/view_details_cart.dart';
//
// class MyOrderUiDesktop extends StatefulWidget {
//   const MyOrderUiDesktop({super.key});
//
//   @override
//   State<MyOrderUiDesktop> createState() => _MyOrderUiDesktopState();
// }
//
// class _MyOrderUiDesktopState extends State<MyOrderUiDesktop> {
//   // Sample data for the orders
//   List<Map<String, dynamic>> orders = [];
//
//   @override
//   void initState() {
//     super.initState();
//     getOrderData();
//   }
//
//   Future<void> getOrderData() async {
//     String? userId = await SharedPreferencesHelper.getUserId();
//     print('User ID: $userId');
//
//     var response = await ApiHelper.getOrderDetails(userId.toString());
//     print('API Response: $response');
//
//     if (response != null &&
//         response['error'] == false &&
//         response['data'] != null) {
//       List<Map<String, dynamic>> fetchedOrders = [];
//
//       for (var order in response['data']) {
//         print('Raw Order: $order');
//
//         String createdAt = order['created_at'] ?? '';
//         print('Created At: $createdAt');
//
//         String formattedDate = _formatDate(createdAt);
//         print('Formatted Date: $formattedDate');
//
//         Map<String, dynamic> formattedOrder = {
//           'orderNumber': order['order_id'] ?? 'Unknown',
//           'placedDate': formattedDate,
//           'deliveredDate': formattedDate, // Assuming delivery same as placed
//           'status': 'Delivered',
//         };
//
//         print('Formatted Order: $formattedOrder');
//         fetchedOrders.add(formattedOrder);
//       }
//
//       setState(() {
//         orders = fetchedOrders;
//       });
//
//       print('Final Orders List: $orders');
//     } else {
//       print('No valid response or data is empty');
//     }
//   }
//
//   String _formatDate(String dateString) {
//     try {
//       final dateTime = DateTime.parse(dateString);
//       return DateFormat('E, dd MMM yyyy').format(dateTime);
//     } catch (e) {
//       return dateString;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.only(
//               left: 389,
//               top: 24,
//               right: MediaQuery.of(context).size.width * 0.15,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CralikaFont(
//                   text: "My Orders",
//                   fontWeight: FontWeight.w400,
//                   fontSize: 32,
//                   lineHeight: 36 / 32,
//                   letterSpacing: 1.28,
//                   color: const Color(0xFF414141),
//                 ),
//                 const SizedBox(height: 13),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     BarlowText(
//                       text: "My Account",
//                       color: const Color(0xFF30578E),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       lineHeight: 1.0,
//                       letterSpacing: 1 * 0.04,
//                       route: AppRoutes.myAccount,
//                       enableUnderlineForActiveRoute: true,
//                       decorationColor: const Color(0xFF30578E),
//                       onTap: () {
//                         context.go(AppRoutes.myAccount);
//                       },
//                     ),
//                     const SizedBox(width: 32),
//
//                     BarlowText(
//                       text: "My Orders",
//                       color: const Color(0xFF30578E),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       lineHeight: 1.0,
//                       route: AppRoutes.myOrder,
//                       enableUnderlineForActiveRoute: true,
//                       decorationColor: const Color(0xFF30578E),
//                       onTap: () {
//                         context.go(AppRoutes.myOrder);
//                       },
//                     ),
//                     const SizedBox(width: 32),
//
//                     BarlowText(
//                       text: "Wishlist",
//                       color: const Color(0xFF30578E),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       lineHeight: 1.0,
//                       onTap: () {
//                         context.go(AppRoutes.wishlist);
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CralikaFont(
//                       text: "${orders.length} Orders",
//                       fontWeight: FontWeight.w400,
//                       fontSize: 20,
//                       lineHeight: 36 / 32,
//                       letterSpacing: 1.28,
//                       color: const Color(0xFF414141),
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Orders list
//                     Column(
//                       children:
//                           orders
//                               .map((order) => _buildOrderItem(order))
//                               .toList(),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderItem(Map<String, dynamic> order) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFFDDEAFF).withOpacity(0.6),
//               offset: const Offset(20, 20),
//               blurRadius: 20,
//             ),
//           ],
//           border: Border.all(color: const Color(0xFFDDEAFF), width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.only(
//             left: 16.0,
//             top: 13,
//             bottom: 36,
//             right: 16,
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   BarlowText(
//                     text:
//                         "Placed On: ${order['placedDate']} / Delivered On: ${order['deliveredDate']}",
//                     fontWeight: FontWeight.w400,
//                     fontSize: 14,
//                     lineHeight: 1.4,
//                     letterSpacing: 0,
//                     color: const Color(0xFF636363),
//                   ),
//                   BarlowText(
//                     text: order['status'],
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     lineHeight: 1.4,
//                     letterSpacing: 0,
//                     color: const Color(0xFF268FA2),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: 56,
//                     width: 56,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFDDEAFF),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Center(
//                       child: SvgPicture.asset(
//                         "assets/icons/shopping_bag.svg",
//                         height: 27,
//                         width: 25,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 24),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       BarlowText(
//                         text: "Order# ${order['orderNumber']}",
//                         fontWeight: FontWeight.w400,
//                         fontSize: 20,
//                         lineHeight: 1.0,
//                         letterSpacing: 0,
//                         color: const Color(0xFF414141),
//                       ),
//                       const SizedBox(height: 10),
//                       GestureDetector(
//                         onTap: () {
//                           print("Cart icon tapped");
//                           showDialog(
//                             context: context,
//                             barrierColor: Colors.transparent,
//                             builder: (BuildContext context) {
//                               return ViewDetailsCart();
//                             },
//                           );
//                         },
//                         child: BarlowText(
//                           text: "VIEW DETAILS",
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           lineHeight: 1.0,
//                           letterSpacing: 0,
//                           color: const Color(0xFF30578E),
//                           hoverBackgroundColor: Color(0xFFb9d6ff),
//
//                           enableHoverBackground: true,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget customTextFormField({
//     required String hintText,
//     TextEditingController? controller,
//   }) {
//     return Stack(
//       children: [
//         Positioned(
//           left: 0,
//           top: 16,
//           child: Text(
//             hintText,
//             style: GoogleFonts.barlow(
//               fontWeight: FontWeight.w400,
//               fontSize: 14,
//               color: const Color(0xFF414141),
//             ),
//           ),
//         ),
//         TextFormField(
//           controller: controller,
//           textAlign: TextAlign.right,
//           cursorColor: const Color(0xFF414141),
//           decoration: InputDecoration(
//             border: const UnderlineInputBorder(
//               borderSide: BorderSide(color: Color(0xFF414141)),
//             ),
//             enabledBorder: const UnderlineInputBorder(
//               borderSide: BorderSide(color: Color(0xFF414141)),
//             ),
//             focusedBorder: const UnderlineInputBorder(
//               borderSide: BorderSide(color: Color(0xFF414141)),
//             ),
//             hintText: '',
//             hintStyle: GoogleFonts.barlow(
//               fontWeight: FontWeight.w400,
//               fontSize: 14,
//               height: 1.0,
//               letterSpacing: 0.0,
//               color: const Color(0xFF414141),
//             ),
//             contentPadding: const EdgeInsets.only(top: 16),
//           ),
//           style: const TextStyle(color: Color(0xFF414141)),
//         ),
//       ],
//     );
//   }
// }
