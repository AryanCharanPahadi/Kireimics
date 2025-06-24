import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../component/shared_preferences/shared_preferences.dart';

class ProductBadgesRow extends StatelessWidget {
  final bool isOutOfStock;
  final bool isMobile;
  final int? quantity;
  final dynamic product;
  final Function(String)? onWishlistChanged;
  final Function(int, bool)? toggleWishlistState;
  final int index;

  const ProductBadgesRow({
    super.key,
    required this.isOutOfStock,
    required this.isMobile,
    this.quantity,
    required this.product,
    this.onWishlistChanged,
    this.toggleWishlistState,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutOfStock) {
      // Only show out-of-stock image and wishlist icon
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              "assets/home_page/outofstock.svg",
              height: 24,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FutureBuilder<bool>(
              future: SharedPreferencesHelper.isInWishlist(
                product.id.toString(),
              ),
              builder: (context, snapshot) {
                final isInWishlist = snapshot.data ?? false;

                return GestureDetector(
                  onTap: () async {
                    if (isInWishlist) {
                      await SharedPreferencesHelper.removeFromWishlist(
                        product.id.toString(),
                      );
                      onWishlistChanged?.call('Product Removed From Wishlist');
                    } else {
                      await SharedPreferencesHelper.addToWishlist(
                        product.id.toString(),
                      );
                      onWishlistChanged?.call('Product Added To Wishlist');
                    }
                    // Trigger UI update
                    // Since this is a StatelessWidget, we rely on the parent to handle state changes
                    // The setState call is removed, and we assume the parent will handle it
                  },
                  child: SvgPicture.asset(
                    isInWishlist
                        ? 'assets/home_page/IconWishlist.svg'
                        : 'assets/home_page/IconWishlistEmpty.svg',
                    width: isMobile ? 20 : 24,
                    height: isMobile ? 18 : 20,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// LEFT SIDE — badges tightly stacked
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // First badge (maker_choice)
            if (product.isMakerChoice == 1)
              Padding(
                padding: const EdgeInsets.only(
                  top: 2,
                ), // manual top offset to align
                child: SvgPicture.asset(
                  "assets/home_page/maker_choice.svg",
                  height: 40,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            if (product.isMakerChoice == 1 && product.discount != 0)
              const SizedBox(height: 5), // <-- This adds the 5px gap between badges

            if (product.discount != 0)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 32,
                width: 80,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF46856),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(79),
                    ),
                  ),
                  child: Text(
                    "${product.discount}% OFF",
                    style: TextStyle(
                      fontFamily: GoogleFonts.barlow().fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.65,
                    ),
                  ),
                ),
              ),
          ],
        ),

        /// RIGHT SIDE — manually aligned to match badge
        Padding(
          padding: const EdgeInsets.only(top: 7), // match left badge padding
          child: FutureBuilder<bool>(
            future: SharedPreferencesHelper.isInWishlist(product.id.toString()),
            builder: (context, snapshot) {
              final isInWishlist = snapshot.data ?? false;
              return GestureDetector(
                onTap: () async {
                  if (isInWishlist) {
                    await SharedPreferencesHelper.removeFromWishlist(
                      product.id.toString(),
                    );
                    onWishlistChanged?.call('Product Removed From Wishlist');
                  } else {
                    await SharedPreferencesHelper.addToWishlist(
                      product.id.toString(),
                    );
                    onWishlistChanged?.call('Product Added To Wishlist');
                  }
                },
                child: SvgPicture.asset(
                  isInWishlist
                      ? 'assets/home_page/IconWishlist.svg'
                      : 'assets/home_page/IconWishlistEmpty.svg',
                  width: isMobile ? 20 : 24,
                  height: isMobile ? 18 : 20,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
