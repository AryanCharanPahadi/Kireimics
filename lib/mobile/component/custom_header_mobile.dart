import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/custom_text.dart';
import '../../component/cart_loader.dart';
import '../../component/routes.dart';
import '../../component/shared_preferences.dart';
import 'drawer.dart';

class CustomHeaderMobile extends StatefulWidget {
  const CustomHeaderMobile({super.key});

  @override
  State<CustomHeaderMobile> createState() => _CustomHeaderMobileState();
}

class _CustomHeaderMobileState extends State<CustomHeaderMobile> {
  @override
  void initState() {
    super.initState();

    _loadCartItemCount(); // load cart count on init
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
                  icon: Icon(Icons.menu, size: 30, color: Color(0xFF3E5B84)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DrawerMobile()),
                    );
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
                    'assets/header/IconCart.svg', // Ensure the correct path
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

class Column1 extends StatelessWidget {
  final Function(String) onNavItemSelected;

  const Column1({super.key, required this.onNavItemSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BarlowText(
                          route: AppRoutes.home,
                          onTap: () => onNavItemSelected(AppRoutes.home),

                          text: "HOME",
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: Color(0xFF3E5B84),
                          activeBackgroundColor: Color(0xFFb9d6ff),
                          enableBackgroundForActiveRoute: true,
                        ),
                        const SizedBox(width: 12),
                        BarlowText(
                          onTap: () => onNavItemSelected(AppRoutes.catalog),
                          route: AppRoutes.catalog,
                          text: "CATALOG",
                          fontWeight: FontWeight.w600,
                          enableBackgroundForActiveRoute: true,
                          fontSize: 18,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: Color(0xFF3E5B84),
                          activeBackgroundColor: Color(0xFFb9d6ff),
                        ),
                        const SizedBox(width: 12),

                        BarlowText(
                          route: AppRoutes.sale,
                          onTap: () => onNavItemSelected(AppRoutes.sale),
                          text: "SALE",
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: Color(0xFFf46856),
                          activeBackgroundColor: Color(0xFFfde1dd),
                          enableBackgroundForActiveRoute: true,
                        ),
                        const SizedBox(width: 12),
                        BarlowText(
                          onTap: () => onNavItemSelected(AppRoutes.about),
                          route: AppRoutes.about,
                          text: "ABOUT",
                          fontWeight: FontWeight.w600,
                          enableBackgroundForActiveRoute: true,
                          fontSize: 18,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: Color(0xFF3E5B84),
                          activeBackgroundColor: Color(0xFFb9d6ff),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Color(0xFF3E5B84)),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'SEARCH',
                            hintStyle: TextStyle(
                              fontSize:16,
                              fontFamily: GoogleFonts.barlow().fontFamily,
                              color: Color(0xFF414141),
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.search, color: Color(0xFF3E5B84), size: 20),
                    ],
                  ),
                  Divider(color: Color(0xFF414141)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
