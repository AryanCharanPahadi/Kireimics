// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:kireimics/mobile/home_page/home_page_mobile.dart';
// import 'package:kireimics/mobile/shipping_policy/shipping_policy_component.dart';
// import 'package:kireimics/web/component/above_footer.dart';
//
// import '../about_page/about_page.dart';
// import '../component/custom_header_mobile.dart';
// import '../component/footer.dart';
// import '../component/scrolling_header.dart';
//
// class ShippingPolicyMain extends StatefulWidget {
//   const ShippingPolicyMain({super.key});
//
//   @override
//   State<ShippingPolicyMain> createState() => _ShippingPolicyMainState();
// }
//
// class _ShippingPolicyMainState extends State<ShippingPolicyMain> {
//   final ScrollController _scrollController = ScrollController();
//   double _lastScrollOffset = 0.0;
//   bool _isScrollingUp = false;
//   bool _showStickyColumn1 = false;
//   bool _showStickyHeader = false;
//   String _selectedPage = "shippingPolicy"; // Track the selected page
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollListener() {
//     final currentOffset = _scrollController.offset;
//     final isAtTop = currentOffset <= 0;
//     final isPastThreshold = currentOffset > 100;
//
//     _isScrollingUp = currentOffset > _lastScrollOffset;
//     _lastScrollOffset = currentOffset;
//
//     setState(() {
//       if (isAtTop) {
//         _showStickyColumn1 = false;
//         _showStickyHeader = false;
//       } else if (_isScrollingUp) {
//         _showStickyColumn1 = isPastThreshold;
//         _showStickyHeader = false;
//       } else {
//         _showStickyColumn1 = isPastThreshold;
//         _showStickyHeader = isPastThreshold;
//       }
//     });
//   }
//
//   void _onNavItemSelected(String page) {
//     setState(() {
//       _selectedPage = page;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             controller: _scrollController,
//             child: Column(
//               children: [
//                 const ScrollingHeaderMobile(),
//                 CustomHeaderMobile(),
//                 Column1(onNavItemSelected: _onNavItemSelected), // Pass callback
//                 if (_selectedPage == "shippingPolicy") ShippingPolicy(),
//                 if (_selectedPage == "home") HomePageMobile(),
//                 if (_selectedPage == "aboutUs") AboutPage(),
//                 const SizedBox(height: 24),
//                 AboveFooter(),
//                 const SizedBox(height: 27),
//                 Footer(),
//               ],
//             ),
//           ),
//           if (_showStickyHeader || _showStickyColumn1)
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.white,
//                 child: Column(
//                   children: [
//                     if (_showStickyHeader) CustomHeaderMobile(),
//                     if (_showStickyColumn1)
//                       Column1(onNavItemSelected: _onNavItemSelected),
//                   ],
//                 ),
//               ),
//             ),
//           Positioned(
//             left: 300,
//             bottom: 60,
//             right: 10,
//             child: SvgPicture.asset(
//               "assets/chat_bot/chat.svg",
//               width: 36,
//               height: 36,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
