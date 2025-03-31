import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'drawer.dart';

class CustomHeaderMobile extends StatelessWidget {
  const CustomHeaderMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>DrawerMobile()));
              },
            ),

            Image.asset('assets/fullLogoNew.png', height: 24, width: 150),
            GestureDetector(
              onTap: () {},
              child: SvgPicture.asset(
                'assets/IconCart.svg', // Ensure the correct path
                width: 23,
                height: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Column1 extends StatelessWidget {
  const Column1({super.key});

  @override
  Widget build(BuildContext context) {
    final navTextStyle = TextStyle(
      fontFamily: GoogleFonts.barlow().fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.0,
      letterSpacing: 0.56,
      color: Color(0xFF3E5B84),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          SizedBox(
            // color: Colors.black,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Text("HOME", style: navTextStyle),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {},
                          child: Text("CATALOG", style: navTextStyle),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {},
                          child: Text("SALE", style: navTextStyle),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {},
                          child: Text("ABOUT", style: navTextStyle),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Color(0xFF3E5B84),),
                ],
              ),
            ),
          ),
          // SizedBox(height: 10),
          SizedBox(
            // color: Colors.black,
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
                              fontSize: 20,
                              fontFamily: GoogleFonts.barlow().fontFamily,
                              color:Color(0xFF414141)
                                
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.search, color:Color(0xFF3E5B84),size: 24,),
                    ],
                  ),
                  Divider(color: Color(0xFF414141),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
