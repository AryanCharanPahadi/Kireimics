import 'package:flutter/material.dart';
import 'package:kireimics/mobile/component/aquacollection_card.dart';

import '../component/gridview.dart';
import '../component/let_connect.dart';

class HomePageMobile extends StatelessWidget {
  const HomePageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AquaCollectionCard(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Divider(color: Color(0xFF3E5B84)),
        ),
        Gridview(),
        LetConnect(),
      ],
    );
  }
}
