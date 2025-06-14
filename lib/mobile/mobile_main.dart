import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';
import 'package:kireimics/mobile/address_page/add_address_ui/delete_address.dart';
import 'package:kireimics/mobile/checkout/checkout_page.dart';
import 'package:kireimics/mobile/contact_us/contact_us_component.dart';
import 'package:kireimics/mobile/home_page/home_page_mobile.dart';
import 'package:kireimics/mobile/login/login.dart';
import 'package:kireimics/mobile/my_account_route/my_account/my_account_ui.dart';
import 'package:kireimics/mobile/my_account_route/my_orders/my_order_ui.dart';
import 'package:kireimics/mobile/privacy_policy/privacy_policy_component.dart';
import 'package:kireimics/mobile/product_details/more_product/more_product.dart';
import 'package:kireimics/mobile/product_details/product_details_mobile.dart';
import 'package:kireimics/mobile/sale/sale_mobile.dart';
import 'package:kireimics/mobile/search_gridview/gridview.dart';
import 'package:kireimics/mobile/shipping_policy/shipping_policy_component.dart';
import 'package:kireimics/mobile/sign_in/sign_in.dart';
import 'package:kireimics/mobile/view_details/view_details_ui.dart';
import 'package:kireimics/component/above_footer/above_footer.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import '../component/notification_toast/custom_toast.dart';
import '../component/shared_preferences/shared_preferences.dart';
import '../component/text_fonts/custom_text.dart';
import '../web/checkout/checkout_controller.dart';
import 'about_page/about_page.dart';
import 'cart_panel/cart_panel_mobile.dart';
import 'cart_panel/proceed_to_checkout.dart';
import 'catalog/catalog.dart';
import 'collection/collection_view_mobile.dart';
import 'component/custom_header_mobile.dart';
import 'component/footer/footer.dart';
import 'component/scrolling_header.dart';
import 'login/forgot_password/forget_password_page.dart';
import 'login/forgot_password/forgot_password_ui.dart';
import 'my_account_route/wishlist_ui/wishlist.dart';
import 'dart:js' as js;

class LandingPageMobile extends StatefulWidget {
  final String? initialRoute;

  const LandingPageMobile({super.key, this.initialRoute});

  @override
  State<LandingPageMobile> createState() => _LandingPageMobileState();
}

class _LandingPageMobileState extends State<LandingPageMobile>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final CheckoutController checkoutController = Get.put(CheckoutController());
  final ValueNotifier<double> _cartSubtotal = ValueNotifier<double>(0.0);
  final ValueNotifier<Map<int, int>> _productQuantities =
      ValueNotifier<Map<int, int>>({});
  final ValueNotifier<Map<int, double>> _productPrices = ValueNotifier<Map<int, double>>({});
  final ValueNotifier<Map<int, double?>> _productHeights = ValueNotifier<Map<int, double?>>({});
  final ValueNotifier<Map<int, double?>> _productWidths = ValueNotifier<Map<int, double?>>({});
  final ValueNotifier<Map<int, double?>> _productLengths = ValueNotifier<Map<int, double?>>({});
  final ValueNotifier<Map<int, double?>> _productWeights = ValueNotifier<Map<int, double?>>({});

  double _lastScrollOffset = 0.0;
  bool _isScrollingUp = false;
  bool _showStickyColumn1 = false;
  bool _showStickyHeader = false;
  late String _selectedPage;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false;
  double _subtotal = 0.0;
  final double _deliveryCharge = 50.0;
  late double _total;

  Future<bool> isUserLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  bool isAnyRequiredFieldEmpty() {
    return checkoutController.firstNameController.text.isEmpty ||
        checkoutController.lastNameController.text.isEmpty ||
        checkoutController.emailController.text.isEmpty ||
        checkoutController.address1Controller.text.isEmpty ||
        checkoutController.zipController.text.isEmpty ||
        checkoutController.stateController.text.isEmpty ||
        checkoutController.cityController.text.isEmpty ||
        checkoutController.mobileController.text.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _selectedPage = _getPageFromRoute(widget.initialRoute ?? AppRoutes.home);
    _scrollController.addListener(_scrollListener);

    _updateSubtotalAndTotal();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _animationController.forward();
  }

  void _updateSubtotalAndTotal() {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    _subtotal =
        double.tryParse(uri.queryParameters['subtotal'] ?? '') ??
        _cartSubtotal.value;
    _total = _subtotal + _deliveryCharge;
  }

  final Map<String, Widget Function(String?)> _basePageMap = {
    AppRoutes.about: (_) => const AboutPage(),
    AppRoutes.shippingPolicy: (_) => const ShippingPolicyMobile(),
    AppRoutes.privacyPolicy: (_) => const PrivacyPolicyMobile(),
    AppRoutes.viewDetails: (_) => const ViewDetailsUiMobile(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordUiMobile(),
    AppRoutes.myOrder: (_) => const MyOrderUiMobile(),
  };

  Map<String, Widget Function(String?)> get _pageMap {
    return {
      ..._basePageMap,
      AppRoutes.home:
          (_) => HomePageMobile(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.forgotPasswordMain:
          (_) => ForgotPasswordMainMobile(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.catalog:
          (_) => CatalogMobileComponent(onWishlistChanged: _showNotification),
      AppRoutes.sale: (_) => SaleMobile(onWishlistChanged: _showNotification),
      AppRoutes.logIn:
          (_) => LoginMobile(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.deleteAddress:
          (_) => DeleteAddressMobile(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.signIn:
          (_) => SignInMobile(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.contactUs:
          (_) => ContactUsComponent(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.checkOut:
          (_) => CheckoutPageMobile(
            onWishlistChanged: _showNotification,
            onErrorWishlistChanged: _showErrorNotification,
          ),
      AppRoutes.wishlist:
          (_) => WishlistUiMobile(onWishlistChanged: _showNotification),
      AppRoutes.searchQuery:
          (_) => GridviewSearch(onWishlistChanged: _showNotification),
      AppRoutes.addAddress:
          (_) => AddAddressUiMobile(onWishlistChanged: _showNotification),
      AppRoutes.myAccount:
          (_) => MyAccountUiMobile(onWishlistChanged: _showNotification),
      '/cart':
          (id) => CartPanelMobile(
        productId: int.tryParse(id ?? '0') ?? 0,
        onWishlistChanged: _showNotification,
        onSubtotalChanged: (
            subtotal,
            productQuantities,
            productPrices,
            productHeights,
            productWidths,
            productLengths,
            productWeights,
            ) {
          _cartSubtotal.value = subtotal;
          _productQuantities.value = productQuantities;
          _productPrices.value = productPrices;
          _productHeights.value = productHeights;   // Store heights
          _productWidths.value = productWidths;     // Store widths
          _productLengths.value = productLengths;   // Store lengths
          _productWeights.value = productWeights;   // Store weights
          setState(() {
            _updateSubtotalAndTotal();
          });
          // Print product details
          print('Product Details:');
          productQuantities.forEach((productId, quantity) {
            final price = productPrices[productId] ?? 0.0;
            final height = productHeights[productId] ?? 'N/A';
            final width = productWidths[productId] ?? 'N/A';
            final length = productLengths[productId] ?? 'N/A';
            final weight = productWeights[productId] ?? 'N/A';
            print(
              'Product ID: $productId, Quantity: $quantity, Price: $price, '
                  'Height: $height, Width: $width, Length: $length, Weight: $weight',
            );
          });
        },
      ),
      '/product':
          (id) => ProductDetailsMobile(
            productId: int.tryParse(id ?? '0') ?? 0,
            onWishlistChanged: _showNotification,
          ),
      '/category':
          (id) => CatalogViewAllMobile(
            catId: int.tryParse(id ?? '0') ?? 0,
            onWishlistChanged: _showNotification,
          ),
      '/collection':
          (id) => CollectionViewMobile(
            productIds: int.tryParse(id ?? '0') ?? 0,
            onWishlistChanged: _showNotification,
          ),
    };
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

  String _getPageFromRoute(String route) {
    if (route.startsWith('/product/')) return '/product';
    if (route.startsWith('/cart/')) return '/cart';
    if (route.startsWith('/category/')) return '/category';
    if (route.startsWith('/collection/')) return '/collection';
    return _pageMap.containsKey(route) ? route : AppRoutes.home;
  }

  final ValueNotifier<String?> _notificationMessage = ValueNotifier(null);
  final ValueNotifier<String?> _notificationErrorMessage = ValueNotifier(null);

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _cartSubtotal.dispose();
    _productQuantities.dispose(); // Dispose of the new notifier
    _productHeights.dispose();
    _productWidths.dispose();
    _productLengths.dispose();
    _productWeights.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LandingPageMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoute != oldWidget.initialRoute) {
      setState(() {
        _selectedPage = _getPageFromRoute(
          widget.initialRoute ?? AppRoutes.home,
        );
        _updateSubtotalAndTotal();
      });
      _animationController.reset();
      _animationController.duration = const Duration(milliseconds: 1000);
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutSine,
        ),
      );
      _animationController.forward();
    }
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final isAtTop = currentOffset <= 0;
    final isPastThreshold = currentOffset > 100;

    _isScrollingUp = currentOffset < _lastScrollOffset;
    _lastScrollOffset = currentOffset;

    setState(() {
      if (isAtTop) {
        _showStickyColumn1 = false;
        _showStickyHeader = false;
      } else if (_isScrollingUp) {
        _showStickyColumn1 = isPastThreshold;
        _showStickyHeader = isPastThreshold;
      } else {
        _showStickyColumn1 = isPastThreshold;
        _showStickyHeader = false;
      }
    });
  }

  void _onNavItemSelected(String route) {
    if (_pageMap.containsKey(route)) {
      _isClosing = true;
      _animationController.duration = const Duration(milliseconds: 300);
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0, 1),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      );
      _animationController.reverse();

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && _isClosing) {
          context.go(route);
          setState(() {
            _selectedPage = route;
            _isClosing = false;
            _updateSubtotalAndTotal();
          });
          _animationController.reset();
          _animationController.duration = const Duration(milliseconds: 1000);
          _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOutSine,
            ),
          );
          _animationController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoginRoute = _selectedPage == AppRoutes.logIn;
    final isSignInRoute = _selectedPage == AppRoutes.signIn;
    final isAddAddressRoute = _selectedPage == AppRoutes.addAddress;
    final isViewDetailsRoute = _selectedPage == AppRoutes.viewDetails;
    final isCheckoutRoute = _selectedPage == AppRoutes.checkOut;
    final isDeleteAddressRoute = _selectedPage == AppRoutes.deleteAddress;
    final isForgotPasswordRoute = _selectedPage == AppRoutes.forgotPassword;
    final isForgotPasswordResetRoute =
        _selectedPage == AppRoutes.forgotPasswordMain;
    final isCartRoute = _selectedPage == '/cart';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _isClosing = true;
        _animationController.duration = const Duration(milliseconds: 300);
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 1),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
        await _animationController.reverse();
        if (context.mounted) {
          context.pop();
        }
      },
      child: ColoredBox(
        color: Colors.white,
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
                          if (!isLoginRoute &&
                              !isSignInRoute &&
                              !isAddAddressRoute &&
                              !isDeleteAddressRoute &&
                              !isForgotPasswordRoute &&
                              !isForgotPasswordResetRoute &&
                              !isViewDetailsRoute) ...[
                            ScrollingHeaderMobile(),
                            const CustomHeaderMobile(),
                            Column1(onNavItemSelected: _onNavItemSelected),
                          ],
                          _selectedPage == '/product' ||
                                  _selectedPage == '/category' ||
                                  _selectedPage == '/collection'
                              ? _pageMap[_selectedPage]!(
                                widget.initialRoute?.split('/').last,
                              )
                              : _selectedPage == '/cart'
                              ? _pageMap[_selectedPage]!(
                                widget.initialRoute?.split('/').last,
                              )
                              : _pageMap[_selectedPage]!(null),
                          if (!isLoginRoute &&
                              !isSignInRoute &&
                              !isAddAddressRoute &&
                              !isForgotPasswordRoute &&
                              !isForgotPasswordResetRoute &&
                              !isDeleteAddressRoute &&
                              !isViewDetailsRoute &&
                              _selectedPage != AppRoutes.catalog &&
                              _selectedPage != AppRoutes.sale &&
                              _selectedPage != AppRoutes.checkOut &&
                              _selectedPage != AppRoutes.myAccount &&
                              _selectedPage != AppRoutes.myOrder &&
                              _selectedPage != AppRoutes.wishlist &&
                              _selectedPage != AppRoutes.collection &&
                              _selectedPage != AppRoutes.searchQuery &&
                              _selectedPage != AppRoutes.privacyPolicy &&
                              _selectedPage != '/product' &&
                              _selectedPage != '/collection' &&
                              _selectedPage != '/cart') ...[
                            const SizedBox(height: 40),
                            const AboveFooter(fontSize: 24),
                          ],
                          if (!isLoginRoute &&
                              !isSignInRoute &&
                              !isDeleteAddressRoute &&
                              !isForgotPasswordRoute &&
                              !isAddAddressRoute &&
                              !isForgotPasswordResetRoute &&
                              !isViewDetailsRoute) ...[
                            const SizedBox(height: 27),
                            const Footer(),
                          ],
                        ],
                      ),
                    ),

                    if (isLoginRoute &&
                        MediaQuery.of(context).viewInsets.bottom == 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
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
                            border: Border.all(
                              color: const Color(0xFFDDEAFF),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 13,
                              bottom: 13,
                              right: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDDEAFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/header/IconProfile.svg",
                                      height: 21,
                                      width: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BarlowText(
                                      text: "Don't have an account?",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      lineHeight: 1.0,
                                      color: const Color(0xFF000000),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        context.go(AppRoutes.signIn);
                                      },
                                      child: BarlowText(
                                        text: "SIGN UP NOW",
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
                      ),

                    if (isSignInRoute &&
                        MediaQuery.of(context).viewInsets.bottom == 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
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
                            border: Border.all(
                              color: const Color(0xFFDDEAFF),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 13,
                              bottom: 13,
                              right: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDDEAFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/header/IconProfile.svg",
                                      height: 21,
                                      width: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BarlowText(
                                      text: "Already have an account?",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      lineHeight: 1.0,
                                      color: const Color(0xFF000000),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        context.go(AppRoutes.logIn);
                                      },
                                      child: BarlowText(
                                        text: "LOG IN NOW",
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
                      ),

                    if (!isLoginRoute &&
                        !isSignInRoute &&
                        !isForgotPasswordRoute &&
                        !isDeleteAddressRoute &&
                        !isForgotPasswordResetRoute &&
                        !isAddAddressRoute &&
                        !isViewDetailsRoute &&
                        (_showStickyHeader || _showStickyColumn1))
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
                                Column1(
                                  onNavItemSelected: _onNavItemSelected,
                                  isScrolling: true,
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (!isLoginRoute &&
                        !isSignInRoute &&
                        !isForgotPasswordRoute &&
                        !isDeleteAddressRoute &&
                        !isAddAddressRoute &&
                        !isForgotPasswordResetRoute &&
                        !isViewDetailsRoute)
                      if (isCheckoutRoute)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            color: Colors.white.withOpacity(0.8),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 22.0,
                                top: 21,
                                bottom: 28,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BarlowText(
                                    text: "Rs. ${_total.toStringAsFixed(2)}",
                                    color: Color(0xFF30578E),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    lineHeight: 1.0,
                                    letterSpacing: 1 * 0.04,
                                  ),
                                  SizedBox(height: 8),
                                  BarlowText(
                                    text: "MAKE PAYMENT",
                                    color:
                                        isAnyRequiredFieldEmpty()
                                            ? const Color(
                                              0xFF30578E,
                                            ).withOpacity(0.5)
                                            : const Color(0xFF30578E),
                                    backgroundColor:
                                        isAnyRequiredFieldEmpty()
                                            ? const Color(
                                              0xFFb9d6ff,
                                            ).withOpacity(0.5)
                                            : const Color(0xFFb9d6ff),
                                    hoverTextColor:
                                        isAnyRequiredFieldEmpty()
                                            ? const Color(
                                              0xFF2876E4,
                                            ).withOpacity(0.5)
                                            : const Color(0xFF2876E4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    lineHeight: 1.0,
                                    letterSpacing: 1 * 0.04,
                                    onTap: () async {
                                      if (checkoutController
                                          .firstNameController
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call(
                                              'Please enter your first name',
                                            );
                                        return;
                                      }
                                      if (checkoutController
                                              .firstNameController
                                              .text
                                              .length <
                                          2) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call('First name too short');
                                        return;
                                      }
                                      if (checkoutController
                                          .lastNameController
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call(
                                              'Please enter your last name',
                                            );
                                        return;
                                      }
                                      if (checkoutController
                                              .lastNameController
                                              .text
                                              .length <
                                          2) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call('Last name too short');
                                        return;
                                      }
                                      if (checkoutController
                                          .emailController
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call('Please enter your email');
                                        return;
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(
                                        checkoutController.emailController.text,
                                      )) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call(
                                              'Please enter a valid email',
                                            );
                                        return;
                                      }
                                      if (checkoutController
                                          .address1Controller
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call(
                                              'Please enter your ADDRESS LINE 1',
                                            );
                                        return;
                                      }
                                      if (checkoutController
                                          .zipController
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call('Please enter your Zip');
                                        return;
                                      }
                                      if (checkoutController
                                          .stateController
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call('Please enter your state');
                                        return;
                                      }
                                      if (checkoutController
                                          .cityController
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call('Please enter your city');
                                        return;
                                      }
                                      if (checkoutController
                                          .mobileController
                                          .text
                                          .isEmpty) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call(
                                              'Please enter your phone number',
                                            );
                                        return;
                                      }
                                      if (!RegExp(
                                        r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$',
                                      ).hasMatch(
                                        checkoutController
                                            .mobileController
                                            .text,
                                      )) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call(
                                              'Please enter a valid phone number',
                                            );
                                        return;
                                      }

                                      bool isLoggedIn = await isUserLoggedIn();
                                      if (!isLoggedIn &&
                                          !checkoutController
                                              .addressExists
                                              .value &&
                                          !checkoutController.isChecked) {
                                        checkoutController
                                            .onErrorWishlistChanged
                                            ?.call(
                                              'Please agree to the Privacy and Shipping Policy',
                                            );
                                        return;
                                      }

                                      if (!isLoggedIn) {
                                        bool signUpSuccess =
                                            await checkoutController
                                                .handleSignUp(context);
                                        if (!signUpSuccess) {
                                          checkoutController
                                              .onErrorWishlistChanged
                                              ?.call(
                                                checkoutController
                                                        .signupMessage
                                                        .isNotEmpty
                                                    ? checkoutController
                                                        .signupMessage
                                                    : 'Signup failed, please try again',
                                              );
                                          return;
                                        }
                                      } else {
                                        // For logged-in users, call handleAddAddress if no address exists
                                        if (!checkoutController
                                            .addressExists
                                            .value) {
                                          bool addressSuccess =
                                              await checkoutController
                                                  .handleAddAddress(context);
                                          if (!addressSuccess) {
                                            checkoutController
                                                .onErrorWishlistChanged
                                                ?.call(
                                                  checkoutController
                                                          .signupMessage
                                                          .isNotEmpty
                                                      ? checkoutController
                                                          .signupMessage
                                                      : 'Failed to add address, please try again',
                                                );
                                            return;
                                          }
                                        }
                                      }

                                      final orderId =
                                          'ORDER_${DateTime.now().millisecondsSinceEpoch}';
                                      checkoutController.openRazorpayCheckout(
                                        context,
                                        _total,
                                        orderId,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),




                    if (!isLoginRoute &&
                        !isSignInRoute &&
                        !isForgotPasswordRoute &&
                        !isDeleteAddressRoute &&
                        !isAddAddressRoute &&
                        !isForgotPasswordResetRoute &&
                        !isViewDetailsRoute &&
                        isCartRoute)
                      ValueListenableBuilder<double>(
                        valueListenable: _cartSubtotal,
                        builder: (context, subtotal, _) {
                          return ValueListenableBuilder<Map<int, int>>(
                            valueListenable: _productQuantities,
                            builder: (context, productQuantities, _) {
                              return ValueListenableBuilder<Map<int, double>>(
                                valueListenable: _productPrices,
                                builder: (context, productPrices, _) {
                                  return ValueListenableBuilder<Map<int, double?>>(
                                    valueListenable: _productHeights,
                                    builder: (context, productHeights, _) {
                                      return ValueListenableBuilder<Map<int, double?>>(
                                        valueListenable: _productWidths,
                                        builder: (context, productWidths, _) {
                                          return ValueListenableBuilder<Map<int, double?>>(
                                            valueListenable: _productLengths,
                                            builder: (context, productLengths, _) {
                                              return ValueListenableBuilder<Map<int, double?>>(
                                                valueListenable: _productWeights,
                                                builder: (context, productWeights, _) {
                                                  return subtotal > 0.00
                                                      ? Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: ProceedToCheckoutButton(
                                                      subtotal: subtotal,
                                                      productQuantities: productQuantities,
                                                      productPrices: productPrices,
                                                      productHeights: productHeights,
                                                      productWidths: productWidths,
                                                      productLengths: productLengths,
                                                      productWeights: productWeights,
                                                    ),
                                                  )
                                                      : const SizedBox.shrink();
                                                },
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),

                    ValueListenableBuilder<String?>(
                      valueListenable: _notificationMessage,
                      builder: (context, message, _) {
                        return message != null
                            ? Positioned(
                              top: 30,
                              right: 05,
                              child: NotificationBanner(
                                textColor: Color(0xFF28292A),
                                message: message,
                                iconPath: "assets/icons/success.svg",
                                bannerColor: const Color(0xFF268FA2),
                                onClose: () {
                                  _notificationMessage.value = null;
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
                              top: 30,
                              right: 5,
                              child: NotificationBanner(
                                textColor: Color(0xFF28292A),
                                message: message,
                                iconPath: "assets/icons/error.svg",
                                bannerColor: const Color(0xFFF46856),
                                onClose: () {
                                  _notificationErrorMessage.value = null;
                                },
                              ),
                            )
                            : const SizedBox.shrink();
                      },
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
}
