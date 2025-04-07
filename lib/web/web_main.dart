import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/web/catalog/catalog.dart';
import 'package:kireimics/web/contact_us/contact_us.dart';
import 'package:kireimics/web/privacy_policy/privacy_policy_component.dart';
import 'package:kireimics/web/product_view/product_details_web.dart';
import 'package:kireimics/web/sale/sale.dart';
import 'package:kireimics/web/shipping_policy/shipping_policy_component.dart';
import 'package:kireimics/web/about_us/about_page.dart';
import 'package:kireimics/web/home_page_web/home_page_web.dart';
import 'package:kireimics/web/component/custom_footer.dart';
import 'package:kireimics/web/component/custom_header.dart';
import 'package:kireimics/web/component/custom_sidebar.dart';
import 'package:kireimics/web/component/scrollable_header.dart';
import '../component/components.dart';
import '../component/routes.dart';
import 'collection/collection.dart';

class LandingPageWeb extends StatefulWidget {

  final String? initialRoute;

  const LandingPageWeb({super.key, this.initialRoute});

  @override
  State<LandingPageWeb> createState() => _LandingPageWebState();
}

class _LandingPageWebState extends State<LandingPageWeb> {
  final List<String> _sidebarItems = ['Home', 'CATALOG', 'SALE', 'ABOUT'];
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  double _previousScrollOffset = 0.0;
  late String _selectedPage;
  void _handleScroll() {
    final currentScrollOffset = _scrollController.offset;
    const scrollThreshold = 50.0;

    if (currentScrollOffset > _previousScrollOffset &&
        currentScrollOffset > scrollThreshold) {
      if (_isHeaderVisible) {
        setState(() => _isHeaderVisible = false);
      }
    } else if (currentScrollOffset < _previousScrollOffset) {
      if (!_isHeaderVisible) {
        setState(() => _isHeaderVisible = true);
      }
    }

    _previousScrollOffset = currentScrollOffset;
  }

  // Page map similar to mobile version
  final Map<String, Widget Function(String?)> _pageMap = {
    AppRoutes.home: (_) => const HomePageWeb(),
    AppRoutes.about: (_) => const AboutPageWeb(),
    AppRoutes.shippingPolicy: (_) => const ShippingPolicyWeb(),
    AppRoutes.privacyPolicy: (_) => const PrivacyPolicyWeb(),
    AppRoutes.contactUs: (_) => const ContactUs(),
    AppRoutes.catalog: (_) => CatalogWeb(),
    AppRoutes.collection: (_) => const CollectionWeb(),
    AppRoutes.sale: (_) => const SaleWeb(),
    '/product':
        (id) => ProductDetailsWeb(productId: int.tryParse(id ?? '0') ?? 0),
  };

  @override
  void initState() {
    super.initState();
    _selectedPage = _getPageFromRoute(widget.initialRoute ?? AppRoutes.home);
    _scrollController.addListener(_handleScroll);
  }

  String _getPageFromRoute(String route) {
    if (route.startsWith('/product/')) return '/product';
    return _pageMap.containsKey(route) ? route : AppRoutes.home;
  }

  void _handleRouteChange(String route) {
    setState(() {
      _selectedPage = _getPageFromRoute(route);
    });
  }

  @override
  void didUpdateWidget(covariant LandingPageWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoute != oldWidget.initialRoute) {
      _handleRouteChange(widget.initialRoute ?? AppRoutes.home);
    }
  }

  void _onSidebarItemSelected(String item) {
    switch (item) {
      case 'Home':
        context.go(AppRoutes.home);
        break;
      case 'ABOUT':
        context.go(AppRoutes.about);
        break;
      case 'CATALOG':
        context.go(AppRoutes.catalog);
        break;
      case 'SALE':
        context.go(AppRoutes.sale);
        break;
      default:
        context.go(AppRoutes.home);
    }
  }

  void _onFooterItemSelected(String item) {
    switch (item) {
      case 'Shipping Policy':
        context.go(AppRoutes.shippingPolicy);
        break;
      case 'Privacy Policy':
        context.go(AppRoutes.privacyPolicy);
        break;
      case 'Contact':
        context.go(AppRoutes.contactUs);
        break;
      default:
        context.go(AppRoutes.home);
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const ScrollableWebHeader(),
                  SizedBox(height: _isHeaderVisible ? 99 : 0),
                  Row(
                    children: [
                      _selectedPage == '/product'
                          ? _pageMap[_selectedPage]!(
                            widget.initialRoute?.split('/').last,
                          )
                          : _pageMap[_selectedPage]!(null),
                    ],
                  ),

                  const SizedBox(height: 5),
                  CustomWebFooter(onItemSelected: _onFooterItemSelected),
                ],
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ScrollingHeader(),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _isHeaderVisible ? 32 : -99,
              left: 0,
              right: 0,
              child: const CustomWebHeader(),
            ),
            SidebarWeb(
              sidebarItems: _sidebarItems,
              selectedItem: _getSelectedItemFromRoute(_selectedPage),
              onItemSelected: _onSidebarItemSelected,
              scrollController: _scrollController,
            ),
            Positioned(
              bottom: 20,
              right: 45,
              child: SvgPicture.asset(
                "assets/chat_bot/chat.svg",
                width: 36,
                height: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedItemFromRoute(String route) {
    switch (route) {
      case AppRoutes.about:
        return 'ABOUT';
      case AppRoutes.catalog:
        return 'CATALOG';
      case AppRoutes.sale:
        return 'SALE';
      case AppRoutes.collection:
        return 'Collections';
      default:
        return 'Home';
    }
  }
}
