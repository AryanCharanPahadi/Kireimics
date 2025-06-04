// utils.dart

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Generates a unique ID of specified length using random characters.
String generateUniqueId(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

/// Returns the current date in 'yyyy-MM-dd' format.
String getFormattedDate() {
  DateTime now = DateTime.now();
  return DateFormat('yyyy-MM-dd').format(now);
}



class BlurredBackdrop extends StatelessWidget {
  final double sigmaX;
  final double sigmaY;
  final Color color;
  final double opacity;

  const BlurredBackdrop({
    this.sigmaX = 0.0,
    this.sigmaY = 0.0,
    this.color = const Color(0xFFB9D6FF),
    this.opacity = 0.73,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}
