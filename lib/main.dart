import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/web/product_view/product_details_web.dart';

import 'package:url_strategy/url_strategy.dart';
import 'component/cart_loader.dart';
import 'component/product_details/pd.dart';
import 'component/product_details/product_details_modal.dart';
import 'component/responsive_layout.dart';
import 'component/routes.dart';
import 'component/splash_screen/splash_screen.dart';

import 'dart:html' as html; // Import only for Flutter Web

void main() {

  setPathUrlStrategy();
  html.document.body?.style.cursor =
      'url("https://vedvika.com/Vector.svg"), auto';

  // ✅ Ensure cursor stays custom when moved
  html.document.onMouseMove.listen((event) {
    html.document.body?.style.cursor =
        'url("https://vedvika.com/Vector.svg"), auto';
  });
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/s', // Add this line to show splash screen first

  routes: [
    // Main responsive routes
    GoRoute(path: '/s', builder: (context, state) => const SplashScreen()),

    // Home route
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const ResponsiveLayout(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.about),
    ),
    GoRoute(
      path: AppRoutes.shippingPolicy,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.shippingPolicy),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.privacyPolicy),
    ),
    GoRoute(
      path: AppRoutes.contactUs,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.contactUs),
    ),

    GoRoute(
      path: AppRoutes.catalog,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.catalog),
    ),

    GoRoute(
      path: AppRoutes.collection,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.collection),
    ),
    GoRoute(
      path: AppRoutes.sale,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.sale),
    ),
    GoRoute(
      path: AppRoutes.checkOut,
      builder:
          (context, state) =>
              const ResponsiveLayout(initialRoute: AppRoutes.checkOut),
    ),
    GoRoute(
      path: AppRoutes.addToCart,
      builder: (context, state) {
        final productId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return ResponsiveLayout(initialRoute: AppRoutes.cartDetails(productId));
      },
    ),

    GoRoute(
      path: AppRoutes.productDetailsPath,
      builder: (context, state) {
        final productId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return ResponsiveLayout(
          initialRoute: AppRoutes.productDetails(productId),
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Kireimics",
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
