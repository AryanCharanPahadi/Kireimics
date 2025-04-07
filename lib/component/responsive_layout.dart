import 'package:flutter/material.dart';
import 'package:kireimics/component/routes.dart';
import 'package:kireimics/web/web_main.dart';
import 'package:kireimics/mobile/mobile_main.dart';

class ResponsiveLayout extends StatelessWidget {
  final String? initialRoute;

  const ResponsiveLayout({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return LandingPageMobile(initialRoute: initialRoute ?? AppRoutes.home);
        } else {
          return LandingPageWeb(initialRoute: initialRoute ?? AppRoutes.home);
        }
      },
    );
  }
}