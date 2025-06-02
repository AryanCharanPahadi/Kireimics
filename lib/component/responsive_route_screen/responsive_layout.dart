import 'package:flutter/material.dart';
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/desktop/desktop_main.dart';
import 'package:kireimics/mobile/mobile_main.dart';
import 'package:kireimics/web/web_main.dart';

class ResponsiveLayout extends StatelessWidget {
  final String? initialRoute;

  const ResponsiveLayout({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final route = initialRoute ?? AppRoutes.home;

        if (constraints.maxWidth < 800) {
          // Mobile
          return LandingPageMobile(initialRoute: route);
        } else if (constraints.maxWidth < 1400) {
          // Web/Laptop
          return LandingPageWeb(initialRoute: route);
        } else {
          // Large Desktop / TV
          return LandingPageDesktop(initialRoute: route);
        }
      },
    );
  }
}
