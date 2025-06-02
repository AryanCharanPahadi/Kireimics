import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:http/http.dart' as http;
import 'package:kireimics/component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../web_desktop_common/add_address_ui/add_address_ui.dart';
import '../../web_desktop_common/cart/cart_panel.dart';
import '../../web_desktop_common/login_signup/login/login_page.dart';
import 'dart:js' as js;

import 'checkout_controller.dart';

class CheckoutPageWeb extends StatefulWidget {
  const CheckoutPageWeb({super.key});

  @override
  State<CheckoutPageWeb> createState() => _CheckoutPageWebState();
}

class _CheckoutPageWebState extends State<CheckoutPageWeb> {
  bool hasAddress = false;
  bool showLoginBox = true;
  bool isChecked = false;
  late double subtotal;
  final double deliveryCharge = 50.0;
  late double total;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  Future<bool> isUserLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  final CheckoutController checkoutController = Get.put(CheckoutController());
  @override
  void initState() {
    super.initState();
    _loadUserData();
    checkoutController.loadAddressData();
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    subtotal = double.tryParse(uri.queryParameters['subtotal'] ?? '') ?? 0.0;
    total = subtotal + deliveryCharge;

    // Extract and print product IDs
    final productIds = uri.queryParameters['productIds']?.split(',') ?? [];
    print('Product IDs: $productIds');
  }

  Future<void> _loadUserData() async {
    String? storedUser = await SharedPreferencesHelper.getUserData();

    if (storedUser != null) {
      List<String> userDetails = storedUser.split(', ');

      if (userDetails.length >= 4) {
        List<String> nameParts = userDetails[1].split(' ');
        String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        String lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        String phone = userDetails[2];
        String email = userDetails[3];

        if (mounted) {
          setState(() {
            firstNameController.text = firstName;
            lastNameController.text = lastName;
            emailController.text = email;
            mobileController.text = phone;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Restrict responsiveness to 800–1400px
    final effectiveWidth = screenWidth.clamp(800.0, 1400.0);
    // Calculate available content width after fixed padding, with minimum
    final contentWidth = (effectiveWidth - 289 - 140).clamp(
      300.0,
      double.infinity,
    );
    // Use vertical layout for widths below 1000px
    final isVerticalLayout = effectiveWidth < 1000;

    return SizedBox(
      width: screenWidth,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 289,
            right: 140,
            top: 24,
            bottom: 24,
          ),
          child: Column(
            children: [
              // Breadcrumb Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BarlowText(
                    text: "My Cart",
                    color: const Color(0xFF3E5B84),
                    fontSize: (16 * (contentWidth / 600)).clamp(12, 16),
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                    letterSpacing: 0.04 * (contentWidth / 600),
                  ),
                  const SizedBox(width: 9),
                  SvgPicture.asset(
                    'assets/icons/right_icon.svg',
                    width: 24 * (contentWidth / 600),
                    height: 24 * (contentWidth / 600),
                    color: const Color(0xFF3E5B84),
                  ),
                  const SizedBox(width: 9),
                  BarlowText(
                    text: "View Details",
                    color: const Color(0xFF3E5B84),
                    fontSize: (16 * (contentWidth / 600)).clamp(12, 16),
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                    route: AppRoutes.checkOut,
                    enableUnderlineForActiveRoute: true,
                    decorationColor: const Color(0xFF3E5B84),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Main Content
              isVerticalLayout
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLeftColumn(context, contentWidth),
                      const SizedBox(height: 32),
                      buildRightColumn(context, contentWidth),
                    ],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: buildLeftColumn(context, contentWidth)),
                      const SizedBox(width: 32),
                      Expanded(child: buildRightColumn(context, contentWidth)),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLeftColumn(BuildContext context, double contentWidth) {
    final containerWidth = (contentWidth * 0.45).clamp(200.0, 444.0);
    final fontScale = (contentWidth / 600).clamp(0.8, 1.0);

    return FutureBuilder<bool>(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CralikaFont(
              text: "Checkout",
              fontWeight: FontWeight.w400,
              fontSize: (32 * fontScale).clamp(24, 32),
              lineHeight: 36 / 32,
              letterSpacing: 1.28 * fontScale,
              color: const Color(0xFF414141),
            ),
            const SizedBox(height: 24),
            if (showLoginBox && !isLoggedIn) ...[
              Container(
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
                width: containerWidth,
                height: (83 * fontScale).clamp(60, 83),
                child: Padding(
                  padding: EdgeInsets.all(13 * fontScale),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56 * fontScale,
                        width: 56 * fontScale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEAFF),
                          borderRadius: BorderRadius.circular(8 * fontScale),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/header/IconProfile.svg",
                            height: 27 * fontScale,
                            width: 25 * fontScale,
                          ),
                        ),
                      ),
                      SizedBox(width: 24 * fontScale),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BarlowText(
                              text: "Already have an account?",
                              fontWeight: FontWeight.w400,
                              fontSize: (20 * fontScale).clamp(16, 20),
                              lineHeight: 1.0,
                              color: const Color(0xFF000000),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder:
                                      (BuildContext context) =>
                                          const LoginPage(),
                                );
                              },
                              child: BarlowText(
                                text: "LOG IN NOW",
                                fontWeight: FontWeight.w600,
                                fontSize: (14 * fontScale).clamp(12, 14),
                                lineHeight: 1.5,
                                color: const Color(0xFF3E5B84),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => showLoginBox = false),
                        child: CircleAvatar(
                          radius: 12 * fontScale,
                          backgroundColor: const Color(0xFFE5E5E5),
                          child: SvgPicture.asset(
                            "assets/icons/closeIcon.svg",
                            color: const Color(0xFF4F4F4F),
                            height: 10 * fontScale,
                            width: 10 * fontScale,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 43 * fontScale),
            ],
            SizedBox(
              width: containerWidth,
              child: Column(
                children: [
                  customTextFormField(
                    hintText: "FIRST NAME*",
                    fontScale: fontScale,
                    controller: firstNameController,
                  ),
                  customTextFormField(
                    hintText: "LAST NAME*",
                    fontScale: fontScale,
                    controller: lastNameController,
                  ),
                  customTextFormField(
                    hintText: "EMAIL*",
                    fontScale: fontScale,
                    controller: emailController,
                  ),
                  customTextFormField(
                    hintText: "ADDRESS LINE 1*",
                    fontScale: fontScale,
                    controller: checkoutController.address1Controller,
                  ),
                  customTextFormField(
                    hintText: "ADDRESS LINE 2",
                    fontScale: fontScale,
                    controller: checkoutController.address2Controller,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: customTextFormField(
                          hintText: "ZIP*",
                          fontScale: fontScale,
                          controller: checkoutController.zipController,
                        ),
                      ),
                      SizedBox(width: 32 * fontScale),
                      Expanded(
                        child: customTextFormField(
                          hintText: "STATE*",
                          fontScale: fontScale,
                          controller: checkoutController.stateController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: customTextFormField(
                          hintText: "CITY*",
                          fontScale: fontScale,
                          controller: checkoutController.cityController,
                        ),
                      ),
                      SizedBox(width: 32 * fontScale),
                      Expanded(
                        child: customTextFormField(
                          hintText: "PHONE*",
                          fontScale: fontScale,
                          controller: mobileController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (!isLoggedIn) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isChecked = !isChecked;
                            });
                          },
                          child: SvgPicture.asset(
                            isChecked
                                ? "assets/icons/filledCheckbox.svg"
                                : "assets/icons/emptyCheckbox.svg",
                            height: 23,
                            width: 23,
                          ),
                        ),
                        SizedBox(width: 19 * fontScale),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12 * fontScale),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.w400,
                                  fontSize: (14 * fontScale).clamp(12, 14),
                                  height: 1.5,
                                  color: const Color(0xFF414141),
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        "By selecting this checkbox, you are agreeing to our ",
                                  ),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: const TextStyle(
                                      color: Color(0xFF3E5B84),
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap =
                                              () => context.go(
                                                AppRoutes.privacyPolicy,
                                              ),
                                  ),
                                  const TextSpan(text: " & "),
                                  TextSpan(
                                    text: "Shipping Policy",
                                    style: const TextStyle(
                                      color: Color(0xFF3E5B84),
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap =
                                              () => context.go(
                                                AppRoutes.shippingPolicy,
                                              ),
                                  ),
                                  const TextSpan(text: "."),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BarlowText(
                          text:
                              checkoutController.addressExists == false
                                  ? 'UPDATE ADDRESS'
                                  : 'ADD ADDRESS',
                          color: const Color(0xFF30578E),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          lineHeight: 1.0,
                          letterSpacing: 0.64,
                          enableHoverUnderline: true,
                          decorationColor: const Color(0xFF3E5B84),
                          onTap: () {
                            if (!hasAddress) {
                              showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return AddAddressUi();
                                },
                              );
                            } else {
                              // Handle update address logic here
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildRightColumn(BuildContext context, double contentWidth) {
    final containerWidth = (contentWidth * 0.45).clamp(220.0, 488.0);
    final fontScale = (contentWidth / 600).clamp(0.8, 1.0);

    // ... other imports

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
        'amount': (total * 100).toInt(),
        'currency': 'INR',
        'name': 'Kireimics',
        'description': 'Payment for order',
        'prefill': {
          'name': firstNameController.text,
          'email': emailController.text,
          'contact': mobileController.text,
        },
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
          final amount = total; // From the outer scope
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
            '${AppRoutes.paymentResult}?success=true&orderId=$orderId&amount=$total',
          );
        }),
        'modal': {
          'ondismiss': js.allowInterop(() {
            print('Payment modal dismissed'); // Debug print
            context.go(
              '${AppRoutes.paymentResult}?success=false&orderId=$orderId&amount=$total',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          color: const Color(0xFF3E5B84),
          width: containerWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 44 * fontScale,
              vertical: 18 * fontScale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CralikaFont(
                  text: "Order Details",
                  color: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w400,
                  fontSize: (20 * fontScale).clamp(16, 20),
                  lineHeight: 36 / 20,
                  letterSpacing: 0.8 * fontScale,
                ),
                SizedBox(height: 15 * fontScale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BarlowText(
                      text: "Item Total",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: (16 * fontScale).clamp(12, 16),
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                    BarlowText(
                      text: "Rs. ${subtotal.toStringAsFixed(2)}",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: (16 * fontScale).clamp(12, 16),
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                  ],
                ),
                SizedBox(height: 12 * fontScale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BarlowText(
                      text: "Shipping & Taxes",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: (16 * fontScale).clamp(12, 16),
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                    BarlowText(
                      text: "Rs. ${deliveryCharge.toStringAsFixed(2)}",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: (16 * fontScale).clamp(12, 16),
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                  ],
                ),
                SizedBox(height: 12 * fontScale),
                const Divider(color: Color(0xFFFFFFFF)),
                SizedBox(height: 12 * fontScale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CralikaFont(
                      text: "Subtotal",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: (16 * fontScale).clamp(12, 16),
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                    BarlowText(
                      text: "Rs. ${total.toStringAsFixed(2)}",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: (16 * fontScale).clamp(12, 16),
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32 * fontScale),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return CartPanel();
                  },
                );
              },
              child: BarlowText(
                text: "VIEW CART",
                fontWeight: FontWeight.w600,
                fontSize: (16 * fontScale).clamp(12, 16),
                lineHeight: 1.0,
                letterSpacing: 0.64 * fontScale,
              ),
            ),
            SizedBox(height: 24 * fontScale),
            BarlowText(
              text: "MAKE PAYMENT",
              color: const Color(0xFF3E5B84),
              fontWeight: FontWeight.w600,
              fontSize: (16 * fontScale).clamp(12, 16),
              lineHeight: 1.0,
              letterSpacing: 0.64 * fontScale,
              backgroundColor: Color(0xFFb9d6ff),
              onTap: openRazorpayCheckout,
            ),
          ],
        ),
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    required double fontScale,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8 * fontScale),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hint text positioned on the left
          Positioned(
            left: 0,
            child: Text(
              hintText,
              style: GoogleFonts.barlow(
                fontWeight: FontWeight.w400,
                fontSize: (14 * fontScale).clamp(14, 18),
                color: const Color(0xFF414141),
              ),
            ),
          ),
          // Text field with right-aligned input
          TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            cursorColor: const Color(0xFF414141),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF414141)),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF414141)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF414141)),
              ),
              hintText: '',
              hintStyle: GoogleFonts.barlow(
                fontWeight: FontWeight.w400,
                fontSize: (14 * fontScale).clamp(14, 18),
                height: 1.0,
                color: const Color(0xFF414141),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 8 * fontScale,
                horizontal: 8 * fontScale,
              ),
            ),
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: (14 * fontScale).clamp(14, 18),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
