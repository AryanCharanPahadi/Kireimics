import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/categories/categories_controller.dart';

class CatalogNavigation extends StatelessWidget {
  final int selectedCategoryId;
  final Function(int, String, String) onCategorySelected;
  final Function() fetchAllProducts;
  final BuildContext context;
  final double fontSize; // Font size parameter
  final FontWeight fontWeight; // Font weight parameter

  const CatalogNavigation({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.fetchAllProducts,
    required this.context,
    this.fontSize = 16, // Default font size if not provided
    this.fontWeight = FontWeight.w600, // Default font weight if not provided
  });

  @override
  Widget build(BuildContext context) {
    final CategoriesController categoriesController =
        Get.find<CategoriesController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Obx(() {
      if (categoriesController.isLoading.value) {
        return const CircularProgressIndicator();
      }

      final children =
          categoriesController.categories.map((category) {
            final name = category['name'] as String;
            final desc = category['description'] as String;
            final id = category['id'] as int;

            return GestureDetector(
              onTap: () {
                onCategorySelected(id, name, desc);
              },
              child: BarlowText(
                text: name,
                color: const Color(0xFF3E5B84),
                fontWeight: fontWeight, // Use fontWeight from parameter
                fontSize: fontSize, // Use fontSize from parameter
                lineHeight: 1.0,
                letterSpacing: 0.04 * fontSize,
                decoration:
                    selectedCategoryId == id
                        ? TextDecoration.underline
                        : TextDecoration.none,
                decorationThickness: 2.0,
                decorationColor: const Color(0xFF3E5B84),
                enableHoverUnderline: true,
              ),
            );
          }).toList();

      return isSmallScreen
          ? Wrap(spacing: 16, runSpacing: 18, children: children)
          : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                children
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: child,
                      ),
                    )
                    .toList(),
          );
    });
  }
}
