import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomWebHeader extends StatelessWidget {
  const CustomWebHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 99,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Image.asset(
                'assets/fullLogoNew.png',
                height: 31,
                width: 191,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHoverIcon('assets/IconSearch.svg', 18, 18),
                  const SizedBox(width: 32),
                  _buildHoverIcon('assets/IconWishlist.svg', 18, 15),
                  const SizedBox(width: 32),
                  _buildHoverIcon('assets/IconProfile.svg', 18, 16),
                  const SizedBox(width: 32),
                  _buildHoverIcon('assets/IconCart.svg', 20, 19),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoverIcon(String assetPath, double width, double height) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, isHoveredValue, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isHoveredValue
                ? Matrix4.diagonal3Values(1.5, 1.5, 1.0)
                : Matrix4.identity(),
            child: GestureDetector(
              onTap: () {},
              child: SvgPicture.asset(
                assetPath,
                width: width,
                height: height,
              ),
            ),
          );
        },
      ),
    );
  }
}
