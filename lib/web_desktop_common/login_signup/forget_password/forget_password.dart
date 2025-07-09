import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../component/api_helper/api_helper.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/utilities/utility.dart';
import '../../component/rotating_svg_loader.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSendingMail = false;

  bool showSuccessBanner = false;
  bool showErrorBanner = false;
  String errorMessage = "";

  Future<void> userData() async {
    final response = await ApiHelper.fetchUserData(emailController.text);

    if (response!['error'] == false) {
      // print(response['data']);
    } else {
      // print(response['error'] == true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

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
            width: isLargeScreen ? 600 : 550,
            child: Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
                child: SingleChildScrollView(
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
                                        ? "Password Reset Mail Sent Successfully"
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
                        text: "Forgot Password",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                        fontSize: 32.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      SizedBox(height: 8),
                      BarlowText(
                        text:
                            "Enter your registered email ID to receive the link to reset your password.",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      SizedBox(height: 32),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            customTextFormField(
                              hintText: "EMAIL",
                              controller: emailController,
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

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (formKey.currentState!.validate()) {
                                          setState(() {
                                            isSendingMail = true;
                                            showSuccessBanner = false;
                                            showErrorBanner = false;
                                          });

                                          final response =
                                              await ApiHelper.fetchUserData(
                                                emailController.text,
                                              );

                                          // If user not found
                                          if (response == null ||
                                              response['error'] == true ||
                                              response['data'] == null ||
                                              (response['data'] as List)
                                                  .isEmpty) {
                                            setState(() {
                                              isSendingMail = false;
                                              errorMessage =
                                                  "Data not found with this email";
                                              showErrorBanner = true;
                                              showSuccessBanner = false;
                                            });

                                            return;
                                          }

                                          final mailResponse =
                                              await ApiHelper.resetPasswordMail(
                                                email: emailController.text,
                                              );

                                          // print(
                                          //   "Password Reset Mail Response: $mailResponse",
                                          // );

                                          if (mailResponse['error'] == false) {
                                            setState(() {
                                              showSuccessBanner = true;
                                              showErrorBanner = false;
                                              errorMessage = '';
                                              isSendingMail = false;
                                            });

                                            Future.delayed(
                                              Duration(seconds: 3),
                                              () {
                                                if (mounted) context.pop();
                                              },
                                            );
                                          } else {
                                            setState(() {
                                              showErrorBanner = true;
                                              showSuccessBanner = false;
                                              errorMessage =
                                                  mailResponse['message'] ??
                                                  'Something went wrong. Please try again.';
                                              isSendingMail = false;
                                            });
                                          }
                                        }
                                      },

                                      child:
                                          isSendingMail
                                              ? SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: RotatingSvgLoader(
                                                  assetPath:
                                                      'assets/footer/footerbg.svg',
                                                ),
                                              )
                                              : BarlowText(
                                                text: "SEND RESET LINK",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                lineHeight: 1.0,
                                                letterSpacing: 0.64,
                                                color: Color(0xFF30578E),
                                                backgroundColor: Color(
                                                  0xFFb9d6ff,
                                                ),
                                                hoverTextColor: Color(
                                                  0xFF2876E4,
                                                ),
                                              ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
    bool enabled = true,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 13,

          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: hintText,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF414141),
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
          validator: validator,
          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: Color(0xFF414141),
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            errorStyle: TextStyle(color: Colors.red),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            hintText: '',
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: Color(0xFF414141),
            ),
            contentPadding: EdgeInsets.only(top: 16),
          ),
          style: TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
