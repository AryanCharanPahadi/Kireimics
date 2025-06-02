import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/component/above_footer/above_footer.dart';
import 'package:kireimics/web/about_us/about_us_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPageWeb extends StatelessWidget {
  const AboutPageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AboutUsController is initialized
    final AboutUsController aboutUsController = Get.put(AboutUsController());

    return Obx(
          () => aboutUsController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : aboutUsController.errorMessage.value.isNotEmpty
          ? Center(child: Text(aboutUsController.errorMessage.value))
          : aboutUsController.profileData.value == null
          ? const Center(child: Text('No Profile Data Found'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 292, top: 35),
                    child: Container(
                      width:
                      MediaQuery.of(context).size.width - 292,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage(
                            "assets/home_page/background.png",
                          ),
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
                          right: 445,
                          left: 47,
                          bottom: 40,
                        ),
                        child: Text(
                          aboutUsController
                              .profileData.value!['banner_text']
                              ?.toString() ??
                              'N/A',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily:
                            GoogleFonts.barlow().fontFamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            height: 1.5,
                            letterSpacing: 0.04 * 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 500),
                ],
              ),
              Positioned(
                top: 100,
                right: 112,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 377),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _buildProfileImage(
                        aboutUsController.profileData.value!),
                  ),
                ),
              ),
              Positioned(
                top: 250,
                left: 292,
                right: 466,
                child: SizedBox(
                  width: 574,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CralikaFont(
                        text: aboutUsController
                            .profileData.value!['heading_1']
                            ?.toString() ??
                            'N/A',
                        textAlign: TextAlign.left,
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        lineHeight: 36 / 32,
                        letterSpacing: 32 * 0.04,
                        color: const Color(0xFF414141),
                      ),
                      const SizedBox(height: 14),
                      BarlowText(
                        text: aboutUsController.profileData
                            .value!['heading_1_content']
                            ?.toString() ??
                            'N/A',
                        textAlign: TextAlign.left,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        lineHeight: 1.0,
                        letterSpacing: 0.0,
                        color: const Color(0xFF414141),
                      ),
                      const SizedBox(height: 44),
                      Row(
                        children: _buildSocialLinks(
                          aboutUsController
                              .profileData.value!['social_media']
                              ?.toString() ??
                              '{}',
                        ),
                      ),
                      const SizedBox(height: 44),
                      Text(
                        aboutUsController
                            .profileData.value!['heading_2']
                            ?.toString() ??
                            'N/A',
                        style: const TextStyle(
                          fontFamily: "Cralika",
                          fontWeight: FontWeight.w400,
                          fontSize: 32,
                          height: 1.7,
                          letterSpacing: 0.96,
                          color: Color(0xFF414141),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        aboutUsController
                            .profileData.value!['heading_2_content']
                            ?.toString() ??
                            'N/A',
                        style: TextStyle(
                          fontFamily:
                          GoogleFonts.barlow().fontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: const Color(0xFF414141),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const AboveFooter(),
        ],
      ),
    );
  }

  Widget _buildProfileImage(Map<String, dynamic> profile) {
    final profileImage = profile['profile_image'];
    print('Profile Image: $profileImage'); // Debug log

    if (profileImage is String && profileImage.isNotEmpty) {
      return Image.network(
        profileImage,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image));
        },
      );
    } else if (profileImage is List && profileImage.isNotEmpty) {
      return Image.network(
        profileImage[0],
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image));
        },
      );
    }
    return const Center(child: Text('No Image'));
  }

  List<Widget> _buildSocialLinks(String socialMediaJson) {
    Map<String, dynamic> socialLinks = {};
    try {
      socialLinks = jsonDecode(socialMediaJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding social_media: $e');
    }

    return socialLinks.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: InkWell(
          onTap: () => _launchURL(entry.value),
          child: BarlowText(
            text: entry.key,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3E5B84),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _launchURL(String url) async {
    if (!url.startsWith("http://") &&
        !url.startsWith("https://") &&
        !url.startsWith("mailto:") &&
        !url.startsWith("tel:")) {
      url = "https://$url";
    }

    try {
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}