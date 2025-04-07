import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/custom_text.dart';

import '../../component/categories/categories_controller.dart';

class CollectionWeb extends StatefulWidget {
  const CollectionWeb({super.key});

  @override
  State<CollectionWeb> createState() => _CollectionWebState();
}

class _CollectionWebState extends State<CollectionWeb> {
  final CatalogController categoriesController = Get.put(CatalogController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 453),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(
                        "assets/home_page/background.png",
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFFffb853).withOpacity(0.9),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 41,
                      right: 90,
                      left: 46,
                      bottom: 41,
                    ),
                    child: BarlowText(
                      text:
                          "/A wide range of handmade pottery that's designed to be fun & functional. Each piece is unique, original and perfect for adding charm to any space/",
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 292),
                child: CralikaFont(
                  text: "3 Collections",
                  fontWeight: FontWeight.w400,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 292,
                  right: MediaQuery.of(context).size.width * 0.07,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      if (categoriesController.isLoading.value) {
                        return const CircularProgressIndicator();
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:
                            categoriesController.categories.map((category) {
                              final name = category['name'] as String;
                              final id = category['id'] as int;

                              return Padding(
                                padding: const EdgeInsets.only(right: 32),
                                child: BarlowText(
                                  text: name,
                                  color: const Color(0xFF3E5B84),
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.012,
                                  lineHeight: 1.0,
                                  letterSpacing: 0.04 * 16,

                                  onTap: () {
                                    print('Tapped: $name (ID: $id)');
                                  },
                                ),
                              );
                            }).toList(),
                      );
                    }),

                    Row(
                      children: [
                        BarlowText(
                          text: "Sort / New",
                          color: const Color(0xFF3E5B84),
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.012,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.07,
                left: 292,
                top: 30,
                bottom: 40,
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 30, // Reduced from 23 to make it tighter
                  childAspectRatio: 2.3, // Adjusted aspect ratio
                ),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    width: 900,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/home_page/aquaCollection.png',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            width: 282, // Fixed width instead of percentage
                            padding: const EdgeInsets.all(12),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Aqua Collection',
                                  style: TextStyle(
                                    fontFamily: 'Cralika',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    height: 36 / 20,
                                    letterSpacing: 0.04 * 20,
                                    color: Color(0xFF0D2C54),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '4 Pieces',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                    color: const Color(0xFF3E5B84),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'VIEW',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    height: 1.0,
                                    letterSpacing: 0.04 * 16,
                                    color: const Color(0xFF0D2C54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
