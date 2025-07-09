import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';

class ScrollingHeaderMobile extends StatefulWidget {
  final Color? customColor;

  const ScrollingHeaderMobile({super.key, this.customColor});

  @override
  State<ScrollingHeaderMobile> createState() => _ScrollingHeaderMobileState();
}

class _ScrollingHeaderMobileState extends State<ScrollingHeaderMobile> {
  String bandText = '';
  Color? bandColor;

  @override
  void initState() {
    super.initState();
    getBandDetails();
  }

  Future<void> getBandDetails() async {
    final response = await http.get(
      Uri.parse(
        "https://www.kireimics.com/apis/common/band_details/get_band_details.php",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        bandText = data['band_text']?.trim() ?? '';

        if (widget.customColor == null) {
          final colorString = data['band_color'];
          if (colorString != null) {
            bandColor = Color(int.parse(colorString));
          } else {
            bandColor = Colors.black; // fallback color if API color null
          }
        } else {
          bandColor = widget.customColor;
        }

        // print("Band Text: $bandText");
        // print("Band Color: $bandColor");
      });
    } else {
      // print('Failed to fetch band details: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bandText.isEmpty) {
      return const SizedBox.shrink(); // or a placeholder if needed
    }

    return Container(
      height: 40,
      color: bandColor,
      child: Marquee(
        text: bandText,
        style: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.barlow().fontFamily,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          fontSize: 14,
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
