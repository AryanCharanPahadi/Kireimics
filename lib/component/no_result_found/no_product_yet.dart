import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';

class NoProductYet extends StatelessWidget {

  const NoProductYet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        BarlowText(
          text: "We haven't added anything here yet. But we will soon!",
          // backgroundColor: Color(0xFFb9d6ff),
          color: Color(0xFF3E5B84),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

      ],
    );
  }
}
