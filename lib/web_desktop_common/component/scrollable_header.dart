import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;

class ScrollableHeader extends StatefulWidget {
  const ScrollableHeader({super.key});

  @override
  State<ScrollableHeader> createState() => _ScrollableHeaderState();
}

class _ScrollableHeaderState extends State<ScrollableHeader> {
  String bandText = '';
  Color? bandColor;

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
        final colorString = data['band_color'];
        if (colorString != null) {
          bandColor = Color(int.parse(colorString));
        }

        // print("Band Text: $bandText");
        // print("Band Color: $bandColor");
      });
    } else {
      // print('Failed to fetch band details: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBandDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (bandText.isEmpty) {
      return const SizedBox.shrink(); // or a loader or placeholder
    }

    return Container(
      height: 32,
      color: bandColor,
      child: Marquee(
        text: bandText,
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
