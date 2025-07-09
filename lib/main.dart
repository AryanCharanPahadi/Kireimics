import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/web/checkout/encription.dart';
import 'package:kireimics/web_desktop_common/thankyou_page/thankyou.dart';

import 'component/no_found_page/404_page.dart';
import 'component/responsive_route_screen/responsive_layout.dart';
import 'component/app_routes/routes.dart';
import 'component/splash_screen/splash_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyB3fk9XwkfmG4L0nZDnGly7neJ8wfin7D0",
      authDomain: "kireimics-login.firebaseapp.com",
      projectId: "kireimics-login",
      storageBucket: "kireimics-login.firebasestorage.app",
      messagingSenderId: "593473253260",
      appId: "1:593473253260:web:9eef0e420df916560db0a9",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/s',

      routes: [
        // Main responsive routes
        GoRoute(path: '/s', builder: (context, state) => const SplashScreen()),

        // Home route
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const ResponsiveLayout(),
        ),
        GoRoute(
          path: AppRoutes.paymentResult,
          builder: (context, state) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: PaymentStateService().getPaymentResult(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final result = snapshot.data!;
                // print(
                //   'Received payment result from shared preferences: $result',
                // );

                final isSuccess = result['success'] ?? false;
                final orderId = result['orderId'] ?? 'N/A';
                final amount = result['amount'] ?? 0.0;
                final orderDate = result['orderDate'] ?? DateTime.now();

                return PaymentResultPage(
                  isSuccess: isSuccess,
                  orderId: orderId,
                  amount: amount,
                  orderDate: orderDate,
                );
              },
            );
          },
        ),

        GoRoute(
          path: AppRoutes.about,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.about),
        ),

        GoRoute(
          path: AppRoutes.searchQuery,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.searchQuery),
        ),

        GoRoute(
          path: AppRoutes.viewDetails,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.viewDetails),
        ),

        GoRoute(
          path: AppRoutes.shippingPolicy,
          builder:
              (context, state) => const ResponsiveLayout(
                initialRoute: AppRoutes.shippingPolicy,
              ),
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
          path: AppRoutes.logIn,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.logIn),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.signIn),
        ),

        GoRoute(
          path: AppRoutes.addAddress,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.addAddress),
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
          path: AppRoutes.myAccount,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.myAccount),
        ),
        GoRoute(
          path: AppRoutes.myOrder,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.myOrder),
        ),
        GoRoute(
          path: AppRoutes.deleteAddress,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.deleteAddress),
        ),
        GoRoute(
          path: AppRoutes.forgotPasswordMain,
          builder:
              (context, state) => const ResponsiveLayout(
                initialRoute: AppRoutes.forgotPasswordMain,
              ),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder:
              (context, state) => const ResponsiveLayout(
                initialRoute: AppRoutes.forgotPassword,
              ),
        ),
        GoRoute(
          path: AppRoutes.wishlist,
          builder:
              (context, state) =>
                  const ResponsiveLayout(initialRoute: AppRoutes.wishlist),
        ),

        GoRoute(
          path: AppRoutes.addToCart,
          builder: (context, state) {
            final productId =
                int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return ResponsiveLayout(
              initialRoute: AppRoutes.cartDetails(productId),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.productDetailsPath,
          builder: (context, state) {
            final productId =
                int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return ResponsiveLayout(
              initialRoute: AppRoutes.productDetails(productId),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.idCollectionViewPath,
          builder: (context, state) {
            final collectionId =
                int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return ResponsiveLayout(
              initialRoute: AppRoutes.idCollectionView(collectionId),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.catIdProductViewPath,
          builder: (context, state) {
            final catId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return ResponsiveLayout(
              initialRoute: AppRoutes.catIdProductView(catId),
            );
          },
        ),

        GoRoute(
          path: '/:path(.*)',
          builder: (context, state) => const NoFoundPage(),
        ),
      ],
    );

    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Kireimics',

      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
