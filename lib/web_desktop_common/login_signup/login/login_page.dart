import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/web_desktop_common/login_signup/forget_password/forget_password.dart';

import '../../../component/google_sign_in/google_sign_in_button.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/utilities/utility.dart';
import '../../../web/checkout/checkout_controller.dart';
import '../../../web/checkout/checkout_controller_new.dart';
import '../signup/signup.dart' show Signup;
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = false;
  final loginController = Get.put(LoginController());
  bool showSuccessBanner = false;
  bool showErrorBanner = false;
  String errorMessage = "";
  void dispose() {
    // Clear all text controllers to prevent memory leaks
    loginController.emailController.clear();
    loginController.passwordController.clear();
    super.dispose();
  }

  final CheckoutController checkoutControllerNew = Get.put(
    CheckoutController(),
  );

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 1900;

    return Stack(
      children: [
        BlurredBackdrop(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isWideScreen ? 550 : 504,
            child: Material(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                    top: 22,
                    right: 44,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: BarlowText(
                              text: "Close",
                              color: Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              enableUnderlineForActiveRoute: true,
                              decorationColor: Color(0xFF30578E),
                              hoverTextColor: const Color(0xFF2876E4),
                            ),
                          ),
                          if (showSuccessBanner || showErrorBanner)
                            NotificationBanner(
                              iconPath:
                                  showSuccessBanner
                                      ? "assets/icons/success.svg"
                                      : "assets/icons/error.svg",
                              message:
                                  showSuccessBanner
                                      ? "Logged in successfully!"
                                      : errorMessage,
                              bannerColor:
                                  showSuccessBanner
                                      ? Color(0xFF268FA2)
                                      : Color(0xFFF46856),
                              textColor: Color(0xFF28292A),
                              onClose: () {
                                setState(() {
                                  showSuccessBanner = false;
                                  showErrorBanner = false;
                                });
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 33),
                      CralikaFont(
                        text: "Log In",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                        fontSize: 32.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      SizedBox(height: 8),
                      BarlowText(
                        text:
                            "Log in to your Kireimics account for a quick checkout.",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        lineHeight: 1.0,
                        letterSpacing: 0.0,
                      ),
                      SizedBox(height: 32),
                      Form(
                        key: loginController.formKey,
                        child: Column(
                          children: [
                            customTextFormField(
                              hintText: "EMAIL",
                              controller: loginController.emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 32),
                            customTextFormField(
                              hintText: "PASSWORD",
                              controller: loginController.passwordController,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 9) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
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
                                            height: 24,
                                            width: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        BarlowText(
                                          text: "Remember Me",
                                          color: Color(0xFF414141),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          lineHeight: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    BarlowText(
                                      text: "Forgot Password?",
                                      color: Color(0xFF30578E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      lineHeight: 1.0,
                                      letterSpacing: 0.64,
                                      enableUnderlineForActiveRoute: true,
                                      decorationColor: Color(0xFF30578E),
                                      hoverTextColor: const Color(0xFF2876E4),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return ForgetPassword();
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        bool success = await loginController
                                            .handleLogin(context);
                                        if (mounted) {
                                          setState(() {
                                            if (success) {
                                              showSuccessBanner = true;
                                              showErrorBanner = false;
                                              widget.onLoginSuccess?.call();
                                              checkoutControllerNew
                                                  .loadUserData();
                                            } else {
                                              showSuccessBanner = false;
                                              showErrorBanner = true;
                                              errorMessage =
                                                  loginController.loginMessage;
                                            }
                                          });

                                          if (success) {
                                            // Hide success banner after 3 seconds
                                            Future.delayed(
                                              const Duration(seconds: 3),
                                              () {
                                                if (mounted) {
                                                  setState(() {
                                                    showSuccessBanner = false;
                                                  });
                                                }
                                              },
                                            );

                                            // Pop dialog after 2 seconds
                                            Future.delayed(
                                              const Duration(seconds: 2),
                                              () {
                                                if (mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            );
                                          }
                                        }
                                      },
                                      child: BarlowText(
                                        text: "LOG IN",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        lineHeight: 1.0,
                                        letterSpacing: 0.64,
                                        color: Color(0xFF30578E),
                                        backgroundColor: Color(0xFFb9d6ff),
                                        decorationColor: const Color(
                                          0xFF30578E,
                                        ),
                                        hoverTextColor: const Color(0xFF2876E4),
                                        hoverDecorationColor: Color(0xFF2876E4),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    BarlowText(
                                      text: "Or",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      lineHeight: 1.0,
                                      letterSpacing: 0.0,
                                      color: Color(0xFF414141),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        SizedBox(width: 24),
                                        GoogleSignInButton(
                                          functionName: 'signInWithGoogle',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Conditionally position the signup container
                      if (!isWideScreen) ...[
                        SizedBox(height: 40),
                        buildSignUpContainer(context),
                        SizedBox(height: 44),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Positioned signup container for wide screens
        if (isWideScreen)
          Positioned(
            bottom: 20,
            right: 44,
            child: Container(
              width: 504,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: buildSignUpContainer(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildSignUpContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFDDEAFF).withOpacity(0.6),
            offset: Offset(20, 20),
            blurRadius: 20,
          ),
        ],
        border: Border.all(color: Color(0xFFDDEAFF), width: 1),
      ),
      height: 83,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          top: 13,
          bottom: 13,
          right: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Color(0xFFDDEAFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/header/IconProfile.svg",
                  height: 27,
                  width: 25,
                ),
              ),
            ),
            SizedBox(width: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BarlowText(
                  text: "Don't have an account?",
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  lineHeight: 1.0,
                  color: Color(0xFF000000),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(Duration.zero, () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Signup();
                        },
                      );
                    });
                  },
                  child: BarlowText(
                    text: "SIGN UP NOW",
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    lineHeight: 1.5,
                    color: Color(0xFF30578E),
                    hoverBackgroundColor: Color(0xFFb9d6ff),
                    enableHoverBackground: true,
                    decorationColor: const Color(0xFF30578E),
                    hoverTextColor: const Color(0xFF2876E4),
                    hoverDecorationColor: Color(0xFF2876E4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool isPassword = false,
  }) {
    bool obscureText = isPassword;
    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 16,
              child: Text(
                hintText,
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: const Color(0xFF414141),
                ),
              ),
            ),
            TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              cursorColor: const Color(0xFF414141),
              obscureText: isPassword ? obscureText : false,
              validator: validator,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF414141)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF414141)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF414141)),
                ),
                errorStyle: TextStyle(color: Colors.red),
                hintText: '',
                hintStyle: GoogleFonts.barlow(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: const Color(0xFF414141),
                ),
                contentPadding: EdgeInsets.only(
                  top: isPassword ? 16 : 10,
                  right: isPassword ? 40 : 0,
                ),
                suffixIcon:
                    isPassword
                        ? GestureDetector(
                          onTap: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          child: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF30578E),
                            size: 20,
                          ),
                        )
                        : null,
              ),
              style: const TextStyle(
                color: Color(0xFF414141),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}
