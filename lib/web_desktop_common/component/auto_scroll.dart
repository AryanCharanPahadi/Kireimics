import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AutoScrollImages extends StatefulWidget {
  final List<String> imagePaths;
  final List<double> imageHeights;

  const AutoScrollImages({
    super.key,
    required this.imagePaths,
    required this.imageHeights,
  });

  @override
  State<AutoScrollImages> createState() => AutoScrollImagesState();
}

class AutoScrollImagesState extends State<AutoScrollImages> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
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
        _scrollPosition += 1.0;
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0.0;
        }
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxImageHeight = widget.imageHeights.isNotEmpty
        ? widget.imageHeights.reduce((a, b) => a > b ? a : b)
        : 100;

    return SizedBox(
      height: (widget.imageHeights.isNotEmpty ? widget.imageHeights.reduce((a, b) => a > b ? a : b) : 100),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.imagePaths.length * 10, // Repeating
        itemBuilder: (context, index) {
          final actualIndex = index % widget.imagePaths.length;
          final isLastInLoop = actualIndex == widget.imagePaths.length - 1;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SvgPicture.asset(
                  widget.imagePaths[actualIndex],
                  height: widget.imageHeights[actualIndex],
                  color: const Color(0xFFD7E7FF),
                  fit: BoxFit.contain,
                ),
              ),
              if (isLastInLoop) const SizedBox(width: 20), // Extra space after full loop
            ],
          );
        },
      ),
    );
  }
}
