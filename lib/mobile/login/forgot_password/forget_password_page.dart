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

import '../../../component/api_helper/api_helper.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/utilities/utility.dart';
import '../../../web/checkout/checkout_controller.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';
import '../../../web_desktop_common/component/rotating_svg_loader.dart';

class ForgotPasswordMainMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged;
  final Function(String)? onErrorWishlistChanged;
  const ForgotPasswordMainMobile({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });

  @override
  State<ForgotPasswordMainMobile> createState() =>
      _ForgotPasswordMainMobileState();
}

class _ForgotPasswordMainMobileState extends State<ForgotPasswordMainMobile> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final String formattedDate = getFormattedDate();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());

    final email = uri.queryParameters['email'];
    return Stack(
      children: [
        Positioned(
          top: 393,
          left: 35,

          child: SvgPicture.asset(
            'assets/footer/footerbg.svg',
            height: 154,
            width: 152,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Positioned(
          top: 450,
          left: 283,

          child: SvgPicture.asset(
            'assets/footer/diamond.svg',
            height: 28,
            width: 28,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Positioned(
          top: 551,
          left: 251,
          child: SvgPicture.asset(
            'assets/footer/footerbg.svg',
            height: 104,
            width: 103,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Positioned(
          top: 592,
          left: 100,
          child: SvgPicture.asset(
            'assets/footer/diamond.svg',
            height: 17,
            width: 17,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                CralikaFont(
                  text: "Reset Password",
                  color: const Color(0xFF414141),
                  fontWeight: FontWeight.w400,
                  fontSize: 24.0,
                  lineHeight: 1.0,
                  letterSpacing: 0.128,
                ),
                const SizedBox(height: 8),

                BarlowText(
                  text: "Please enter your new desired password.",
                  color: const Color(0xFF414141),
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  lineHeight: 1.0,
                  letterSpacing: 0.128,
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      customTextFormField(
                        hintText: "ENTER NEW PASSWORD",
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      SizedBox(height: 32),

                      customTextFormField(
                        hintText: "RE-ENTER NEW PASSWORD",
                        isPassword: true,
                        controller: _confirmPasswordController,
                      ),
                      SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              _isLoading
                                  ?  RotatingSvgLoader(
                        assetPath: 'assets/footer/footerbg.svg',
                      )
                                  : BarlowText(
                                    text: "UPDATE PASSWORD",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    lineHeight: 1.0,
                                    letterSpacing: 0.64,
                                    color: Color(0xFF30578E),
                                    backgroundColor: Color(0xFFb9d6ff),
                                    hoverTextColor: Color(0xFF2876E4),
                                    onTap: () async {
                                      String password =
                                          _passwordController.text.trim();
                                      String confirmPassword =
                                          _confirmPasswordController.text
                                              .trim();

                                      if (password.isEmpty) {
                                        widget.onErrorWishlistChanged?.call(
                                          "Please enter password",
                                        );
                                        return;
                                      }
                                      if (confirmPassword.isEmpty) {
                                        widget.onErrorWishlistChanged?.call(
                                          "Please re-enter password",
                                        );
                                        return;
                                      }
                                      if (password != confirmPassword) {
                                        widget.onErrorWishlistChanged?.call(
                                          "Password is mismatched",
                                        );
                                        return;
                                      }

                                      setState(() {
                                        _isLoading = true;
                                      });

                                      try {
                                        final response =
                                            await ApiHelper.passwordReset(
                                              email: email.toString(),
                                              password:
                                                  _passwordController.text,
                                              updatedAt: formattedDate,
                                            );

                                        if (response['error'] == true) {
                                          widget.onErrorWishlistChanged?.call(
                                            response['message'] ??
                                                "Unknown error",
                                          );
                                        } else {
                                          await ApiHelper.resetPasswordSuccessfullyMail(
                                            email: email.toString(),
                                          );

                                          widget.onWishlistChanged?.call(
                                            "Password Reset Successfully",
                                          );
                                          _passwordController.clear();
                                          _confirmPasswordController.clear();

                                          Future.delayed(
                                            Duration(seconds: 3),
                                            () {
                                              if (mounted) {
                                                context.go(AppRoutes.home);
                                              }
                                            },
                                          );
                                        }
                                      } catch (e) {
                                        widget.onErrorWishlistChanged?.call(
                                          "Something went wrong: $e",
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      }
                                    },
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
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    bool isPassword = false,
  }) {
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
          obscureText: isPassword,
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
            hintText: '',
          ),
          style: const TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
