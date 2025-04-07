import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/mobile/contact_us/contact_us_component.dart';
import 'package:kireimics/mobile/home_page/home_page_mobile.dart';
import 'package:kireimics/mobile/privacy_policy/privacy_policy_component.dart';
import 'package:kireimics/mobile/product_details/product_details_mobile.dart';
import 'package:kireimics/mobile/sale/sale_mobile.dart';
import 'package:kireimics/mobile/shipping_policy/shipping_policy_component.dart';

import 'package:kireimics/web/component/above_footer.dart';
import 'package:kireimics/component/routes.dart';

import 'about_page/about_page.dart';
import 'catalog/catalog.dart';
import 'collection/collection.dart';
import 'component/custom_header_mobile.dart';
import 'component/footer.dart';
import 'component/scrolling_header.dart';

class LandingPageMobile extends StatefulWidget {
  final String? initialRoute;

  const LandingPageMobile({super.key, this.initialRoute});

  @override
  State<LandingPageMobile> createState() => _LandingPageMobileState();
}

class _LandingPageMobileState extends State<LandingPageMobile> {
  final ScrollController _scrollController = ScrollController();
  double _lastScrollOffset = 0.0;
  bool _isScrollingUp = false;
  bool _showStickyColumn1 = false;
  bool _showStickyHeader = false;
  late String _selectedPage;

  @override
  void initState() {
    super.initState();
    _selectedPage = _getPageFromRoute(widget.initialRoute ?? AppRoutes.home);
    _scrollController.addListener(_scrollListener);
  }

  final Map<String, Widget Function(String?)> _pageMap = {
    AppRoutes.home:(_)=> const HomePageMobile(),
    AppRoutes.about:(_)=> const AboutPage(),
    AppRoutes.shippingPolicy:(_)=> const ShippingPolicy(),
    AppRoutes.privacyPolicy:(_)=> const PrivacyPolicyComponent(),
    AppRoutes.contactUs: (_)=>const ContactUsComponent(),
    AppRoutes.catalog:(_)=> const CatalogMobileComponent(),
    AppRoutes.collection: (_)=>const CollectionMobile(),
    AppRoutes.sale: (_)=>const SaleMobile(),
    '/product':
        (id) => ProductDetailsMobile(productId: int.tryParse(id ?? '0') ?? 0),
  };
  String _getPageFromRoute(String route) {
    if (route.startsWith('/product/')) return '/product';

    return _pageMap.containsKey(route) ? route : AppRoutes.home;
  }

  @override
  void didUpdateWidget(covariant LandingPageMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoute != oldWidget.initialRoute) {
      setState(() {
        _selectedPage = _getPageFromRoute(
          widget.initialRoute ?? AppRoutes.home,
        );
      });
    }
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final isAtTop = currentOffset <= 0;
    final isPastThreshold = currentOffset > 100;

    _isScrollingUp = currentOffset > _lastScrollOffset;
    _lastScrollOffset = currentOffset;

    setState(() {
      if (isAtTop) {
        _showStickyColumn1 = false;
        _showStickyHeader = false;
      } else if (_isScrollingUp) {
        _showStickyColumn1 = isPastThreshold;
        _showStickyHeader = false;
      } else {
        _showStickyColumn1 = isPastThreshold;
        _showStickyHeader = isPastThreshold;
      }
    });
  }

  void _onNavItemSelected(String route) {
    if (_pageMap.containsKey(route)) {
      context.go(route);
      setState(() {
        _selectedPage = route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const ScrollingHeaderMobile(),
                const CustomHeaderMobile(),
                Column1(onNavItemSelected: _onNavItemSelected),
                _selectedPage == '/product'
                    ? _pageMap[_selectedPage]!(
                  widget.initialRoute?.split('/').last,
                )
                    : _pageMap[_selectedPage]!(null),                // ProductDetailsMobile(),

                // Only show AboveFooter if the current route is not catalog
                if ((_selectedPage != AppRoutes.catalog) &&
                    (_selectedPage != AppRoutes.sale))
                  const AboveFooter(),
                const SizedBox(height: 27),
                const Footer(),
              ],
            ),
          ),
          if (_showStickyHeader || _showStickyColumn1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    if (_showStickyHeader) const CustomHeaderMobile(),
                    if (_showStickyColumn1)
                      Column1(onNavItemSelected: _onNavItemSelected),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 300,
            bottom: 60,
            right: 10,
            child: SvgPicture.asset(
              "assets/chat_bot/chat.svg",
              width: 36,
              height: 36,
            ),
          ),
        ],
      ),
    );
  }
}
