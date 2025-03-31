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

//
// import 'package:flutter/material.dart';
// import 'package:kireimics/web/web_home_page.dart';
// import 'dart:html' as html; // Import only for Flutter Web
// import 'mobile/mobile_home_page.dart';
//
// void main() {
//   // ✅ Apply custom cursor globally
//   html.document.body?.style.cursor = 'url("https://vedvika.com/Vector.svg"), auto';
//
//   // ✅ Ensure cursor stays custom when moved
//   html.document.onMouseMove.listen((event) {
//     html.document.body?.style.cursor = 'url("https://vedvika.com/Vector.svg"), auto';
//   });
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth > 800) {
//             return const LandingPageWeb();
//           } else {
//             return const LandingPageMobile();
//           }
//         },
//       ),
//     );
//   }
// }
//
