import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RotatingSvgLoader extends StatefulWidget {
  final double size;
  final String assetPath;
  final Color color;

  const RotatingSvgLoader({
    super.key,
    required this.assetPath,
    this.size = 40.0,
    this.color = const Color(0xFFDDEAFF),
  });

  @override
  State<RotatingSvgLoader> createState() => _RotatingSvgLoaderState();
}

class _RotatingSvgLoaderState extends State<RotatingSvgLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Infinite rotation
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        widget.assetPath,
        height: widget.size,
        width: widget.size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
      ),
    );
  }
}
