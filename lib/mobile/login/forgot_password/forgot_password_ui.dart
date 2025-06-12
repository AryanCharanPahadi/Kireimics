import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../web/checkout/checkout_controller.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';

class ForgotPasswordUiMobile extends StatefulWidget {
  const ForgotPasswordUiMobile({super.key});

  @override
  State<ForgotPasswordUiMobile> createState() => _ForgotPasswordUiMobileState();
}

class _ForgotPasswordUiMobileState extends State<ForgotPasswordUiMobile> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                context.go(AppRoutes.logIn);
              },
              child: SvgPicture.asset(
                "assets/icons/closeIcon.svg",
                height: 18,
                width: 18,
              ),
            ),

            const SizedBox(height: 20),

            CralikaFont(
              text: "Forgot Password",
              color: const Color(0xFF414141),
              fontWeight: FontWeight.w400,
              fontSize: 24.0,
              lineHeight: 1.0,
              letterSpacing: 0.128,
            ),
            const SizedBox(height: 8),

            BarlowText(
              text:
                  "Enter your registered email ID to receive the link to reset your password.",
              color: const Color(0xFF414141),
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
              lineHeight: 1.0,
              letterSpacing: 0.128,
            ),
            const SizedBox(height: 32),

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
                            onTap: () {
                              context.go(AppRoutes.forgotPasswordMain);
                            },
                            child: BarlowText(
                              text: "SEND RESET LINK",
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              color: Color(0xFF30578E),
                              backgroundColor: Color(0xFFb9d6ff),
                              hoverTextColor: Color(0xFF2876E4),
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
          top: 16,

          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: hintText,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF414141),
                  ),
                ),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
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
              fontSize: 12,
              height: 1.0,
              letterSpacing: 0.0,
              color: Color(0xFF414141),
            ),
            // contentPadding: EdgeInsets.only(top: 16),
          ),
          style: TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
