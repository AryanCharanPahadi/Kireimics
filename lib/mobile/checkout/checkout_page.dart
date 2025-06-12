import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';
import 'package:kireimics/mobile/login/login.dart';

import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../web/checkout/checkout_controller.dart';
import '../../web_desktop_common/add_address_ui/add_address_ui.dart';
import '../../web_desktop_common/add_address_ui/select_address.dart'
    show SelectAddress;
import '../address_page/add_address_ui/select_address_mobile.dart';

class CheckoutPageMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final Function(String)? onErrorWishlistChanged; // Callback to notify parent
  const CheckoutPageMobile({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });
  @override
  State<CheckoutPageMobile> createState() => _CheckoutPageMobileState();
}

class _CheckoutPageMobileState extends State<CheckoutPageMobile> {
  bool hasAddress = false;
  bool showLoginBox = true;
  bool isChecked = false;
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
    checkoutController.setCallbacks(
      onWishlistChanged: widget.onWishlistChanged,
      onErrorWishlistChanged: widget.onErrorWishlistChanged,
    );
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
    return Stack(
      children: [
        FutureBuilder<bool>(
          future: isUserLoggedIn(),
          builder: (context, snapshot) {
            final isLoggedIn = snapshot.data ?? false;

            return Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            BarlowText(
                              text: "My Cart",
                              color: Color(0xFF30578E),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.0,
                              letterSpacing: 1 * 0.04, // 4% of 32px
                            ),

                            SizedBox(width: 9.0),

                            SvgPicture.asset(
                              'assets/icons/right_icon.svg',
                              width: 20,
                              height: 20,
                              color: Color(0xFF30578E),
                            ),
                            SizedBox(width: 9.0),

                            BarlowText(
                              text: "View Details",
                              color: Color(0xFF30578E),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.0,
                              route: AppRoutes.checkOut,
                              enableUnderlineForActiveRoute:
                                  true, // Enable underline when active
                              decorationColor: Color(
                                0xFF30578E,
                              ), // Color of the underline
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            CralikaFont(
                              text: "Checkout",
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              lineHeight: 36 / 32,
                              letterSpacing: 1.28,
                              color: Color(0xFF414141),
                            ),

                            SizedBox(height: 10),

                            if (showLoginBox && !isLoggedIn) ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFDDEAFF).withOpacity(0.6),
                                      offset: Offset(20, 20),
                                      blurRadius: 20,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Color(0xFFDDEAFF),
                                    width: 1,
                                  ),
                                ),
                                // height: 83,
                                // width: 362,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    top: 13,
                                    bottom: 13,
                                    right: 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFDDEAFF),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/header/IconProfile.svg",
                                            height: 21,
                                            width: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 24),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          BarlowText(
                                            text: "Already have an account?",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            lineHeight: 1.0,
                                            color: Color(0xFF000000),
                                          ),
                                          SizedBox(height: 6),
                                          GestureDetector(
                                            onTap: () {
                                              context.go(AppRoutes.logIn);
                                            },
                                            child: BarlowText(
                                              text: "LOG IN NOW",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              lineHeight: 1.5,
                                              color: Color(0xFF30578E),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            showLoginBox =
                                                false; // Hide the box
                                          });
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Color(0xFFE5E5E5),
                                          child: SvgPicture.asset(
                                            "assets/icons/closeIcon.svg",
                                            color: Color(0xFF4F4F4F),
                                            height: 10,
                                            width: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 44),
                            ],
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Form(
                          key: checkoutController.formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customTextFormField(
                                hintText: "FIRST NAME",
                                controller:
                                    checkoutController.firstNameController,
                                isRequired: true,
                              ),
                              SizedBox(height: 32),
                              customTextFormField(
                                hintText: "LAST NAME",
                                controller:
                                    checkoutController.lastNameController,
                                isRequired: true,
                              ),
                              SizedBox(height: 32),

                              customTextFormField(
                                hintText: "EMAIL",
                                controller: checkoutController.emailController,
                                isRequired: true,
                              ),
                              SizedBox(height: 32),

                              customTextFormField(
                                hintText: "ADDRESS LINE 1",
                                controller:
                                    checkoutController.address1Controller,
                                isRequired: true,
                              ),
                              SizedBox(height: 32),

                              customTextFormField(
                                hintText: "ADDRESS LINE 2",
                                controller:
                                    checkoutController.address2Controller,
                              ),
                              SizedBox(height: 32),

                              Row(
                                children: [
                                  Expanded(
                                    child: customTextFormField(
                                      hintText: "ZIP",
                                      controller:
                                          checkoutController.zipController,
                                      isRequired: true,
                                      onChanged: (value) {
                                        if (value.length == 6) {
                                          checkoutController.fetchPincodeData(
                                            value,
                                          );
                                        } else {
                                          checkoutController
                                              .stateController
                                              .text = '';
                                          checkoutController
                                              .cityController
                                              .text = '';
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 32), // spacing between fields
                                  Expanded(
                                    child: Obx(
                                      () => customTextFormField(
                                        hintText:
                                            checkoutController
                                                    .isPincodeLoading
                                                    .value
                                                ? "Loading..."
                                                : "STATE",
                                        enabled:
                                            !checkoutController
                                                .isPincodeLoading
                                                .value,
                                        controller:
                                            checkoutController.stateController,
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
                                            checkoutController
                                                    .isPincodeLoading
                                                    .value
                                                ? "Loading..."
                                                : "CITY",
                                        enabled:
                                            !checkoutController
                                                .isPincodeLoading
                                                .value,
                                        controller:
                                            checkoutController.cityController,
                                        isRequired: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 32), // spacing between fields
                                  Expanded(
                                    child: customTextFormField(
                                      hintText: "PHONE",
                                      controller:
                                          checkoutController.mobileController,
                                      isRequired: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 32),

                              if (!isLoggedIn) ...[
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isChecked = !isChecked;
                                          checkoutController.isChecked =
                                              isChecked; // Sync with controller
                                        });
                                      },
                                      child: SvgPicture.asset(
                                        isChecked
                                            ? "assets/icons/filledCheckbox.svg"
                                            : "assets/icons/emptyCheckbox.svg",
                                        height: 24,
                                        width: 24,
                                      ),
                                    ),
                                    SizedBox(width: 13),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12.0,
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontFamily:
                                                  GoogleFonts.barlow()
                                                      .fontFamily,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              height: 1.5, // Line height: 150%
                                              letterSpacing: 0.0,
                                              color: Color(0xFF414141),
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    "By selecting this checkbox, you are agreeing to our ",
                                                style: TextStyle(
                                                  fontFamily:
                                                      GoogleFonts.barlow()
                                                          .fontFamily,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "Privacy Policy",
                                                style: TextStyle(
                                                  color: Color(0xFF30578E),
                                                  fontFamily:
                                                      GoogleFonts.barlow()
                                                          .fontFamily,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: " & "),
                                              TextSpan(
                                                text: "Shipping Policy",
                                                style: TextStyle(
                                                  color: Color(0xFF30578E),
                                                  fontFamily:
                                                      GoogleFonts.barlow()
                                                          .fontFamily,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: "."),
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
                                      text: 'UPDATE ADDRESS',
                                      color: const Color(0xFF30578E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      lineHeight: 1.0,
                                      letterSpacing: 0.64,
                                      backgroundColor: Color(0xFFB9D6FF),

                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return SelectAddressMobile();
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 42),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: Color(0xFF30578E),
                              // width: 346,

                              // height: 243,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 46,
                                  top: 18,
                                  right: 44,
                                  bottom: 32,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CralikaFont(
                                      text: "Order Details",
                                      color: Color(0xFFFFFFFF),

                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                      lineHeight:
                                          36 / 20, // line-height / font-size
                                      letterSpacing: 0.8, // 4% of 20px is 0.8
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BarlowText(
                                          text: "Item Total",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                        BarlowText(
                                          text:
                                              "Rs. ${subtotal.toStringAsFixed(2)}",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BarlowText(
                                          text: "Shipping & Taxes",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                        BarlowText(
                                          text:
                                              "Rs. ${deliveryCharge.toStringAsFixed(2)}",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    Divider(color: Color(0xFFFFFFFF)),
                                    SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CralikaFont(
                                          text: "Subtotal",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                        BarlowText(
                                          text:
                                              "Rs. ${total.toStringAsFixed(2)}",
                                          color: Color(0xFFFFFFFF),

                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          lineHeight:
                                              36 /
                                              16, // line-height / font-size = 2.25
                                          letterSpacing:
                                              0.64, // 4% of 16 = 0.64
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 32),

                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.go(AppRoutes.addToCart);
                                  },
                                  child: BarlowText(
                                    text: "VIEW CART",

                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    lineHeight: 1.0, // 100% line height
                                    letterSpacing:
                                        0.64, // 4% of 16px = 0.04 * 16 = 0.64
                                    backgroundColor: Color(0xFFb9d6ff),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    bool enabled = true,
    Function(String)? onChanged,
    bool isRequired = false,
  }) {
    return Stack(
      children: [
        // Hint text positioned on the left
        Positioned(
          left: 0,
          top: 20,
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
            border: UnderlineInputBorder(
              // Add this for the bottom border
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            enabledBorder: UnderlineInputBorder(
              // Add this for enabled state
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            focusedBorder: UnderlineInputBorder(
              // Add this for focused state
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            hintText: '', // Empty hint since we're showing our own
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: const Color(0xFF414141),
            ),
            contentPadding: const EdgeInsets.only(
              top: 15,
            ), // Match the Positioned top value
          ),
          style: const TextStyle(
            color: Color(0xFF414141),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
