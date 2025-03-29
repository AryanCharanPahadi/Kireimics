import 'package:flutter/material.dart';
import 'package:kireimics/web/web_home_page.dart';
import 'mobile/mobile_home_page.dart';

void main() {


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const LandingPageWeb();
          } else {
            return const LandingPageMobile();
          }
        },
      ),
    );
  }
}
