import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_routes/routes.dart' show AppRoutes;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> _colors = [
    const Color(0xFF3E5B84), // Blue (base)
    const Color(0xFFF46856),
    const Color(0xFFFFBC5A),
  ];

  int _currentColorIndex = 0;
  bool _navigated = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await Future.delayed(const Duration(milliseconds: 500));

          if (!_navigated) {
            setState(() {
              _currentColorIndex = (_currentColorIndex + 1) % _colors.length;
            });
            _controller.reset();
            _controller.forward();
          }
        }
      });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Slide animation for the image
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start completely off screen to the left
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _controller.forward();
    _slideController.forward(); // Start sliding image immediately
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5)); // Example delay

    if (!mounted) return;
    _navigated = true;

    await _fadeController.forward(); // Start fade out
    if (!mounted) return;

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: _colors[0],
        body: Stack(
          children: [
            ..._colors.asMap().entries.map((entry) {
              final index = entry.key;
              final color = entry.value;

              if (index == 0) return const SizedBox.shrink();

              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRect(
                      child: SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                            (_currentColorIndex == index
                                ? _animation.value
                                : (_currentColorIndex > index ? 1.0 : 0.0)),
                        child: Container(color: color),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            Align(
              alignment:
                  screenWidth < 800 ? Alignment.center : Alignment.centerLeft,
              child: Padding(
                padding:
                    screenWidth < 800
                        ? const EdgeInsets.symmetric(horizontal: 10)
                        : const EdgeInsets.only(left: 40),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Image.asset(
                    "assets/loader/kiremics_new.png",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
