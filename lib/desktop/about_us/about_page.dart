import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/above_footer/above_footer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/text_fonts/custom_text.dart';
import '../../web/about_us/about_us_controller.dart';

class AboutPageDesktop extends StatefulWidget {
  const AboutPageDesktop({super.key});

  @override
  State<AboutPageDesktop> createState() => _AboutPageDesktopState();
}

class _AboutPageDesktopState extends State<AboutPageDesktop> {
  @override
  Widget build(BuildContext context) {
    final AboutUsController aboutUsController = Get.put(AboutUsController());

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final leftPadding = 389.0; // ~389px if screenWidth is ~1556
    final rightTextPadding = screenWidth * 0.2; // ~445px
    final textRightPadding = screenWidth * 0.3;
    final containerWidth = screenWidth - leftPadding;
    final imageMaxHeight = screenHeight * 0.5; // Adjust as needed
    final placeholderHeight = screenHeight * 0.8;
    final textBlockWidth = screenWidth * 0.37; // ~574px

    return Obx(
      () =>
          aboutUsController.isLoading.value
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
                            padding: EdgeInsets.only(
                              left: leftPadding,
                              top: screenHeight * 0.04,
                            ),
                            child: Container(
                              width: containerWidth - 266,
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
                                padding: EdgeInsets.only(
                                  top: screenHeight * 0.05,
                                  right: rightTextPadding,
                                  left: screenWidth * 0.03,
                                  bottom: screenHeight * 0.05,
                                ),
                                child: Text(
                                  aboutUsController
                                          .profileData
                                          .value!['banner_text']
                                          ?.toString() ??
                                      'N/A',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.barlow().fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                    height: 1.5,
                                    letterSpacing: 0.72,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: placeholderHeight),
                        ],
                      ),
                      Positioned(
                        top: screenHeight * 0.12,
                        right: 98,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: imageMaxHeight,
                          ),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: _buildProfileImage(
                              aboutUsController.profileData.value!,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.3,
                        left: leftPadding,
                        right: textRightPadding,
                        child: SizedBox(
                          width: textBlockWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                aboutUsController
                                        .profileData
                                        .value!['heading_1']
                                        ?.toString() ??
                                    'N/A',
                                style: TextStyle(
                                  fontFamily: 'Cralika',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 32,
                                  height: 1.125,
                                  letterSpacing: 1.28,
                                  color: const Color(0xFF414141),
                                ),
                              ),
                              SizedBox(height: 14),
                              Text(
                                aboutUsController
                                        .profileData
                                        .value!['heading_1_content']
                                        ?.toString() ??
                                    'N/A',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.barlow().fontFamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  height: 1.5,
                                  letterSpacing: 0.0,
                                  color: const Color(0xFF414141),
                                ),
                              ),
                              SizedBox(height: 44),
                              Row(
                                children: _buildSocialLinks(
                                  aboutUsController
                                          .profileData
                                          .value!['social_media'] ??
                                      {},
                                ),
                              ),
                              SizedBox(height: 44),
                              Text(
                                aboutUsController
                                        .profileData
                                        .value!['heading_2']
                                        ?.toString() ??
                                    'N/A',
                                style: TextStyle(
                                  fontFamily: "Cralika",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 32,
                                  height: 1.7,
                                  letterSpacing: 0.96,
                                  color: const Color(0xFF414141),
                                ),
                              ),
                              SizedBox(height: 14),
                              Text(
                                aboutUsController
                                        .profileData
                                        .value!['heading_2_content']
                                        ?.toString() ??
                                    'N/A',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.barlow().fontFamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  height: 1.5,
                                  letterSpacing: 0.0,
                                  color: const Color(0xFF414141),
                                ),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 117),
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

  List<Widget> _buildSocialLinks(dynamic socialMedia) {
    Map<String, dynamic> socialLinks = {};

    // Handle different types of socialMedia
    if (socialMedia is String) {
      try {
        socialLinks = jsonDecode(socialMedia) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding social_media: $e');
      }
    } else if (socialMedia is Map<String, dynamic>) {
      socialLinks = socialMedia;
    } else {
      print('Unexpected social_media type: ${socialMedia.runtimeType}');
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
