import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:http/http.dart' as http;
import 'package:kireimics/mobile/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import '../../component/api_helper/api_helper.dart';
import '../../component/google_sign_in/auth.dart';
import '../../component/google_sign_in/google_sign_in_button.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/notification_toast/custom_toast.dart';
import '../../component/app_routes/routes.dart';
import '../../component/utilities/utility.dart';
import '../../web_desktop_common/login_signup/signup/signup_controller.dart';

class SignInMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  const SignInMobile({super.key, this.onWishlistChanged});
  @override
  State<SignInMobile> createState() => _SignInMobileState();
}

class _SignInMobileState extends State<SignInMobile> {
  bool showLoginBox = true; // initially show the login container
  bool isChecked = false;
  final signupController = Get.put(SignupController());
  bool showSuccessBanner = false;
  bool showErrorBanner = false;
  String errorMessage = "";
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
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context.go(AppRoutes.home);
                  },
                  child: SvgPicture.asset(
                    "assets/icons/closeIcon.svg",
                    height: 18,
                    width: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CralikaFont(
              text: "Sign Up",
              color: const Color(0xFF414141),
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
              lineHeight: 1.0,
              letterSpacing: 0.128,
            ),
            const SizedBox(height: 12),
            BarlowText(
              text: "Create a free Kireimics account for a quick checkout.",
              fontWeight: FontWeight.w400,
              fontSize: 14,
              lineHeight: 1.0,
              letterSpacing: 0.0,
            ),
            const SizedBox(height: 44),
            Form(
              key: signupController.formKey,
              child: Column(
                children: [
                  customTextFormField(
                    hintText: "FIRST NAME",
                    controller: signupController.firstNameController,
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
                  customTextFormField(
                    hintText: "LAST NAME",
                    controller: signupController.lastNameController,
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
                  customTextFormField(
                    hintText: "PHONE",
                    controller: signupController.phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  customTextFormField(
                    hintText: "CREATE PASSWORD",
                    controller: signupController.passwordController,
                    isPassword: true, // Add isPassword flag
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
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              bool success = await signupController
                                  .handleSignUp(context);
                              if (mounted) {
                                setState(() {
                                  if (success) {
                                    showSuccessBanner = true;
                                    showErrorBanner = false;
                                    widget.onWishlistChanged?.call(
                                      "Sign Up successful!",
                                    );
                                  } else {
                                    showSuccessBanner = false;
                                    showErrorBanner = true;
                                    errorMessage =
                                        signupController.signupMessage;
                                    widget.onWishlistChanged?.call(
                                      errorMessage,
                                    );
                                  }
                                });
                              }
                            },
                            child: BarlowText(
                              text: "SIGN UP",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              color: Color(0xFF3E5B84),
                              backgroundColor: Color(0xFFb9d6ff),
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: 320,
                            child: Text.rich(
                              TextSpan(
                                text: 'By signing up, you are agreeing to our ',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.barlow().fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                  color: Color(0xFF414141),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Color(0xFF3E5B84),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            context.go(AppRoutes.privacyPolicy);
                                          },
                                  ),
                                  TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Shipping Policy',
                                    style: TextStyle(
                                      color: Color(0xFF3E5B84),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            context.go(
                                              AppRoutes.shippingPolicy,
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
                            fontSize: 14,
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
            const SizedBox(height: 40),
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
                            fontSize: 12,
                            lineHeight: 1.5,
                            color: const Color(0xFF3E5B84),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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
                        ? IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF3E5B84),
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText; // Toggle visibility
                            });
                          },
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
