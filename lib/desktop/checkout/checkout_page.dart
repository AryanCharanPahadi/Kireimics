import 'dart:convert' show jsonDecode, jsonEncode;

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
import '../../web/checkout/checkout_controller.dart';
import '../../web_desktop_common/add_address_ui/add_address_ui.dart';
import '../../web_desktop_common/add_address_ui/select_address.dart';
import '../../web_desktop_common/cart/cart_panel.dart';
import '../../web_desktop_common/login_signup/login/login_page.dart';
import 'dart:js' as js;
import 'package:kireimics/utils/razorpay_js.dart';

class CheckoutPageDesktop extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final Function(String)? onErrorWishlistChanged; // Callback to notify parent
  const CheckoutPageDesktop({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });
  @override
  State<CheckoutPageDesktop> createState() => _CheckoutPageDesktopState();
}

class _CheckoutPageDesktopState extends State<CheckoutPageDesktop> {
  bool showLoginBox = true;
  late double subtotal;
  final double deliveryCharge = 50.0;
  late double total;
  Future<bool> isUserLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  final CheckoutController checkoutController = Get.put(CheckoutController());
  @override
  void initState() {
    super.initState();
    checkoutController.loadUserData();
    checkoutController.loadAddressData();
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());
    subtotal = double.tryParse(uri.queryParameters['subtotal'] ?? '') ?? 0.0;
    total = subtotal + deliveryCharge;

    checkoutController.loadProductIds(context);

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Ensure minimum width of 1400px for screens above 1400px
    final effectiveWidth = screenWidth.clamp(1400.0, double.infinity);
    // Calculate available content width after fixed padding
    final contentWidth = effectiveWidth - 389 - 200;
    // Font scaling based on content width
    final fontScale = (contentWidth / 800).clamp(1.0, 1.5);

    return SizedBox(
      width: screenWidth,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 389,
            right: 200,
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
                    color: const Color(0xFF30578E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                    letterSpacing: 0.04 * fontScale,
                  ),
                  SizedBox(width: 9),
                  SvgPicture.asset(
                    'assets/icons/right_icon.svg',
                    width: 24,
                    height: 24,
                    color: const Color(0xFF30578E),
                  ),
                  SizedBox(width: 9),
                  BarlowText(
                    text: "View Details",
                    color: const Color(0xFF30578E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                    route: AppRoutes.checkOut,
                    enableUnderlineForActiveRoute: true,
                    decorationColor: const Color(0xFF30578E),
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 32 * fontScale),
              // Main Content
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildLeftColumn(context, contentWidth, fontScale),
                  ),
                  SizedBox(width: 32 * fontScale),
                  Expanded(
                    child: buildRightColumn(context, contentWidth, fontScale),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLeftColumn(
    BuildContext context,
    double contentWidth,
    double fontScale,
  ) {
    final containerWidth = (contentWidth * 0.45).clamp(444.0, 600.0);

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
              fontSize: 32,
              lineHeight: 36 / 32,
              letterSpacing: 1.28 * fontScale,
              color: const Color(0xFF414141),
            ),
            SizedBox(height: 24 * fontScale),
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
                height: (83 * fontScale).clamp(83, 100),
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
                              fontSize: 20,
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
                                fontSize: 16,
                                lineHeight: 1.5,
                                color: const Color(0xFF30578E),
                                hoverBackgroundColor: const Color(0xFFb9d6ff),
                                enableHoverBackground: true,
                                decorationColor: const Color(0xFF30578E),
                                hoverTextColor: const Color(0xFF2876E4),
                                hoverDecorationColor: Color(0xFF2876E4),
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
              child: Form(
                key: checkoutController.formKey,
                child: Column(
                  children: [
                    customTextFormField(
                      hintText: "FIRST NAME",
                      fontScale: fontScale,
                      controller: checkoutController.firstNameController,
                      isRequired: true,
                    ),
                    SizedBox(height: 32),

                    customTextFormField(
                      hintText: "LAST NAME",
                      fontScale: fontScale,
                      controller: checkoutController.lastNameController,
                      isRequired: true,
                    ),
                    SizedBox(height: 32),

                    customTextFormField(
                      hintText: "EMAIL",
                      fontScale: fontScale,
                      controller: checkoutController.emailController,
                      isRequired: true,
                    ),
                    SizedBox(height: 32),

                    customTextFormField(
                      hintText: "ADDRESS LINE 1",
                      fontScale: fontScale,
                      controller: checkoutController.address1Controller,
                      isRequired: true,
                    ),
                    SizedBox(height: 32),

                    customTextFormField(
                      hintText: "ADDRESS LINE 2",
                      fontScale: fontScale,
                      controller: checkoutController.address2Controller,
                    ),
                    SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: customTextFormField(
                            hintText: "ZIP",
                            fontScale: fontScale,
                            controller: checkoutController.zipController,
                            isRequired: true,
                            onChanged: (value) {
                              if (value.length == 6) {
                                checkoutController.fetchPincodeData(value);
                              } else {
                                checkoutController.stateController.text = '';
                                checkoutController.cityController.text = '';
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 32 * fontScale),
                        Expanded(
                          child: Obx(
                            () => customTextFormField(
                              hintText:
                                  checkoutController.isPincodeLoading.value
                                      ? "Loading..."
                                      : "STATE",
                              enabled:
                                  !checkoutController.isPincodeLoading.value,
                              fontScale: fontScale,
                              controller: checkoutController.stateController,
                              isRequired: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => customTextFormField(
                              hintText:
                                  checkoutController.isPincodeLoading.value
                                      ? "Loading..."
                                      : "CITY",
                              enabled:
                                  !checkoutController.isPincodeLoading.value,
                              fontScale: fontScale,
                              controller: checkoutController.cityController,
                              isRequired: true,
                            ),
                          ),
                        ),
                        SizedBox(width: 32 * fontScale),
                        Expanded(
                          child: customTextFormField(
                            hintText: "PHONE",
                            fontScale: fontScale,
                            controller: checkoutController.mobileController,
                            isRequired: true,
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
                                checkoutController.isChecked =
                                    !checkoutController.isChecked;
                              });
                            },
                            child: SvgPicture.asset(
                              checkoutController.isChecked
                                  ? "assets/icons/filledCheckbox.svg"
                                  : "assets/icons/emptyCheckbox.svg",
                              height: 24,
                              width: 24,
                            ),
                          ),
                          SizedBox(width: 19),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
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
                                      color: Color(0xFF30578E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                                      color: Color(0xFF30578E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BarlowText(
                            text:
                                checkoutController.addressExists.value
                                    ? 'UPDATE ADDRESS'
                                    : 'ADD ADDRESS',
                            color: const Color(0xFF30578E),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            lineHeight: 1.0,
                            letterSpacing: 0.64,
                            decorationColor: const Color(0xFF30578E),
                            hoverBackgroundColor: Color(0xFFb9d6ff),
                            enableHoverBackground: true,
                            hoverTextColor: const Color(0xFF2876E4),
                            hoverDecorationColor: Color(0xFF2876E4),
                            onTap: () {
                              if (checkoutController.addressExists.value) {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return SelectAddress();
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return AddAddressUi();
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildRightColumn(
    BuildContext context,
    double contentWidth,
    double fontScale,
  ) {
    final containerWidth = (contentWidth * 0.45).clamp(488.0, 650.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          color: const Color(0xFF30578E),
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
                  fontSize: 20,
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
                      fontSize: 16,
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                    BarlowText(
                      text: "Rs. ${subtotal.toStringAsFixed(2)}",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
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
                      fontSize: 16,
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                    BarlowText(
                      text: "Rs. ${deliveryCharge.toStringAsFixed(2)}",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
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
                      fontSize: 20,
                      lineHeight: 36 / 16,
                      letterSpacing: 0.64 * fontScale,
                    ),
                    BarlowText(
                      text: "Rs. ${total.toStringAsFixed(2)}",
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
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
                color: Color(0xFF30578E),

                fontSize: 16,
                lineHeight: 1.0,
                letterSpacing: 0.64 * fontScale,
                hoverBackgroundColor: const Color(0xFFb9d6ff),
                enableHoverBackground: true,
                decorationColor: const Color(0xFF30578E),
                hoverTextColor: const Color(0xFF2876E4),
                hoverDecorationColor: Color(0xFF2876E4),
              ),
            ),
            SizedBox(height: 24 * fontScale),
            BarlowText(
              text: "MAKE PAYMENT",
              color: const Color(0xFF30578E),
              fontWeight: FontWeight.w600,
              fontSize: 16,
              lineHeight: 1.0,
              letterSpacing: 0.64 * fontScale,
              backgroundColor: Color(0xFFb9d6ff),
              hoverTextColor: Color(0xFF2876E4),
              onTap: () async {
                // Sequential validation of required fields
                if (checkoutController.firstNameController.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter your first name',
                  );
                  return;
                }
                if (checkoutController.firstNameController.text.length < 2) {
                  widget.onErrorWishlistChanged?.call('First name too short');
                  return;
                }
                if (checkoutController.lastNameController.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter your last name',
                  );
                  return;
                }
                if (checkoutController.lastNameController.text.length < 2) {
                  widget.onErrorWishlistChanged?.call('Last name too short');
                  return;
                }
                if (checkoutController.emailController.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter your email',
                  );
                  return;
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(checkoutController.emailController.text)) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter a valid email',
                  );
                  return;
                }
                if (checkoutController.address1Controller.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter your ADDRESS LINE 1',
                  );
                  return;
                }
                if (checkoutController.zipController.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call('Please enter your Zip');
                  return;
                }
                if (checkoutController.stateController.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter your state',
                  );
                  return;
                }
                if (checkoutController.cityController.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call('Please enter your city');
                  return;
                }
                if (checkoutController.mobileController.text.isEmpty) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter your phone number',
                  );
                  return;
                }
                if (!RegExp(
                  r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$',
                ).hasMatch(checkoutController.mobileController.text)) {
                  widget.onErrorWishlistChanged?.call(
                    'Please enter a valid phone number',
                  );
                  return;
                }
                if (!checkoutController.isChecked &&
                    !checkoutController.addressExists.value) {
                  widget.onErrorWishlistChanged?.call(
                    'Please agree to the Privacy and Shipping Policy',
                  );
                  return;
                }

                // Check if user is logged in
                bool isLoggedIn = await isUserLoggedIn();
                if (!isLoggedIn) {
                  // Call handleSignUp for non-logged-in users
                  bool signUpSuccess = await checkoutController.handleSignUp(
                    context,
                  );
                  if (!signUpSuccess) {
                    widget.onErrorWishlistChanged?.call(
                      checkoutController.signupMessage.isNotEmpty
                          ? checkoutController.signupMessage
                          : 'Signup failed, please try again',
                    );
                    return;
                  }
                }

                // Proceed to payment if all validations pass and signup is successful (or user is logged in)
                final orderId =
                    'ORDER_${DateTime.now().millisecondsSinceEpoch}';
                checkoutController.openRazorpayCheckout(
                  context,
                  total,
                  orderId,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    bool enabled = true,
    Function(String)? onChanged,
    required double fontScale,
    bool isRequired = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8 * fontScale),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hint text with optional red asterisk
          Positioned(
            left: 0,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: hintText,
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: const Color(0xFF414141),
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Text field with right-aligned input
          TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            cursorColor: const Color(0xFF414141),
            enabled: enabled,
            onChanged: onChanged,
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
              contentPadding: EdgeInsets.symmetric(
                vertical: 8 * fontScale,
                horizontal: 8 * fontScale,
              ),
            ),
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
