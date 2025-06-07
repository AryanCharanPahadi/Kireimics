import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/desktop/contact_us/contact_us.dart';
import 'package:kireimics/web_desktop_common/collection/collection_view.dart';
import '../component/notification_toast/custom_toast.dart';
import '../component/app_routes/routes.dart';
import '../web/about_us/about_page.dart';
import '../web_desktop_common/add_address_ui/add_address_ui.dart';
import '../web_desktop_common/cart/cart_panel.dart';
import '../web_desktop_common/component/profile_dropdown.dart';
import '../web_desktop_common/component/scrollable_header.dart';
import '../web_desktop_common/login_signup/forget_password/forget_password_page.dart';
import '../web_desktop_common/product_view/product_details.dart';
import '../web_desktop_common/sidebar/custom_sidebar.dart';
import '../web_desktop_common/custom_header/header.dart';
import '../web_desktop_common/footer/custom_footer.dart' show Footer;
import '../web_desktop_common/catalog_page/catalog.dart';
import '../web_desktop_common/catalog_sale_gridview/catalog_view_all.dart';
import '../web_desktop_common/login_signup/login/login_page.dart';
import '../web_desktop_common/login_signup/signup/signup.dart';
import '../web_desktop_common/privacy_policy/privacy_policy_component.dart';
import '../web_desktop_common/sale/sale.dart';
import '../web_desktop_common/search_gridview/search_gridview.dart';
import '../web_desktop_common/shipping_policy/shipping_policy_component.dart';
import '../web_desktop_common/view_details_cart/view_detail/view_details_cart.dart';
import '../web_desktop_common/wishlist/wishlist_ui.dart' show WishlistUi;
import 'about_us/about_page.dart';
import 'checkout/checkout_page.dart';
import 'home_page_desktop/home_page_desktop.dart';
import 'my_account_route/my_account/my_account_ui.dart';
import 'my_account_route/my_orders/my_order_ui.dart';

class LandingPageDesktop extends StatefulWidget {
  final String? initialRoute;

  const LandingPageDesktop({super.key, this.initialRoute});

  @override
  State<LandingPageDesktop> createState() => _LandingPageDesktopState();
}

class _LandingPageDesktopState extends State<LandingPageDesktop>
    with SingleTickerProviderStateMixin {
  final List<String> _sidebarItems = ['Home', 'CATALOG', 'SALE', 'ABOUT'];
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  double _previousScrollOffset = 0.0;
  late String _selectedPage;
  bool _showProfileDropdown = false;
  final ValueNotifier<bool> _showSideContainer = ValueNotifier(false);
  final ValueNotifier<bool> _showSideLogIn = ValueNotifier(false);
  final ValueNotifier<bool> _showSideSignIn = ValueNotifier(false);
  final ValueNotifier<bool> _showSideAddress = ValueNotifier(false);
  final ValueNotifier<bool> _showSideCartDetails = ValueNotifier(false);
  final ValueNotifier<String?> _notificationMessage = ValueNotifier(null);
  final ValueNotifier<String?> _notificationErrorMessage = ValueNotifier(null);
  // Animation controller and animations
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false; // Track whether the page is closing
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

  void _showNotification(String message) {
    _notificationMessage.value = message;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _notificationMessage.value = null;
      }
    });
  }

  void _showErrorNotification(String message) {
    _notificationErrorMessage.value = message;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _notificationErrorMessage.value = null;
      }
    });
  }

  final Map<String, Widget Function(String?)> _basePageMap = {
    AppRoutes.about: (_) => const AboutPageWeb(),
    AppRoutes.shippingPolicy: (_) => const ShippingPolicy(),
    AppRoutes.privacyPolicy: (_) => const PrivacyPolicy(),
    AppRoutes.forgetPassword: (_) => const ForgetPasswordPage(),
    // AppRoutes.collection: (_) => const Collection(),
    AppRoutes.sale: (_) => const Sale(),
    AppRoutes.myOrder: (_) => const MyOrderUiDesktop(),

    '/cart': (id) => CartPanel(productId: int.tryParse(id ?? '0') ?? 0),
  };

  Map<String, Widget Function(String?)> get _pageMap {
    return {
      ..._basePageMap,
      AppRoutes.home:
          (_) => HomePageDesktop(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.searchQuery:
          (_) => SearchGridview(onWishlistChanged: _showNotification),
      AppRoutes.wishlist:
          (_) => WishlistUi(onWishlistChanged: _showNotification),
      AppRoutes.catalog:
          (_) => CatalogPage(onWishlistChanged: _showNotification),
      AppRoutes.myAccount:
          (_) => MyAccountUiDesktop(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.checkOut:
          (_) => CheckoutPageDesktop(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.contactUs:
          (_) => ContactUsDesktop(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),

      '/product':
          (id) => ProductDetails(
            productId: int.tryParse(id ?? '0') ?? 0,
            onWishlistChanged: _showNotification,
          ),
      '/category':
          (id) => CatalogViewAll(
            catId: int.tryParse(id ?? '0') ?? 0,
            onWishlistChanged: _showNotification,
          ),

      '/collection':
          (id) => CollectionProductPage(
            productIds: int.tryParse(id ?? '0') ?? 0,
            onWishlistChanged: _showNotification,
          ),
    };
  }

  int? _cartProductId;

  @override
  void initState() {
    super.initState();
    _selectedPage = _getPageFromRoute(widget.initialRoute ?? AppRoutes.home);
    _scrollController.addListener(_handleScroll);

    // Initialize animation controller with opening duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Bottom-to-top duration
      vsync: this,
    );

    // Slide animation: bottom to top for opening
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom for opening
      end: Offset.zero, // End at original position
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine, // Smoother curve for opening
      ),
    );

    // Fade animation: from transparent to opaque
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine, // Smoother curve for opening
      ),
    );

    // Start the opening animation
    _animationController.forward();

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
    if ((widget.initialRoute ?? '').startsWith('/view-cart')) {
      _showSideCartDetails.value = true;
    }
  }

  String _getPageFromRoute(String route) {
    if (route.startsWith('/product/')) return '/product';
    if (route.startsWith('/category/')) return '/category';
    if (route.startsWith('/collection/')) return '/collection';
    return _pageMap.containsKey(route) ? route : AppRoutes.home;
  }

  void _handleRouteChange(String route) {
    _closeProfileDropdown();
    setState(() {
      _selectedPage = _getPageFromRoute(route);
    });
  }

  @override
  void dispose() {
    // Always call super.dispose() first to ensure proper cleanup
    _animationController.dispose();
    _scrollController.dispose();
    _showSideContainer.dispose();
    _showSideLogIn.dispose();
    _showSideSignIn.dispose();
    _showSideAddress.dispose();
    _showSideCartDetails.dispose();
    _notificationMessage.dispose();
    _notificationErrorMessage.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LandingPageDesktop oldWidget) {
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
      _showSideCartDetails.value =
          widget.initialRoute?.startsWith('/view-cart') ?? false;

      if ((widget.initialRoute ?? '').startsWith('/cart')) {
        final id = widget.initialRoute?.split('/').last;
        _cartProductId = int.tryParse(id ?? '0');
      }
    }
    _animationController.reset();
    _animationController.duration = const Duration(
      milliseconds: 1000,
    ); // Bottom-to-top duration
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine, // Smoother curve for opening
      ),
    );
    _animationController.forward();
  }

  void _onSidebarItemSelected(String item) {
    String targetRoute;
    switch (item) {
      case 'Home':
        targetRoute = AppRoutes.home;
        break;
      case 'ABOUT':
        targetRoute = AppRoutes.about;
        break;
      case 'CATALOG':
        targetRoute = AppRoutes.catalog;
        break;
      case 'SALE':
        targetRoute = AppRoutes.sale;
        break;
      default:
        targetRoute = AppRoutes.home;
    }

    // Check if the target route is the same as the current route
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    if (currentRoute == targetRoute) {
      return; // Do not navigate or animate if already on the same route
    }

    // Navigate to the new route immediately
    context.go(targetRoute);

    // Run closing animation for the current page
    _isClosing = true;
    _animationController.duration = const Duration(
      milliseconds: 300,
    ); // Faster top-to-bottom duration
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic, // Snappier curve for closing
      ),
    );
    _animationController.reverse();

    // Start the opening animation for the new page with a slight overlap
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _isClosing) {
        _isClosing = false;
        _animationController.reset();
        _animationController.duration = const Duration(
          milliseconds: 1000,
        ); // Bottom-to-top duration
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutSine, // Smoother curve for opening
          ),
        );
        _animationController.forward();
      }
    });
  }

  void _onFooterItemSelected(String item) {
    String targetRoute;
    switch (item) {
      case 'Shipping Policy':
        targetRoute = AppRoutes.shippingPolicy;
        break;
      case 'Privacy Policy':
        targetRoute = AppRoutes.privacyPolicy;
        break;
      case 'Contact':
        targetRoute = AppRoutes.contactUs;
        break;
      default:
        targetRoute = AppRoutes.home;
    }

    // Check if the target route is the same as the current route
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    if (currentRoute == targetRoute) {
      return; // Do not navigate or animate if already on the same route
    }

    // Navigate to the new route immediately
    context.go(targetRoute);

    // Run closing animation for the current page
    _isClosing = true;
    _animationController.duration = const Duration(
      milliseconds: 300,
    ); // Faster top-to-bottom duration
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic, // Snappier curve for closing
      ),
    );
    _animationController.reverse();

    // Start the opening animation for the new page with a slight overlap
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _isClosing) {
        _isClosing = false;
        _animationController.reset();
        _animationController.duration = const Duration(
          milliseconds: 1000,
        ); // Bottom-to-top duration
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutSine, // Smoother curve for opening
          ),
        );
        _animationController.forward();
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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
    final isForgetPasswordRoute = _selectedPage == AppRoutes.forgetPassword;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _isClosing = true;
        _animationController.duration = const Duration(
          milliseconds: 300,
        ); // Faster top-to-bottom duration
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 1),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic, // Snappier curve for closing
          ),
        );
        await _animationController.reverse();
        if (context.mounted) {
          context.pop();
        }
      },
      child: ColoredBox(
        color: Colors.white, // Persistent background to prevent flicker
        child: Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          if (!isForgetPasswordRoute) const ScrollableHeader(),
                          SizedBox(
                            height:
                                _isHeaderVisible && !isForgetPasswordRoute
                                    ? 99
                                    : 0,
                          ),
                          Row(
                            children: [
                              (_selectedPage == '/product' ||
                                      _selectedPage == '/category' ||
                                      _selectedPage == '/collection')
                                  ? _pageMap[_selectedPage]!(
                                    widget.initialRoute?.split('/').last,
                                  )
                                  : _pageMap[_selectedPage]!(null),
                            ],
                          ),
                          const SizedBox(height: 5),
                          if (!isForgetPasswordRoute)
                            Footer(onItemSelected: _onFooterItemSelected),
                        ],
                      ),
                    ),
                    if (!isForgetPasswordRoute)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ScrollableHeader(),
                      ),
                    if (!isForgetPasswordRoute)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        top: _isHeaderVisible ? 32 : -99,
                        left: 0,
                        right: 0,
                        child: Header(
                          onProfileDropdownChanged:
                              _handleProfileDropdownChanged,
                        ),
                      ),
                    if (!isForgetPasswordRoute)
                      CustomSidebar(
                        sidebarItems: _sidebarItems,
                        selectedItem: _getSelectedItemFromRoute(_selectedPage),
                        onItemSelected: _onSidebarItemSelected,
                        scrollController: _scrollController,
                      ),
                    // Positioned(
                    //   bottom: 20,
                    //   right: 173,
                    //   child: SvgPicture.asset(
                    //     "assets/chat_bot/chat.svg",
                    //     width: 56,
                    //     height: 56,
                    //   ),
                    // ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _showSideContainer,
                      builder: (context, show, _) {
                        return show
                            ? CartPanel(productId: _cartProductId ?? 0)
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
                        return show ? AddAddressUi() : const SizedBox.shrink();
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _showSideCartDetails,
                      builder: (context, show, _) {
                        return show
                            ? ViewDetailsCart()
                            : const SizedBox.shrink();
                      },
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: _notificationMessage,
                      builder: (context, message, _) {
                        return message != null
                            ? Positioned(
                              top: 50,
                              right: 24,
                              child: NotificationBanner(
                                textColor: Color(0xFF28292A),
                                message: message,
                                iconPath: "assets/icons/success.svg",
                                bannerColor: const Color(0xFF268FA2),
                                onClose: () {
                                  _notificationMessage.value =
                                      null; // This will close the banner
                                },
                              ),
                            )
                            : const SizedBox.shrink();
                      },
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: _notificationErrorMessage,
                      builder: (context, message, _) {
                        return message != null
                            ? Positioned(
                              top: 50,
                              right: 24,
                              child: NotificationBanner(
                                textColor: Color(0xFF28292A),
                                message: message,
                                iconPath: "assets/icons/error.svg",
                                bannerColor: const Color(0xFFF46856),
                                onClose: () {
                                  _notificationErrorMessage.value =
                                      null; // This will close the banner
                                },
                              ),
                            )
                            : const SizedBox.shrink();
                      },
                    ),
                    ProfileDropdown(
                      isVisible: _showProfileDropdown,
                      onClose: _closeProfileDropdown,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
