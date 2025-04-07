import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart' show AppRoutes;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2)); // Adjust delay as needed

    if (!mounted) return;
    // Use GoRouter to navigate to home
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: RotationTransition(
          turns: _controller,
          child: Image.asset(
            "assets/loader/logo.png",
            width: 50,
          ),
        ),
      ),
    );
  }
}