import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../component/text_fonts/custom_text.dart';

class ThankYouNew extends StatefulWidget {
  const ThankYouNew({super.key});

  @override
  State<ThankYouNew> createState() => _ThankYouNewState();
}

class _ThankYouNewState extends State<ThankYouNew> {
  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width > 1400 ? 800 : 501.0,
            top: MediaQuery.of(context).size.width > 1400 ? 150 : 76,
          ),
          child: Container(
            color: Color(0xFF268FA2),
            width: 428,
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
                customTextFormField(hintText: "ENTER NEW PASSWORD"),
                const SizedBox(height: 32),
                customTextFormField(hintText: "RE-ENTER NEW PASSWORD"),
                const SizedBox(height: 44),

                BarlowText(
                  text: "UPDATE PASSWORD",
                  color: const Color(0xFF30578E),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  lineHeight: 1.0,
                  backgroundColor: Color(0xFFb9d6ff),
                  hoverTextColor: Color(0xFF2876E4),
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
                contentPadding: const EdgeInsets.only(right: 40),
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
