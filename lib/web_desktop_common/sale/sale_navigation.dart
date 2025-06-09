import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/web_desktop_common/sale/sale_categories_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/categories/categories_controller.dart';

class SaleNavigation extends StatelessWidget {
  final int selectedCategoryId;
  final Function(int, String, String) onCategorySelected;
  final Function() fetchAllProducts;
  final BuildContext context;
  final double fontSize; // Font size parameter
  final FontWeight fontWeight; // Font weight parameter

  const SaleNavigation({
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
    final SaleCategoriesController saleCategoriesController = Get.put(
      SaleCategoriesController(),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Obx(() {
      if (saleCategoriesController.isLoading.value) {
        return const CircularProgressIndicator();
      }

      // Check if the current route is the checkout route
      final currentRoute =
          GoRouter.of(context).routeInformationProvider.value.uri.toString();
      final children =
          saleCategoriesController.categories
              .where((category) {
                if (currentRoute.contains(AppRoutes.sale) &&
                    (category['name']?.toString().toLowerCase() ==
                        'collections')) {
                  return false;
                }
                return true;
              })
              .map((category) {
                final name = category['name'] as String;
                final desc = category['sale_description'] as String;
                final id = category['id'] as int;

                return GestureDetector(
                  onTap: () {
                    onCategorySelected(id, name, desc);
                  },
                  child: BarlowText(
                    text: name,
                    color: const Color(0xFF30578E),
                    fontWeight: fontWeight,
                    fontSize: fontSize,
                    lineHeight: 1.0,
                    letterSpacing: 0.04 * fontSize,
                    decoration:
                        selectedCategoryId == id
                            ? TextDecoration.underline
                            : TextDecoration.none,
                    decorationThickness: 2.0,
                    enableUnderlineForActiveRoute: true,
                    decorationColor: Color(0xFF30578E),
                    hoverTextColor: const Color(0xFF2876E4),
                  ),
                );
              })
              .toList();

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
