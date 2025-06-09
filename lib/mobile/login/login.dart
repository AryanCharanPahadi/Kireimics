import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/sign_in/sign_in.dart';

import '../../component/google_sign_in/google_sign_in_button.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/notification_toast/custom_toast.dart';
import '../../web_desktop_common/login_signup/login/login_controller.dart';

class LoginMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  const LoginMobile({super.key, this.onWishlistChanged});
  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  bool showLoginBox = true; // initially show the login container
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
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
              text: "Log In",
              color: const Color(0xFF414141),
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
              lineHeight: 1.0,
              letterSpacing: 0.128,
            ),
            const SizedBox(height: 12),
            BarlowText(
              text: "Log in to your Kireimics account for a quick checkout.",
              fontWeight: FontWeight.w400,
              fontSize: 14,
              lineHeight: 1.0,
              letterSpacing: 0.0,
            ),
            const SizedBox(height: 44),
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
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
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
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                              SizedBox(width: 12),
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
                            fontSize: 14,
                            lineHeight: 1.0,
                            letterSpacing: 0.64,
                            hoverBackgroundColor: Color(0xFFb9d6ff),
                            enableHoverBackground: true,
                            onTap: () {
                              context.go(AppRoutes.forgotPassword);
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
                              bool success = await loginController.handleLogin(
                                context,
                              );
                              if (mounted) {
                                setState(() {
                                  if (success) {
                                    showSuccessBanner = true;
                                    showErrorBanner = false;
                                    widget.onWishlistChanged?.call(
                                      "Login successful!",
                                    );
                                  } else {
                                    showSuccessBanner = false;
                                    showErrorBanner = true;
                                    errorMessage = loginController.loginMessage;
                                    widget.onWishlistChanged?.call(
                                      errorMessage,
                                    );
                                  }

                                });
                              }
                            },
                            child: BarlowText(
                              text: "LOG IN",
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              color: Color(0xFF30578E),
                              backgroundColor: Color(0xFFb9d6ff),
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
            const SizedBox(height: 100),
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
              validator: validator,
              controller: controller,
              textAlign: TextAlign.right,
              cursorColor: const Color(0xFF414141),
              obscureText:
                  isPassword
                      ? obscureText
                      : false, // Apply obscureText for password
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
                  top: isPassword ? 16 : 12,
                  right: isPassword ? 40 : 0, // Add padding for the eye icon
                ),
                suffixIcon:
                    isPassword
                        ? IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF30578E),
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
