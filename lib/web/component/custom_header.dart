import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/custom_text.dart';

import '../../component/routes.dart';
import '../../component/shared_preferences.dart';
import '../cart/cart_panel.dart';

class CustomWebHeader extends StatefulWidget {
  const CustomWebHeader({super.key});

  @override
  State<CustomWebHeader> createState() => _CustomWebHeaderState();
}

class _CustomWebHeaderState extends State<CustomWebHeader> {
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
    _loadCartItemCount(); // load cart count on init
  }

  Future<void> _loadCartItemCount() async {
    final ids = await SharedPreferencesHelper.getAllProductIds();
    setState(() {
      _cartItemCount = ids.length;
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
    return Stack(
      children: [
        // Main header content
        Container(
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
                    children: [
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          if (showSearchField)
                            Container(
                              margin: const EdgeInsets.only(right: 30),
                              width: 200,
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Colors.black26,
                                  ),
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                autofocus: true,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'SEARCH',
                                  hintStyle: TextStyle(letterSpacing: 1),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          _buildIcon(
                            showSearchField
                                ? 'assets/icons/closeIcon.svg'
                                : 'assets/header/IconSearch.svg',
                            18,
                            18,
                            onTap: () {
                              setState(() {
                                if (showSearchField) {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                } else {
                                  _searchFocusNode.requestFocus();
                                }
                                showSearchField = !showSearchField;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      _buildIcon('assets/header/IconWishlist.svg', 18, 15),
                      const SizedBox(width: 32),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildIcon(
                            'assets/header/IconProfile.svg',
                            18,
                            16,
                            onTap: () {
                              setState(() {
                                showProfileDropdown = !showProfileDropdown;
                              });
                            },
                          ),
                          Positioned(
                            top: 28,
                            right: -20,
                            child: Visibility(
                              visible: showProfileDropdown,
                              child: Container(
                                width: 180,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: BarlowText(
                                        text: 'LOG IN / SIGN UP',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        lineHeight: 1.0, // Line height of 100%
                                        letterSpacing:
                                            0.64, // 4% of 16px = 0.64
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: const Divider(
                                        color: Color(0xFF3E5B84),
                                      ),
                                    ),
                                    _dropdownItem('My Account'),
                                    _dropdownItem('My Orders'),
                                    _dropdownItem('Wishlist'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      _buildIcon(
                        'assets/header/IconCart.svg',
                        20,
                        19,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return CartPanelOverlay(
                                productId: _cartProductId ?? 0,
                              );
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
            right: 63,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
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

        // Outside click handler - now positioned above everything else
        if (showSearchField || showProfileDropdown)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  showSearchField = false;
                  showProfileDropdown = false;
                  if (_searchFocusNode.hasFocus) {
                    _searchFocusNode.unfocus();
                  }
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _dropdownItem(String text) {
    return InkWell(
      onTap: () {
        // Handle each option tap
        print('$text tapped');
        setState(() {
          showProfileDropdown = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: BarlowText(
          text: text,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          lineHeight: 1.0, // 100% line height
          letterSpacing: 0.64, // 4% of 16px = 0.64
          color: Color(0xFF3E5B84),
        ),
      ),
    );
  }

  Widget _buildIcon(
    String assetPath,
    double width,
    double height, {
    VoidCallback? onTap,
  }) {
    _isHovered.putIfAbsent(assetPath, () => false);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered[assetPath] = true),
      onExit: (_) => setState(() => _isHovered[assetPath] = false),
      child: GestureDetector(
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
