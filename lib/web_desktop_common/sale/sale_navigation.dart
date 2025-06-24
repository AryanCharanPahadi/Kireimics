import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/web_desktop_common/sale/sale_categories_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/categories/categories_controller.dart';
import '../component/rotating_svg_loader.dart';

class SaleNavigation extends StatelessWidget {
  final int? selectedCategoryId;
  final Function(int, String, String)? onCategorySelected;
  final Function()? fetchAllProducts;
  final BuildContext? context;
  final double fontSize; // Font size parameter
  final FontWeight fontWeight; // Font weight parameter

  const SaleNavigation({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.fetchAllProducts,
    this.context,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    // Use the provided context or fall back to the build context
    final effectiveContext = this.context ?? context;
    final SaleCategoriesController categoriesController = Get.put(
      SaleCategoriesController(),
    );
    final screenWidth = MediaQuery.of(effectiveContext).size.width;
    final isSmallScreen = screenWidth < 800;

    return Obx(() {
      if (categoriesController.isLoading.value) {
        return const RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg');
      }

      final currentRoute =
          GoRouter.of(context).routeInformationProvider.value.uri.toString();
      final children =
          categoriesController.categories
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
                    onCategorySelected!(id, name, desc);
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
