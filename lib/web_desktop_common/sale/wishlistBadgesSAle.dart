import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kireimics/web_desktop_common/sale/sale_modal.dart';

import '../../component/product_details/product_details_modal.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';

class WishlistBadgeRowSale extends StatelessWidget {
  final SaleModal product;
  final bool isOutOfStock;
  final int? quantity;
  final Function(String)? onWishlistChanged;
  final double paddingVertical;
  final bool hideWishlistIcon; // New parameter to hide wishlist icon

  const WishlistBadgeRowSale({
    super.key,
    required this.product,
    required this.isOutOfStock,
    required this.quantity,
    this.onWishlistChanged,
    required this.paddingVertical,
    this.hideWishlistIcon = false, // Default to false (show icon)
  });

  @override
  Widget build(BuildContext context) {
    if (isOutOfStock) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              "assets/home_page/outofstock.svg",
              height: 25,
              width: 25,
            ),
          ),
          if (!hideWishlistIcon) // Conditionally show wishlist icon
            FutureBuilder<bool>(
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
                  },
                  child: SvgPicture.asset(
                    isInWishlist
                        ? 'assets/home_page/IconWishlist.svg'
                        : 'assets/home_page/IconWishlistEmpty.svg',
                    width: 23,
                    height: 20,
                  ),
                );
              },
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            final List<Widget> badges = [];

            if (product.isMakerChoice == 1) {
              badges.add(
                SvgPicture.asset(
                  "assets/home_page/maker_choice.svg",
                  height: 50,
                ),
              );
            }

            // if (quantity != null && quantity! <= 2) {
            //   if (badges.isNotEmpty) badges.add(const SizedBox(height: 10));
            //   badges.add(
            //     SvgPicture.asset(
            //       "assets/home_page/fewPiecesLeft.svg",
            //     ),
            //   );
            // }

            if (product.discount != 0) {
              if (badges.isNotEmpty) badges.add(const SizedBox(height: 10));
              badges.add(
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 7.5,
                      horizontal: 14,
                    ),
                    backgroundColor: const Color(0xFFF46856),
                    disabledBackgroundColor: const Color(0xFFF46856),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    side: BorderSide.none,
                  ),
                  child: BarlowText(
                    text: "${product.discount}% OFF",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    lineHeight: 1.0, // 100% of font size
                    letterSpacing: 0.56, // 4% of 14px = 0.56
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: badges,
            );
          },
        ),
        const Spacer(),
        if (!hideWishlistIcon) // Conditionally show wishlist icon
          FutureBuilder<bool>(
            future: SharedPreferencesHelper.isInWishlist(product.id.toString()),
            builder: (context, snapshot) {
              final isInWishlist = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: GestureDetector(
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
                    width: 23,
                    height: 20,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
