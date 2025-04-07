import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auto_scroll.dart';

class AboveFooter extends StatefulWidget {
  const AboveFooter({super.key});

  @override
  State<AboveFooter> createState() => _AboveFooterState();
}

class _AboveFooterState extends State<AboveFooter> {
  final List<String> imagePaths = [
    "assets/grouped_alphabet/dot.svg",
    "assets/grouped_alphabet/@.svg",
    "assets/grouped_alphabet/k.svg",
    "assets/grouped_alphabet/i.svg",
    "assets/grouped_alphabet/r.svg",
    "assets/grouped_alphabet/e.svg",
    "assets/grouped_alphabet/i.svg",
    "assets/grouped_alphabet/m.svg",
    "assets/grouped_alphabet/i.svg",
    "assets/grouped_alphabet/c.svg",
    "assets/grouped_alphabet/s.svg",
  ];
  List<double> imageHeights = [
    16.0,
    70.0,
    90.0,
    67.0,
    70.0,
    72.0,
    67.0,
    70.0,
    67.0,
    72.0,
    72.0,
  ]; // match this list length to imagePaths

  void _launchInstagram() async {
    final Uri url = Uri.parse("https://www.google.co.in/");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 166,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Follow The Journey",
                style: TextStyle(
                  fontFamily: 'Cralika',
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  height: 36 / 32,
                  letterSpacing: 0.04 * 32,
                  color: Color(0xFF3E5B84),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _launchInstagram,
                child: Image.asset(
                  "assets/above_footer/instag.png",
                  height: 31,
                  width: 31,
                ),
              ),
            ],
          ),
          SizedBox(height: 50), // spacing between rows
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AutoScrollImagesWeb(
                    imagePaths: imagePaths,
                    imageHeights: imageHeights,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
