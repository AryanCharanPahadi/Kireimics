import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import 'drawer.dart';

class CustomHeaderMobile extends StatefulWidget {
  const CustomHeaderMobile({super.key});

  @override
  State<CustomHeaderMobile> createState() => _CustomHeaderMobileState();
}

class _CustomHeaderMobileState extends State<CustomHeaderMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _menuIconController;

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();

    _menuIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _menuIconController.dispose();
    super.dispose();
  }

  Future<void> _loadCartItemCount() async {
    final ids = await SharedPreferencesHelper.getAllProductIds();
    setState(() {
      _cartItemCount = ids.length;
    });
  }

  int _cartItemCount = 0;

  @override
  Widget build(BuildContext context) {
    int? cartProductId;

    return Stack(
      children: [
        Container(
          color: Colors.white,
          height: 73,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _menuIconController,
                    size: 30,
                    color: const Color(0xFF30578E),
                  ),
                  onPressed: () async {
                    await _menuIconController.forward(); // Animate to "close"

                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        reverseTransitionDuration: const Duration(
                          milliseconds: 400,
                        ),
                        pageBuilder: (_, __, ___) => const DrawerMobile(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          final offsetAnimation = Tween<Offset>(
                                begin: const Offset(1.0, 0.0), // from right
                                end: Offset.zero,
                              )
                              .chain(CurveTween(curve: Curves.easeOutCubic))
                              .animate(animation);

                          final fadeAnimation = Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              )
                              .chain(CurveTween(curve: Curves.easeIn))
                              .animate(animation);

                          final scaleAnimation = Tween<double>(
                                begin: 0.95,
                                end: 1.0,
                              )
                              .chain(CurveTween(curve: Curves.easeOut))
                              .animate(animation);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: FadeTransition(
                              opacity: fadeAnimation,
                              child: ScaleTransition(
                                scale: scaleAnimation,
                                child: child,
                              ),
                            ),
                          );
                        },
                      ),
                    );

                    await _menuIconController
                        .reverse(); // Animate back to "menu"
                  },
                ),

                Image.asset(
                  'assets/header/fullLogoNew.png',
                  height: 24,
                  width: 150,
                ),

                GestureDetector(
                  onTap: () {
                    context.go(AppRoutes.cartDetails(cartProductId ?? 0));
                  },
                  child: SvgPicture.asset(
                    'assets/header/IconCart.svg',
                    width: 23,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_cartItemCount > 0)
          Positioned(
            top: 13,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$_cartItemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class Column1 extends StatefulWidget {
  final bool isScrolling; // New parameter to indicate scrolling state
  final Function(String) onNavItemSelected;

  const Column1({
    super.key,
    required this.onNavItemSelected,
    this.isScrolling = false,
  });

  @override
  State<Column1> createState() => _Column1State();
}

class _Column1State extends State<Column1> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool showSearchField = false;
  bool _showSearchIcon = true; // New flag to toggle search/close icon

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Navigate to search query route with the query as a parameter
      context.go('${AppRoutes.searchQuery}?query=$query');
      setState(() {
        showSearchField = false;
        _searchController.clear();
        _searchFocusNode.unfocus();
        _showSearchIcon = true; // Reset to search icon after search
      });
    }
  }

  void _toggleIcon() {
    setState(() {
      if (_showSearchIcon) {
        // Search icon clicked, focus on TextField
        _searchFocusNode.requestFocus();
      } else {
        // Close icon clicked, clear input and show search icon
        _searchController.clear();
        _showSearchIcon = true;
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                top: widget.isScrolling ? 10 : 0.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BarlowText(
                          route: AppRoutes.home,
                          onTap: () => widget.onNavItemSelected(AppRoutes.home),
                          text: "HOME",
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: const Color(0xFF30578E),
                          activeBackgroundColor: const Color(0xFFb9d6ff),
                          enableBackgroundForActiveRoute: true,
                        ),
                        const SizedBox(width: 32),
                        BarlowText(
                          onTap:
                              () => widget.onNavItemSelected(AppRoutes.catalog),
                          route: AppRoutes.catalog,
                          text: "CATALOG",
                          fontWeight: FontWeight.w600,
                          enableBackgroundForActiveRoute: true,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: const Color(0xFF30578E),
                          activeBackgroundColor: const Color(0xFFb9d6ff),
                        ),
                        const SizedBox(width: 32),
                        BarlowText(
                          route: AppRoutes.sale,
                          onTap: () => widget.onNavItemSelected(AppRoutes.sale),
                          text: "SALE",
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: const Color(0xFFf46856),
                          activeBackgroundColor: const Color(0xFFfde1dd),
                          enableBackgroundForActiveRoute: true,
                        ),
                        const SizedBox(width: 32),
                        BarlowText(
                          onTap:
                              () => widget.onNavItemSelected(AppRoutes.about),
                          route: AppRoutes.about,
                          text: "ABOUT",
                          fontWeight: FontWeight.w600,
                          enableBackgroundForActiveRoute: true,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: const Color(0xFF30578E),
                          activeBackgroundColor: const Color(0xFFb9d6ff),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF30578E)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 55,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            // Hint text (positioned on the left)
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'SEARCH',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.barlow().fontFamily,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF414141),
                                ),
                              ),
                            ),
                            // TextField (user input aligned right)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 15.0,
                              ), // <-- Add right padding here
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                cursorColor: const Color(0xFF30578E),
                                onSubmitted: (_) => _handleSearch(),
                                textAlign:
                                    TextAlign.end, // Right-align user input
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.barlow().fontFamily,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF30578E),
                                ),
                                onChanged: (value) {
                                  // Update icon based on text input
                                  setState(() {
                                    _showSearchIcon = value.isEmpty;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleIcon,
                        child: Icon(
                          _showSearchIcon ? Icons.search : Icons.close,
                          color: const Color(0xFF30578E),
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Color(0xFF414141)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
