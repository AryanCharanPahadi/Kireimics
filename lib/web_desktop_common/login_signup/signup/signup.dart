import 'dart:convert' show json;
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/web_desktop_common/login_signup/signup/signup_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/google_sign_in/auth.dart';
import '../../../component/google_sign_in/google_sign_in_button.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/utilities/utility.dart';
import '../login/login_page.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final signupController = Get.put(SignupController());
  bool isChecked = false;
  bool showSuccessBanner = false;
  bool showErrorBanner = false;
  String errorMessage = "";

  @override
  void dispose() {
    // Clear all text controllers to prevent memory leaks
    signupController.firstNameController.clear();
    signupController.lastNameController.clear();
    signupController.emailController.clear();
    signupController.phoneController.clear();
    signupController.passwordController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            width: MediaQuery.of(context).size.width > 1400 ? 550 : 504,
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                                if (showSuccessBanner || showErrorBanner)
                                  NotificationBanner(
                                    iconPath:
                                        showSuccessBanner
                                            ? "assets/icons/success.svg"
                                            : "assets/icons/error.svg",

                                    message:
                                        showSuccessBanner
                                            ? "Signed Up successfully!"
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
                            text: "Sign Up",
                            color: Color(0xFF414141),
                            fontWeight: FontWeight.w600,
                            fontSize: 32.0,
                            lineHeight: 1.0,
                            letterSpacing: 0.128,
                          ),
                          SizedBox(height: 8),
                          BarlowText(
                            text:
                                "Create a free Kireimics account for a quick checkout.",
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            lineHeight: 1.0,
                            letterSpacing: 0.0,
                          ),
                          SizedBox(height: 28),
                          Form(
                            key: signupController.formKey,
                            child: Column(
                              children: [
                                customTextFormField(
                                  hintText: "FIRST NAME",
                                  controller:
                                      signupController.firstNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    if (value.length < 2) {
                                      return 'First name too short';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 28),
                                customTextFormField(
                                  hintText: "LAST NAME",
                                  controller:
                                      signupController.lastNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    if (value.length < 2) {
                                      return 'Last name too short';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 28),
                                customTextFormField(
                                  hintText: "EMAIL",
                                  controller: signupController.emailController,
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
                                SizedBox(height: 28),
                                customTextFormField(
                                  hintText: "PHONE",
                                  controller: signupController.phoneController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (!RegExp(
                                      r'^[0-9]{10,15}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 28),
                                customTextFormField(
                                  hintText: "CREATE PASSWORD",
                                  controller:
                                      signupController.passwordController,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            bool success =
                                                await signupController
                                                    .handleSignUp(context);
                                            if (mounted) {
                                              setState(() {
                                                if (success) {
                                                  showSuccessBanner = true;
                                                  showErrorBanner = false;
                                                } else {
                                                  showSuccessBanner = false;
                                                  showErrorBanner = true;
                                                  errorMessage =
                                                      signupController
                                                          .signupMessage;
                                                }
                                              });
                                              if (success) {
                                                Future.delayed(
                                                  const Duration(seconds: 1),
                                                  () {
                                                    if (mounted) {
                                                      setState(() {
                                                        showSuccessBanner =
                                                            false;
                                                      });
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    }
                                                  },
                                                );
                                              }
                                            }
                                          },
                                          child: BarlowText(
                                            text: "SIGN UP",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            lineHeight: 1.0,
                                            letterSpacing: 0.64,
                                            color: Color(0xFF30578E),
                                            backgroundColor: Color(0xFFb9d6ff),
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        Container(
                                          width: 320,
                                          child: Text.rich(
                                            TextSpan(
                                              text:
                                                  'By signing up, you are agreeing to our ',
                                              style: TextStyle(
                                                fontFamily:
                                                    GoogleFonts.barlow()
                                                        .fontFamily,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                height: 1.0,
                                                letterSpacing: 0.0,
                                                color: Color(0xFF414141),
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Privacy Policy',
                                                  style: TextStyle(
                                                    color: Color(0xFF30578E),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          context.go(
                                                            AppRoutes
                                                                .privacyPolicy,
                                                          );
                                                        },
                                                ),
                                                TextSpan(
                                                  text: ' & ',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        GoogleFonts.barlow()
                                                            .fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: Color(0xFF414141),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'Shipping Policy',
                                                  style: TextStyle(
                                                    color: Color(0xFF30578E),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          context.go(
                                                            AppRoutes
                                                                .shippingPolicy,
                                                          );
                                                        },
                                                ),
                                                TextSpan(text: '.'),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
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
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // Fixed login container at the bottom
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
                      border: Border.all(color: Color(0xFFDDEAFF), width: 1),
                    ),
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
                              text: "Already have an account?",
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              lineHeight: 1.0,
                              color: Color(0xFF000000),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Future.delayed(Duration.zero, () {
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.transparent,
                                    builder: (BuildContext context) {
                                      return LoginPage();
                                    },
                                  );
                                });
                              },
                              child: BarlowText(
                                text: "LOG IN NOW",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool isPassword = false, // Add isPassword parameter
  }) {
    bool obscureText =
        isPassword; // Initially hide password if isPassword is true
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
              obscureText:
                  isPassword
                      ? obscureText
                      : false, // Apply obscureText for password
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
                contentPadding: const EdgeInsets.only(
                  top: 16,
                  right: 40, // Add padding for the eye icon
                ),
                suffixIcon:
                    isPassword
                        ? GestureDetector(
                          onTap: () {
                            setState(() {
                              obscureText = !obscureText; // Toggle visibility
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
              style: const TextStyle(color: Color(0xFF414141)),
            ),
          ],
        );
      },
    );
  }
}
