import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/login_signup/login/login_page.dart';
import '../cart/cart_panel.dart';

class Header extends StatefulWidget {
  final ValueChanged<bool>? onProfileDropdownChanged;

  const Header({super.key, this.onProfileDropdownChanged});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int? _cartProductId;
  int _cartItemCount = 0;

  final Map<String, bool> _isHovered = {};
  bool showSearchField = false;
  bool showProfileDropdown = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && showSearchField) {
        setState(() {
          showSearchField = false;
        });
      }
    });
    _loadCartItemCount();
  }

  Future<void> _loadCartItemCount() async {
    final ids = await SharedPreferencesHelper.getAllProductIds();
    setState(() {
      _cartItemCount = ids.length;
    });
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Navigate to search query route with the query as a parameter
      context.go('${AppRoutes.searchQuery}?query=$query');
      setState(() {
        showSearchField = false;
        _searchController.clear();
        _searchFocusNode.unfocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _isLoggedIn() async {
    String? userData = await SharedPreferencesHelper.getUserData();
    return userData != null && userData.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          color: Colors.white,
          height: 99,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 140 : 44),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Image.asset(
                    'assets/header/newLogoMain.png',
                    height: 31,
                    width: 180,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          if (showSearchField)
                            Container(
                              width: 302,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Color(0xFF414141),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 15.0,
                                      ), // <-- Add right padding here
                                      child: Stack(
                                        children: [
                                          if (_searchController.text.isEmpty)
                                            BarlowText(
                                              text: 'SEARCH',
                                              fontSize: 14,
                                              letterSpacing: 1,
                                              color: Color(0xFF414141),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          TextField(
                                            controller: _searchController,
                                            focusNode: _searchFocusNode,
                                            cursorColor: Color(0xFF30578E),

                                            style: TextStyle(
                                              fontSize: 14,
                                              color: const Color(0xFF30578E),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  GoogleFonts.barlow()
                                                      .fontFamily,
                                            ),
                                            textAlign: TextAlign.right,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onSubmitted: (_) => _handleSearch(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      _searchFocusNode.unfocus();
                                      setState(() {
                                        showSearchField = false;
                                      });
                                    },
                                    child: _buildIcon(
                                      'assets/icons/closeIcon.svg',

                                      14,
                                      14,
                                      onTap: null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Search icon (only shown when search field is hidden)
                          if (!showSearchField)
                            _buildIcon(
                              'assets/header/newSearch.svg',
                              18,
                              18,
                              onTap: () {
                                setState(() {
                                  _searchFocusNode.requestFocus();
                                  showSearchField = true;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () async {
                          bool isLoggedIn =
                              await _isLoggedIn();

                          if (isLoggedIn) {
                            context.go(AppRoutes.wishlist);
                          } else {
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder:
                                  (BuildContext context) => const LoginPage(),
                            );
                          }
                        },
                        child: _buildIcon(
                          'assets/header/newWishlist.svg',
                          18,
                          15,
                        ),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          print("Profile icon tapped");
                          setState(() {
                            showProfileDropdown = !showProfileDropdown;
                            widget.onProfileDropdownChanged?.call(
                              showProfileDropdown,
                            );
                          });
                        },
                        child: _buildIcon(
                          'assets/header/newPerson.svg',
                          18,
                          16,
                        ),
                      ),
                      const SizedBox(width: 32),
                      _buildIcon(
                        'assets/header/newCart.svg',
                        20,
                        19,
                        onTap: () {
                          print("Cart icon tapped");
                          showDialog(
                            context: context,
                            barrierColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return CartPanel();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_cartItemCount > 0)
          Positioned(
            top: 30,
            right: isLargeScreen ? 160 : 63,
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

  Widget _buildIcon(
    String assetPath,
    double width,
    double height, {
    VoidCallback? onTap,
    Key? key,
  }) {
    _isHovered.putIfAbsent(assetPath, () => false);

    return MouseRegion(
      onEnter: (_) {
        print("Mouse entered $assetPath");
        setState(() => _isHovered[assetPath] = true);
      },
      onExit: (_) {
        print("Mouse exited $assetPath");
        setState(() => _isHovered[assetPath] = false);
      },
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          colorFilter:
              _isHovered[assetPath] == true
                  ? const ColorFilter.mode(Color(0xFF2876E4), BlendMode.srcIn)
                  : null,
        ),
      ),
    );
  }
}
