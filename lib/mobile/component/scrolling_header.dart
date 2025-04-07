import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

class ScrollingHeaderMobile extends StatelessWidget {
  final Color color;

  const ScrollingHeaderMobile({
    super.key,
    this.color =  Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: color,
      child: Marquee(
        text: '✦ Free shipping pan-India for orders above Rs. 2000    ',
        style: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.barlow().fontFamily,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          fontSize: 14,
          height: 1.0,
          letterSpacing: 0.0,
        ),
        scrollAxis: Axis.horizontal,
        blankSpace: 160.0,
        velocity: 50.0,
        pauseAfterRound: const Duration(seconds: 0),
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}