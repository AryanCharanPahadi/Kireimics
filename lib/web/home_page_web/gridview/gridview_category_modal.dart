import 'package:flutter/material.dart';

class HomePageCategory {
  final String id;
  final String name;
  final double price;
  final List<String> imagePath; // Changed to List<String>
  final bool hasDiscount;
  final String discountText;
  final Color discountColor;
  final Color discountTextColor;

  HomePageCategory({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.hasDiscount = false,
    this.discountText = 'Few Pieces Left',
    this.discountColor = Colors.white,
    this.discountTextColor = const Color(0xFFF46856),
  });
}
