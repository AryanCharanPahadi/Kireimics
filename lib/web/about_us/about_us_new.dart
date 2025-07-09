import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/component/above_footer/above_footer.dart';
import 'package:kireimics/web/about_us/about_us_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/title_service.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';

class AboutPageNew extends StatefulWidget {
  const AboutPageNew({super.key});

  @override
  State<AboutPageNew> createState() => _AboutPageNewState();
}

class _AboutPageNewState extends State<AboutPageNew> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TitleService.setTitle("Kireimics | About Me");
  }

  @override
  Widget build(BuildContext context) {
    // Ensure AboutUsController is initialized
    final AboutUsController aboutUsController = Get.put(AboutUsController());

    return Obx(
          () =>
      aboutUsController.isLoading.value
          ? const Center(
        child: RotatingSvgLoader(
          assetPath: 'assets/footer/footerbg.svg',
        ),
      )
          : aboutUsController.errorMessage.value.isNotEmpty
          ? Center(child: Text(aboutUsController.errorMessage.value))
          : aboutUsController.profileData.value == null
          ? const Center(child: Text('No Profile Data Found'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Inside Stack widget
          Stack(
            children: [
              // Background image container
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width > 1700
                      ? 395
                      : MediaQuery.of(context).size.width > 1400
                      ? 395
                      : 292,
                  top: 35,
                  right: MediaQuery.of(context).size.width > 1700 ? 266 : 0,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width > 1700
                      ? MediaQuery.of(context).size.width - (395 + 266)
                      : MediaQuery.of(context).size.width > 1400
                      ? MediaQuery.of(context).size.width - (395 + 0)
                      : MediaQuery.of(context).size.width - 292,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage("assets/home_page/background.png"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF238ca0).withOpacity(0.9),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 47,
                      bottom: 40,
                      right: 0, // remove internal right padding to avoid conflict
                    ),
                    child: BarlowText(
                      text: aboutUsController.profileData.value!['banner_text']?.toString() ?? 'N/A',
                      textAlign: TextAlign.left,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Profile image overlay
              Positioned(
                top: 50,
                right: 112,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.network(
                    aboutUsController.profileData.value!['profile_image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }



}
