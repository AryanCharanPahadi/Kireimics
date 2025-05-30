import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/web/address_page/add_address_ui/add_address_ui.dart';
import 'package:kireimics/web/catalog/catalog.dart';
import 'package:kireimics/web/checkout/checkout_page.dart';
import 'package:kireimics/web/contact_us/contact_us.dart';
import 'package:kireimics/web/login_signup/login/login_page.dart';
import 'package:kireimics/web/login_signup/signup/signup.dart';
import 'package:kireimics/web/my_account_route/my_account/my_account_ui.dart';
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
import 'package:kireimics/web/component/profile_dropdown.dart'; // Import the new file
import 'package:kireimics/web/wishlist/wishlist_ui.dart';
import '../component/components.dart';
import '../component/routes.dart';
import 'cart/cart_panel.dart';
import 'collection/collection.dart';
import 'my_account_route/my_orders/my_order_ui.dart';

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
  bool _showProfileDropdown = false;

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

  final ValueNotifier<bool> _showSideContainer = ValueNotifier(false);
  final ValueNotifier<bool> _showSideLogIn = ValueNotifier(false);
  final ValueNotifier<bool> _showSideSignIn = ValueNotifier(false);
  final ValueNotifier<bool> _showSideAddress = ValueNotifier(false);

  final Map<String, Widget Function(String?)> _pageMap = {
    AppRoutes.home: (_) => const HomePageWeb(),
    AppRoutes.about: (_) => const AboutPageWeb(),
    AppRoutes.shippingPolicy: (_) => const ShippingPolicyWeb(),
    AppRoutes.privacyPolicy: (_) => const PrivacyPolicyWeb(),
    AppRoutes.contactUs: (_) => const ContactUs(),
    AppRoutes.catalog: (_) => CategoryListDetails(),
    AppRoutes.collection: (_) => const CollectionWeb(),
    AppRoutes.sale: (_) => const SaleWeb(),
    AppRoutes.checkOut: (_) => const CheckoutPageWeb(),
    AppRoutes.myAccount: (_) => const MyAccountUiWeb(),
    AppRoutes.myOrder: (_) => const MyOrderUiWeb(),
    AppRoutes.wishlist: (_) => const WishlistUiWeb(),
    '/product':
        (id) => ProductDetailsWeb(productId: int.tryParse(id ?? '0') ?? 0),
    '/cart': (id) => CartPanelOverlay(productId: int.tryParse(id ?? '0') ?? 0),
  };
  int? _cartProductId;

  @override
  void initState() {
    super.initState();
    _selectedPage = _getPageFromRoute(widget.initialRoute ?? AppRoutes.home);
    _scrollController.addListener(_handleScroll);

    if ((widget.initialRoute ?? '').startsWith('/cart')) {
      _showSideContainer.value = true;
      final id = widget.initialRoute?.split('/').last;
      _cartProductId = int.tryParse(id ?? '0');
    }

    if ((widget.initialRoute ?? '').startsWith('/log-in')) {
      _showSideLogIn.value = true;
    }
    if ((widget.initialRoute ?? '').startsWith('/sign-in')) {
      _showSideSignIn.value = true;
    }
    if ((widget.initialRoute ?? '').startsWith('/add-address')) {
      _showSideAddress.value = true;
    }
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
      _showSideContainer.value =
          widget.initialRoute?.startsWith('/cart') ?? false;
      _showSideLogIn.value =
          widget.initialRoute?.startsWith('/log-in') ?? false;
      _showSideSignIn.value =
          widget.initialRoute?.startsWith('/sign-in') ?? false;

      _showSideAddress.value =
          widget.initialRoute?.startsWith('/add-address') ?? false;

      if ((widget.initialRoute ?? '').startsWith('/cart')) {
        final id = widget.initialRoute?.split('/').last;
        _cartProductId = int.tryParse(id ?? '0');
      }
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

  void _handleProfileDropdownChanged(bool isVisible) {
    setState(() {
      _showProfileDropdown = isVisible;
    });
  }

  void _closeProfileDropdown() {
    setState(() {
      _showProfileDropdown = false;
    });
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
              child: CustomWebHeader(
                onProfileDropdownChanged: _handleProfileDropdownChanged,
              ),
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
            ValueListenableBuilder<bool>(
              valueListenable: _showSideContainer,
              builder: (context, show, _) {
                return show
                    ? CartPanelOverlay(productId: _cartProductId ?? 0)
                    : const SizedBox.shrink();
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _showSideLogIn,
              builder: (context, show, _) {
                return show ? LoginPage() : const SizedBox.shrink();
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _showSideSignIn,
              builder: (context, show, _) {
                return show ? Signup() : const SizedBox.shrink();
              },
            ),

            ValueListenableBuilder<bool>(
              valueListenable: _showSideAddress,
              builder: (context, show, _) {
                return show ? AddAddressUiWeb() : const SizedBox.shrink();
              },
            ),
            ProfileDropdown(
              isVisible: _showProfileDropdown,
              onClose: _closeProfileDropdown,
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
      case AppRoutes.checkOut:
        return 'Checkout';
      case AppRoutes.myAccount:
        return 'My Account';
      case AppRoutes.myOrder:
        return 'My Orders';
      case AppRoutes.wishlist:
        return 'Wishlist';
      case AppRoutes.collection:
        return 'Collections';
      default:
        return 'Home';
    }
  }
}