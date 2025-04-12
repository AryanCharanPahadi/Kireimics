import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kireimics/component/custom_text.dart';
import '../../component/routes.dart';
import '../../component/shared_preferences.dart';
import '../cart/cart_panel.dart';

class CustomWebHeader extends StatefulWidget {
  final ValueChanged<bool>? onProfileDropdownChanged;

  const CustomWebHeader({super.key, this.onProfileDropdownChanged});

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
    _loadCartItemCount();
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
      clipBehavior: Clip.none,
      children: [
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
                    width: 180,
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
                              print("Search icon tapped");
                              setState(() {
                                if (showSearchField) {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                  showSearchField = false;
                                } else {
                                  _searchFocusNode.requestFocus();
                                  showSearchField = true;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {
                          context.go(AppRoutes.wishlist);
                        },

                        child: _buildIcon(
                          'assets/header/IconWishlist.svg',
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
                          'assets/header/IconProfile.svg',
                          18,
                          16,
                        ),
                      ),
                      const SizedBox(width: 32),
                      _buildIcon(
                        'assets/header/IconCart.svg',
                        20,
                        19,
                        onTap: () {
                          print("Cart icon tapped");
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
