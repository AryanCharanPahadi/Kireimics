import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomWebHeader extends StatefulWidget {
  const CustomWebHeader({super.key});

  @override
  State<CustomWebHeader> createState() => _CustomWebHeaderState();
}

class _CustomWebHeaderState extends State<CustomWebHeader> {
  final Map<String, bool> _isHovered = {}; // Store hover states for each icon

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
                'assets/header/fullLogoNew.png',
                height: 31,
                width: 191,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIcon('assets/header/IconSearch.svg', 18, 18),
                  const SizedBox(width: 32),
                  _buildIcon('assets/header/IconWishlist.svg', 18, 15),
                  const SizedBox(width: 32),
                  _buildIcon('assets/header/IconProfile.svg', 18, 16),
                  const SizedBox(width: 32),
                  _buildIcon('assets/header/IconCart.svg', 20, 19),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, double width, double height) {
    _isHovered.putIfAbsent(assetPath, () => false); // Initialize state if missing

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered[assetPath] = true),
      onExit: (_) => setState(() => _isHovered[assetPath] = false),
      child: GestureDetector(
        onTap: () {},
        child: SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          colorFilter: _isHovered[assetPath] == true
              ? const ColorFilter.mode(Color(0xFF2876E4), BlendMode.srcIn)
              : null, // Change color on hover
        ),
      ),
    );
  }
}
