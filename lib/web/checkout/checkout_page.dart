import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/web_desktop_common/add_address_ui/select_address.dart';
import 'package:kireimics/web_desktop_common/cart/cart_panel.dart';
import 'package:kireimics/web_desktop_common/component/rotating_svg_loader.dart';
import 'package:kireimics/web_desktop_common/login_signup/login/login_page.dart';
import '../../component/title_service.dart';
import '../../component/utilities/delivery_charge.dart';
import 'checkout_controller.dart';
import 'dart:js' as js;

class CheckoutPage extends StatefulWidget {
  final Function(String)? onWishlistChanged;
  final Function(String)? onErrorWishlistChanged;
  final Function(bool)? onPaymentProcessing;

  const CheckoutPage({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
    this.onPaymentProcessing,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CheckoutController checkoutController = Get.put(CheckoutController());

  @override
  void initState() {
    super.initState();
    TitleService.setTitle("Kireimics | Checkout");

    checkoutController.initializeRouter(context);
    checkoutController.showLoginBox.value = true;
    // print('Initial showLoginBox: ${checkoutController.showLoginBox.value}');

    checkoutController.checkLoginStatus().then((_) {
      // print(
      //   'After check: isLoggedIn: ${checkoutController.isLoggedIn.value}, '
      //   'showLoginBox: ${checkoutController.showLoginBox.value}',
      // );
      setState(() {});
    });

    checkoutController.loadUserData();
    checkoutController.loadAddressData().then((_) {
      if (checkoutController.zipController.text.length == 6) {
        checkoutController.getShippingTax();
      }
    });
    checkoutController.updateFromRoute(context);
    checkoutController.setCallbacks(
      onWishlistChanged: widget.onWishlistChanged,
      onErrorWishlistChanged: widget.onErrorWishlistChanged,
      onPaymentProcessing: widget.onPaymentProcessing,
    );
  }

  @override
  void dispose() {
    checkoutController.disposeRouter();
    checkoutController.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1400;
    final effectiveWidth =
        isDesktop
            ? screenWidth.clamp(1400.0, double.infinity)
            : screenWidth.clamp(800.0, 1400.0);
    final contentWidth =
        isDesktop ? (effectiveWidth - 389 - 200) : (effectiveWidth - 289 - 140);
    final fontScale = (contentWidth / (isDesktop ? 800 : 600)).clamp(
      isDesktop ? 1.0 : 0.8,
      isDesktop ? 1.5 : 1.0,
    );
    final isVerticalLayout = screenWidth < 1000;

    return SizedBox(
      width: screenWidth,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: isDesktop ? 389 : 289,
            right: isDesktop ? 200 : 140,
            top: 24,
            bottom: 24,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BarlowText(
                    text: "My Cart",
                    color: const Color(0xFF30578E),
                    hoverTextColor: const Color(0xFF2876E4),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                    letterSpacing: 0.04 * fontScale,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (BuildContext context) => CartPanel(),
                      );
                    },
                  ),
                  const SizedBox(width: 9),
                  SvgPicture.asset(
                    'assets/icons/right_icon.svg',
                    width: 24 * (isDesktop ? 1.0 : contentWidth / 600),
                    height: 24 * (isDesktop ? 1.0 : contentWidth / 600),
                    color: const Color(0xFF30578E),
                  ),
                  const SizedBox(width: 9),
                  BarlowText(
                    text: "Checkout",
                    color: const Color(0xFF30578E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.0,
                    hoverTextColor: const Color(0xFF2876E4),
                    route: AppRoutes.checkOut,
                    enableUnderlineForActiveRoute: true,
                    decorationColor: const Color(0xFF30578E),
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 32 * fontScale),
              isVerticalLayout
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLeftColumn(context, contentWidth, fontScale),
                      SizedBox(height: 32 * fontScale),
                      buildRightColumn(context, contentWidth, fontScale),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildLeftColumn(
                          context,
                          contentWidth,
                          fontScale,
                        ),
                      ),
                      SizedBox(width: 32 * fontScale),
                      Expanded(
                        child: buildRightColumn(
                          context,
                          contentWidth,
                          fontScale,
                        ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = (contentWidth * 0.45).clamp(
      screenWidth >= 1400 ? 444.0 : 200.0,
      screenWidth >= 1400 ? 600.0 : 444.0,
    );

    return Obx(() {
      final isLoggedIn = checkoutController.isLoggedIn.value;
      final addressExists = checkoutController.addressExists.value;
      final isLoading = checkoutController.isLoading.value;
      // print(
      //   'buildLeftColumn: isLoggedIn: $isLoggedIn, '
      //   'showLoginBox: ${checkoutController.showLoginBox.value}, '
      //   'addressExists: $addressExists, isLoading: $isLoading',
      // );

      if (isLoading) {
        return Center(
          child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CralikaFont(
            text: "Checkout",
            fontWeight: FontWeight.w600,
            fontSize: 32,
            lineHeight: 36 / 32,
            letterSpacing: 1.28 * fontScale,
            color: const Color(0xFF414141),
          ),
          const SizedBox(height: 24),
          if (isLoggedIn && addressExists) SelectAddress(),
          if (!isLoggedIn && checkoutController.showLoginBox.value) ...[
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
                                    (BuildContext context) => const LoginPage(),
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
                              hoverDecorationColor: const Color(0xFF2876E4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          checkoutController.showLoginBox.value = false;
                        });
                      },
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
          if (!isLoggedIn || (isLoggedIn && !addressExists))
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
                                checkoutController.getShippingTax();
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
                    if (!isLoggedIn || !addressExists)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                checkoutController.isPrivacyPolicyChecked =
                                    !checkoutController.isPrivacyPolicyChecked;
                              });
                            },
                            child: SvgPicture.asset(
                              checkoutController.isPrivacyPolicyChecked
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
                                style: const TextStyle(
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF414141),
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
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget buildRightColumn(
    BuildContext context,
    double contentWidth,
    double fontScale,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = (contentWidth * 0.45).clamp(
      screenWidth >= 1400 ? 488.0 : 220.0,
      screenWidth >= 1400 ? 650.0 : 488.0,
    );

    return Obx(() {
      final double finalDeliveryCharge =
          checkoutController.subtotal.value > AppConstants.deliveryCharge
              ? 0.0
              : checkoutController.totalDeliveryCharge.value;
      final double total =
          checkoutController.subtotal.value + finalDeliveryCharge;

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
                  SizedBox(height: 12 * fontScale),
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
                        text:
                            "Rs. ${checkoutController.subtotal.value.toStringAsFixed(2)}",
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
                      checkoutController.isShippingTaxLoaded.value
                          ? BarlowText(
                            text:
                                "Rs. ${(checkoutController.subtotal.value > AppConstants.deliveryCharge ? 0.0 : checkoutController.totalDeliveryCharge.value).toStringAsFixed(2)}",
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            lineHeight: 36 / 16,
                            letterSpacing: 0.64 * fontScale,
                          )
                          : SizedBox(
                            width: 16 * fontScale,
                            height: 16 * fontScale,
                            child: RotatingSvgLoader(
                              assetPath: 'assets/footer/footerbg.svg',
                            ),
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
                        text:
                            "Rs. ${(checkoutController.subtotal.value + (checkoutController.subtotal.value > AppConstants.deliveryCharge ? 0.0 : checkoutController.totalDeliveryCharge.value)).toStringAsFixed(2)}",
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
                    builder: (BuildContext context) => CartPanel(),
                  );
                },
                child: BarlowText(
                  text: "VIEW CART",
                  color: const Color(0xFF30578E),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  lineHeight: 1.0,
                  letterSpacing: 0.64 * fontScale,
                  hoverBackgroundColor: const Color(0xFFb9d6ff),
                  enableHoverBackground: true,
                  decorationColor: const Color(0xFF30578E),
                  hoverTextColor: const Color(0xFF2876E4),
                  hoverDecorationColor: const Color(0xFF2876E4),
                ),
              ),
              SizedBox(height: 24 * fontScale),
              Obx(() {
                final isLoading =
                    !checkoutController.isShippingTaxLoaded.value ||
                    checkoutController.isSignupProcessing.value;
                return isLoading
                    ? SizedBox(
                      width: 16 * fontScale,
                      height: 16 * fontScale,
                      child: RotatingSvgLoader(
                        assetPath: 'assets/footer/footerbg.svg',
                      ),
                    )
                    : BarlowText(
                      text: "MAKE PAYMENT",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      lineHeight: 1.0,
                      letterSpacing: 0.64 * fontScale,
                      color:
                          isAnyRequiredFieldEmpty()
                              ? const Color(0xFF30578E).withOpacity(0.5)
                              : const Color(0xFF30578E),
                      backgroundColor:
                          isAnyRequiredFieldEmpty()
                              ? const Color(0xFFb9d6ff).withOpacity(0.5)
                              : const Color(0xFFb9d6ff),
                      hoverTextColor:
                          isAnyRequiredFieldEmpty()
                              ? const Color(0xFF2876E4).withOpacity(0.5)
                              : const Color(0xFF2876E4),
                      onTap: () async {
                        bool isLoggedIn =
                            await checkoutController.isUserLoggedIn();

                        if (checkoutController
                            .firstNameController
                            .text
                            .isEmpty) {
                          widget.onErrorWishlistChanged?.call(
                            'Please enter your first name',
                          );
                          return;
                        }
                        if (checkoutController.firstNameController.text.length <
                            2) {
                          widget.onErrorWishlistChanged?.call(
                            'First name too short',
                          );
                          return;
                        }
                        if (checkoutController
                            .lastNameController
                            .text
                            .isEmpty) {
                          widget.onErrorWishlistChanged?.call(
                            'Please enter your last name',
                          );
                          return;
                        }
                        if (checkoutController.lastNameController.text.length <
                            2) {
                          widget.onErrorWishlistChanged?.call(
                            'Last name too short',
                          );
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
                        if (checkoutController
                            .address1Controller
                            .text
                            .isEmpty) {
                          widget.onErrorWishlistChanged?.call(
                            'Please enter your ADDRESS LINE 1',
                          );
                          return;
                        }
                        if (checkoutController.zipController.text.isEmpty) {
                          widget.onErrorWishlistChanged?.call(
                            'Please enter your Zip',
                          );
                          return;
                        }
                        if (checkoutController.stateController.text.isEmpty) {
                          widget.onErrorWishlistChanged?.call(
                            'Please enter your state',
                          );
                          return;
                        }
                        if (checkoutController.cityController.text.isEmpty) {
                          widget.onErrorWishlistChanged?.call(
                            'Please enter your city',
                          );
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

                        if ((!isLoggedIn ||
                                (isLoggedIn &&
                                    !checkoutController.addressExists.value)) &&
                            !checkoutController.isPrivacyPolicyChecked) {
                          widget.onErrorWishlistChanged?.call(
                            'Please accept the Privacy Policy',
                          );
                          return;
                        }

                        if (!isLoggedIn) {
                          bool signUpSuccess = await checkoutController
                              .handleSignUp(context);
                          if (!signUpSuccess) {
                            widget.onErrorWishlistChanged?.call(
                              checkoutController.signupMessage.isNotEmpty
                                  ? checkoutController.signupMessage
                                  : 'Signup failed, please try again',
                            );
                            return;
                          }
                        } else if (!checkoutController.addressExists.value) {
                          bool addressSuccess = await checkoutController
                              .handleAddAddress(context);
                          if (!addressSuccess) {
                            widget.onErrorWishlistChanged?.call(
                              checkoutController.signupMessage.isNotEmpty
                                  ? checkoutController.signupMessage
                                  : 'Failed to add address, please try again',
                            );
                            return;
                          }
                        }

                        final orderId =
                            'ORDER_${DateTime.now().millisecondsSinceEpoch}';
                        checkoutController.openRazorpayCheckout(
                          context,
                          total,
                          orderId,
                        );
                      },
                    );
              }),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/icons/razorpay1.png',
                    width: 76,
                    height: 16,
                    color: const Color(0xFF30578E),
                  ),
                  SizedBox(width: 4),
                  BarlowText(
                    text: "Secure (UPI, Cards, Wallets, NetBanking)",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }

  bool isAnyRequiredFieldEmpty() {
    return checkoutController.firstNameController.text.isEmpty ||
        checkoutController.lastNameController.text.isEmpty ||
        checkoutController.emailController.text.isEmpty ||
        checkoutController.address1Controller.text.isEmpty ||
        checkoutController.zipController.text.isEmpty ||
        checkoutController.stateController.text.isEmpty ||
        checkoutController.cityController.text.isEmpty ||
        checkoutController.mobileController.text.isEmpty ||
        ((!checkoutController.isLoggedIn.value ||
                (checkoutController.isLoggedIn.value &&
                    !checkoutController.addressExists.value)) &&
            !checkoutController.isPrivacyPolicyChecked);
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
