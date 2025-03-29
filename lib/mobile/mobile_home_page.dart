import 'package:flutter/material.dart';

import 'component/custom_header_mobile.dart';
import 'component/scrolling_header.dart';

class LandingPageMobile extends StatefulWidget {
  const LandingPageMobile({super.key});

  @override
  State<LandingPageMobile> createState() => _LandingPageMobileState();
}

class _LandingPageMobileState extends State<LandingPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              children: [
                const ScrollingHeaderMobile(),
                CustomHeaderMobile(),
                Column1(),

                // Space for header when visible
              ],
            ),
          ],
        ),
      ),
    );
  }
}
