import 'package:flutter/material.dart';

class AnimatedZoomImage extends StatefulWidget {
  final String imageUrl;
  const AnimatedZoomImage({super.key, required this.imageUrl});

  @override
  State<AnimatedZoomImage> createState() => AnimatedZoomImageState();
}

class AnimatedZoomImageState extends State<AnimatedZoomImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Starts at 1.0 (normal), zooms in to 1.08, then back to 1.0
    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_controller);

    _controller.forward(); // play once
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: Image.network(widget.imageUrl, fit: BoxFit.cover),
    );
  }
}
