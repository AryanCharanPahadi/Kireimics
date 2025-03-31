import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AutoScrollImagesWeb extends StatefulWidget {
  final List<String> imagePaths;
  final List<double> imageHeights;

  const AutoScrollImagesWeb({
    required this.imagePaths,
    required this.imageHeights,
  });

  @override
  State<AutoScrollImagesWeb> createState() => AutoScrollImagesWebState();
}

class AutoScrollImagesWebState extends State<AutoScrollImagesWeb> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_scrollController.hasClients) {
        _scrollPosition += 1.0; // change this to control speed
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0.0;
        }
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.imagePaths.length * 3, // Repeat 3x
      itemBuilder: (context, index) {
        int actualIndex = index % widget.imagePaths.length;
        bool isLastInLoop = actualIndex == widget.imagePaths.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 2,
              ), // Small space between all images
              child: SvgPicture.asset(
                widget.imagePaths[actualIndex],
                height: widget.imageHeights[actualIndex],
                color: Color(0xFFD7E7FF),
                fit: BoxFit.contain,
              ),
            ),
            if (isLastInLoop)
              const SizedBox(width: 20), // Larger space after a full cycle
          ],
        );
      },
    );
  }
}