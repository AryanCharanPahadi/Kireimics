import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';
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
import '../component/text_fonts/custom_text.dart';
import 'about_page/about_page.dart';
import 'cart_panel/cart_panel_mobile.dart';
import 'catalog/catalog.dart';
import 'collection/collection.dart';
import 'collection/collection_view_mobile.dart';
import 'component/custom_header_mobile.dart';
import 'component/footer/footer.dart';
import 'component/scrolling_header.dart';
import 'my_account_route/wishlist_ui/wishlist.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
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
  final double _deliveryCharge = 50.0; // Static delivery charge
  late double _total;

  @override
  void initState() {
    super.initState();
    _selectedPage = _getPageFromRoute(widget.initialRoute ?? AppRoutes.home);
    _scrollController.addListener(_scrollListener);

    // Initialize subtotal and total
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
    _subtotal = double.tryParse(uri.queryParameters['subtotal'] ?? '') ?? 0.0;
    _total = _subtotal + _deliveryCharge;
  }

  final Map<String, Widget Function(String?)> _basePageMap = {
    AppRoutes.about: (_) => const AboutPage(),
    AppRoutes.shippingPolicy: (_) => const ShippingPolicyMobile(),
    AppRoutes.privacyPolicy: (_) => const PrivacyPolicyMobile(),
    AppRoutes.contactUs: (_) => const ContactUsComponent(),
    AppRoutes.viewDetails: (_) => const ViewDetailsUiMobile(),
    AppRoutes.checkOut: (_) => const CheckoutPageMobile(),
    AppRoutes.myOrder: (_) => const MyOrderUiMobile(),
  };

  Map<String, Widget Function(String?)> get _pageMap {
    return {
      ..._basePageMap,
      AppRoutes.home:
          (_) => HomePageMobile(onWishlistChanged: _showNotification),
      AppRoutes.catalog:
          (_) => CatalogMobileComponent(onWishlistChanged: _showNotification),
      AppRoutes.sale: (_) => SaleMobile(onWishlistChanged: _showNotification),
      AppRoutes.logIn: (_) => LoginMobile(onWishlistChanged: _showNotification),
      AppRoutes.signIn:
          (_) => SignInMobile(onWishlistChanged: _showNotification),
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

  String _getPageFromRoute(String route) {
    if (route.startsWith('/product/')) return '/product';
    if (route.startsWith('/cart/')) return '/cart';
    if (route.startsWith('/category/')) return '/category';
    if (route.startsWith('/collection/')) return '/collection';

    return _pageMap.containsKey(route) ? route : AppRoutes.home;
  }

  final ValueNotifier<String?> _notificationMessage = ValueNotifier(null);

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
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
        _updateSubtotalAndTotal(); // Update subtotal and total when route changes
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
            _updateSubtotalAndTotal(); // Update subtotal and total on navigation
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
    void openRazorpayCheckout() async {
      print('openRazorpayCheckout called'); // Debug print
      if (!kIsWeb) {
        print('Not running on web platform'); // Debug print
        return;
      }

      // Check if openRazorpay is available
      if (!js.context.hasProperty('openRazorpay')) {
        print('Error: openRazorpay function not found in JavaScript context');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Payment system not initialized'),
          ),
        );
        return;
      }

      // Generate a mock order ID for testing
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      final options = {
        'key': 'rzp_test_PKUyVj9nF0FvA7',
        'amount': (_total * 100).toInt(),
        'currency': 'INR',
        'name': 'Kireimics',
        'description': 'Payment for order',
        'prefill': {'name': '', 'email': '', 'contact': ''},
        'notes': {'address': 'Customer address'},
        'handler': js.allowInterop((response) async {
          // Convert the JavaScript response object to a JSON string
          final responseJson = js.context['JSON'].callMethod('stringify', [
            response,
          ]);

          // Extract payment details from response
          final paymentId = response['razorpay_payment_id'] ?? 'N/A';
          final orderIdResponse = response['razorpay_order_id'] ?? orderId;
          final signature = response['razorpay_signature'] ?? 'N/A';
          final amount = _total; // From the outer scope
          final status = 'success'; // Since handler is called on success

          // Print client-side response
          print('=== Payment Successful ===');
          print('Payment ID: $paymentId');
          print('Order ID: $orderIdResponse');
          print('Signature: $signature');
          print('Amount: $amount INR');
          print('Status: $status');
          print('Raw Client-Side Response: $responseJson');

          // Fetch full payment details from PHP server
          try {
            final serverResponse = await http.get(
              Uri.parse(
                'http://localhost/17000ft/payment_details.php?payment_id=$paymentId',
              ),
            );

            if (serverResponse.statusCode == 200) {
              final paymentDetails = jsonDecode(serverResponse.body);
              print('=== Full Payment Details ===');
              print('Full Raw Response: ${jsonEncode(paymentDetails)}');
              print('Mode of Payment: ${paymentDetails['method'] ?? 'N/A'}');
              print('Payment ID: ${paymentDetails['id'] ?? 'N/A'}');
              print('Order ID: ${paymentDetails['order_id'] ?? 'N/A'}');
              print(
                'Amount: ${(paymentDetails['amount'] / 100).toStringAsFixed(2)} ${paymentDetails['currency'] ?? 'N/A'}',
              );
              print('Status: ${paymentDetails['status'] ?? 'N/A'}');
              print(
                'Created At: ${DateTime.fromMillisecondsSinceEpoch((paymentDetails['created_at'] * 1000) ?? 0)}',
              );
            } else {
              print('Failed to fetch payment details: ${serverResponse.body}');
            }
          } catch (e) {
            print('Error fetching payment details: $e');
          }

          // Navigate to payment result route
          context.go(
            '${AppRoutes.paymentResult}?success=true&orderId=$orderId&amount=$_total',
          );
        }),
        'modal': {
          'ondismiss': js.allowInterop(() {
            print('Payment modal dismissed'); // Debug print
            context.go(
              '${AppRoutes.paymentResult}?success=false&orderId=$orderId&amount=$_total',
            );
          }),
        },
      };

      print('Razorpay options: $options'); // Debug print

      try {
        print('Calling js.context.callMethod for openRazorpay'); // Debug print
        js.context.callMethod('openRazorpay', [js.JsObject.jsify(options)]);
      } catch (e) {
        print('Error initiating payment: $e'); // Debug print
        // context.go(
        //   '${AppRoutes.paymentResult}?success=false&orderId=$orderId&amount=$total',
        // );
      }
    }

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
                              !isAddAddressRoute &&
                              !isViewDetailsRoute) ...[
                            const SizedBox(height: 27),
                            const Footer(),
                          ],
                        ],
                      ),
                    ),

                    if (!isLoginRoute &&
                        !isSignInRoute &&
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
                        !isAddAddressRoute &&
                        !isViewDetailsRoute)
                      Positioned(
                        left: 300,
                        bottom: 60,
                        right: 10,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/chat_bot/chat.svg",
                              width: 36,
                              height: 36,
                            ),
                          ],
                        ),
                      ),

                    // Make Payment Container for Checkout Route
                    if (isCheckoutRoute)
                      Positioned(
                        bottom: 0, // Position at the bottom
                        left: 0,
                        right: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          color: Colors.white,

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
                                  fontWeight: FontWeight.w600,
                                  lineHeight: 1.0,
                                  letterSpacing: 1 * 0.04, // 4% of 32px
                                ),
                                SizedBox(height: 8),
                                BarlowText(
                                  text: "MAKE PAYMENT",
                                  color: Color(0xFF30578E),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  backgroundColor: Color(0xFFB9D6FF),
                                  lineHeight: 1.0,
                                  letterSpacing: 1 * 0.04, // 4% of 32px
                                  onTap: openRazorpayCheckout,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ValueListenableBuilder<String?>(
                      valueListenable: _notificationMessage,
                      builder: (context, message, _) {
                        return message != null
                            ? Positioned(
                              top: 30,
                              right: 5,
                              child: NotificationBanner(
                                textColor: Colors.black,
                                message: message,
                                iconPath: "assets/icons/i_icons.svg",
                                bannerColor: const Color(0xFF2876E4),
                                onClose: () {
                                  _notificationMessage.value = null;
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
