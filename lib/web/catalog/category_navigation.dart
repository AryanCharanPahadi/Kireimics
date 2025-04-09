import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/custom_text.dart';
import '../../component/categories/categories_controller.dart';

class CategoryNavigation extends StatelessWidget {
  final int selectedCategoryId;
  final Function(int, String, String) onCategorySelected;
  final Function() fetchAllProducts;
  final BuildContext context;

  const CategoryNavigation({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.fetchAllProducts,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final CatalogController categoriesController = Get.find<CatalogController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Obx(() {
      if (categoriesController.isLoading.value) {
        return const CircularProgressIndicator();
      }

      final children = categoriesController.categories.map((category) {
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
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : screenWidth * 0.012,
            lineHeight: 1.0,
            letterSpacing: 0.04 * 16,
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
