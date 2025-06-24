import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import '../../../component/app_routes/routes.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/utilities/utility.dart';
import '../../component/rotating_svg_loader.dart';

class ForgetPasswordPage extends StatefulWidget {
  final Function(String)? onWishlistChanged;
  final Function(String)? onErrorWishlistChanged;
  const ForgetPasswordPage({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final String formattedDate = getFormattedDate();
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration;
    final uri = Uri.parse(route.uri.toString());

    final email = uri.queryParameters['email'];

    return Stack(
      children: [
        Positioned(
          left: MediaQuery.of(context).size.width > 1400 ? 700 : 405,
          // bottom: 273,
          top: MediaQuery.of(context).size.width > 1400 ? 250 : 164,

          child: SvgPicture.asset(
            'assets/footer/footerbg.svg',
            height: 290,
            width: 254,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Positioned(
          left: MediaQuery.of(context).size.width > 1400 ? 1100 : 850,
          // bottom: 273,
          top: MediaQuery.of(context).size.width > 1400 ? 350 : 280,

          child: SvgPicture.asset(
            'assets/footer/diamond.svg',
            height: 60,
            width: 60,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Positioned(
          left: MediaQuery.of(context).size.width > 1400 ? 1000 : 750,
          // bottom: 273,
          top: MediaQuery.of(context).size.width > 1400 ? 650 : 500,

          child: SvgPicture.asset(
            'assets/footer/footerbg.svg',
            height: 150,
            width: 150,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Positioned(
          left: MediaQuery.of(context).size.width > 1400 ? 850 : 505,
          // bottom: 273,
          top: MediaQuery.of(context).size.width > 1400 ? 750 : 570,

          child: SvgPicture.asset(
            'assets/footer/diamond.svg',
            height: 30,
            width: 30,

            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Color(0xFFDDEAFF), BlendMode.srcIn),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 76),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/header/fullLogoNew.png",
                    width: 277,
                    height: 45,
                  ),
                  const SizedBox(height: 84),
                  CralikaFont(
                    text: "Reset Password",
                    color: const Color(0xFF414141),
                    fontWeight: FontWeight.w600,
                    fontSize: 32.0,
                    lineHeight: 1.0,
                    letterSpacing: 0.128,
                  ),
                  const SizedBox(height: 8),
                  BarlowText(
                    text: "Please enter your new desired password.",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    lineHeight: 1.0,
                    letterSpacing: 0.0,
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: SizedBox(
                      width: 428,
                      child: Column(
                        children: [
                          customTextFormField(
                            hintText: "ENTER NEW PASSWORD",
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 32),
                          customTextFormField(
                            hintText: "RE-ENTER NEW PASSWORD",
                            isPassword: true,
                            controller: _confirmPasswordController,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 44),
                  _isLoading
                      ?  RotatingSvgLoader(
    assetPath: 'assets/footer/footerbg.svg',
    )
                      : BarlowText(
                      text: "UPDATE PASSWORD",
                      color: const Color(0xFF30578E),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      lineHeight: 1.0,
                      backgroundColor: Color(0xFFb9d6ff),
                      hoverTextColor: Color(0xFF2876E4),
                      onTap: () async {
                        String password = _passwordController.text.trim();
                        String confirmPassword = _confirmPasswordController.text.trim();

                        if (password.isEmpty) {
                          widget.onErrorWishlistChanged?.call("Please enter password");
                          return;
                        }
                        if (confirmPassword.isEmpty) {
                          widget.onErrorWishlistChanged?.call("Please re-enter password");
                          return;
                        }
                        if (password != confirmPassword) {
                          widget.onErrorWishlistChanged?.call("Password is mismatched");
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final response = await ApiHelper.passwordReset(
                            email: email.toString(),
                            password: _passwordController.text,
                            updatedAt: formattedDate,
                          );

                          if (response['error'] == true) {
                            widget.onErrorWishlistChanged?.call(response['message'] ?? "Unknown error");
                          } else {
                            await ApiHelper.resetPasswordSuccessfullyMail(email: email.toString());

                            widget.onWishlistChanged?.call("Password Reset Successfully");
                            _passwordController.clear();
                            _confirmPasswordController.clear();

                            Future.delayed(Duration(seconds: 3), () {
                              if (mounted) {
                                context.go(AppRoutes.home);
                              }
                            });
                          }
                        } catch (e) {
                          widget.onErrorWishlistChanged?.call("Something went wrong: $e");
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      }
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
              fontSize: 12,
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
