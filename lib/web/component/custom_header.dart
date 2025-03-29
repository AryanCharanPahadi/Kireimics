import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomWebHeader extends StatelessWidget {
  const CustomWebHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 99,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Container(
          color: Colors.yellow,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),

                child: Container(
                  color: Colors.red,
                  height: 51.49,
                  width: 211,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Container(
                      color: Colors.grey,

                      child: Image.asset(
                        'assets/fullLogoNew.png',
                        height: 31,
                        width: 191,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Container(
                  color: Colors.red,

                  width: 192,
                  height: 24.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          'assets/IconSearch.svg', // Ensure the correct path
                          width: 18,
                          height: 18,
                        ),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          'assets/IconWishlist.svg', // Ensure the correct path
                          width: 18,
                          height: 15,
                        ),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          'assets/IconProfile.svg', // Ensure the correct path
                          width: 18,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          'assets/IconCart.svg', // Ensure the correct path
                          width: 20,
                          height: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
