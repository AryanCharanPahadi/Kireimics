import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/categories/categories_controller.dart';

class CollectionNavigation extends StatelessWidget {
  final int selectedCategoryId;
  final Function(int, String, String, {int? productIds}) onCategorySelected; // Updated signature
  final Function()? fetchAllProducts;
  final BuildContext context;
  final double fontSize;
  final FontWeight fontWeight;
  final int? productIds; // Add productIds parameter

  const CollectionNavigation({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.fetchAllProducts,
    required this.context,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.productIds, // Add productIds to constructor
  });

  @override
  Widget build(BuildContext context) {
    final CategoriesController categoriesController = Get.find<CategoriesController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Obx(() {
      if (categoriesController.isLoading.value) {
        return const CircularProgressIndicator();
      }

      final children = categoriesController.categories
          .where((category) => (category['name'] as String).toLowerCase() != 'collections')
          .map((category) {
        final name = category['name'] as String;
        final desc = category['description'] as String;
        final id = category['id'] as int;

        return GestureDetector(
          onTap: () {
            onCategorySelected(id, name, desc, productIds: productIds); // Pass productIds
          },
          child: BarlowText(
            text: name,
            color: const Color(0xFF3E5B84),
            fontWeight: fontWeight,
            fontSize: fontSize,
            lineHeight: 1.0,
            letterSpacing: 0.04 * fontSize,
            decoration: selectedCategoryId == id
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationThickness: 2.0,
            decorationColor: const Color(0xFF3E5B84),
          ),
        );
      }).toList();

      return isSmallScreen
          ? Wrap(
        spacing: 16,
        runSpacing: 18,
        children: children,
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children
            .map((child) => Padding(
          padding: const EdgeInsets.only(right: 32),
          child: child,
        ))
            .toList(),
      );
    });
  }
}