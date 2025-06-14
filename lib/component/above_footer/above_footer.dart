import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kireimics/component/utilities/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../web_desktop_common/component/auto_scroll.dart'
    show AutoScrollImages;
import '../general_links/general_links_contrller.dart';

class AboveFooter extends StatefulWidget {
  final double fontSize;

  const AboveFooter({super.key, this.fontSize = 32});

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

  late GeneralLinksController _generalLinksController;

  final List<double> imageHeights = [
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
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _generalLinksController = GeneralLinksController();
    _generalLinksController.getGeneralLinks();
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = widget.fontSize;

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
                  fontSize: fontSize,
                  height: 36 / fontSize,
                  letterSpacing: 0.04 * fontSize,
                  color: Color(0xFF30578E),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap:
                    () => UrlLauncherHelper.launchURL(
                      context,
                      _generalLinksController.instagramLink,
                    ),
                child: Image.asset(
                  "assets/above_footer/instag.png",
                  height: 31,
                  width: 31,
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AutoScrollImages(
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
