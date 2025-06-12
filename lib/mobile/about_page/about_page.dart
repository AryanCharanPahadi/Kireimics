import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/text_fonts/custom_text.dart';
import '../../component/utilities/url_launcher.dart';
import '../../web/about_us/about_us_controller.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final AboutUsController aboutUsController = Get.put(AboutUsController());

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
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      // Background container (first container)
                      Column(
                        children: [
                          Container(
                            height: 243,
                            width: MediaQuery.of(context).size.width,
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
                                left: 24,
                                right: 24,
                                top: 24,
                                bottom: 99,
                              ),
                              child: Container(
                                height: 120,
                                width: 342,
                                child: BarlowText(
                                  text:
                                      aboutUsController
                                          .profileData
                                          .value!['banner_text']
                                          ?.toString() ??
                                      'N/A',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  lineHeight: 30 / 14,
                                  letterSpacing: 0.56,
                                  color: Colors.white,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                          // This empty container pushes the image up in the Stack
                          Container(
                            height:
                                377 -
                                100, // Adjust this value to control overlap amount
                          ),
                        ],
                      ),

                      // Image container positioned to overlap
                      Positioned(
                        top: 171,
                        left: 24,
                        right: 24,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 377, // Maximum height
                          ),
                          child: AspectRatio(
                            aspectRatio:
                                3 /
                                4, // Adjust this to match your image's aspect ratio
                            child: _buildProfileImage(
                              aboutUsController.profileData.value!,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22, right: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        CralikaFont(
                          text:
                              aboutUsController.profileData.value!['heading_1']
                                  ?.toString() ??
                              'N/A',
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          lineHeight:
                              36 / 24, // Equivalent to line-height: 36px
                          letterSpacing: 4, // Use a valid unit (e.g., pixels)
                          color: Color(0xFF414141),
                        ),
                        SizedBox(height: 15),

                        Container(
                          child: BarlowText(
                            text:
                                aboutUsController
                                    .profileData
                                    .value!['heading_1_content']
                                    ?.toString() ??
                                'N/A',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            lineHeight: 1.2, // Equivalent to 100% line-height
                            letterSpacing: 0.0, // No extra spacing
                            color: Color(0xFF414141),
                          ),
                        ),
                        SizedBox(height: 44),

                        Row(
                          children: _buildSocialLinks(
                            aboutUsController.profileData.value!['social_media']
                                    ?.toString() ??
                                '{}',
                          ),
                        ),
                        SizedBox(height: 44),

                        Container(
                          child: CralikaFont(
                            text:
                                aboutUsController
                                    .profileData
                                    .value!['heading_2']
                                    ?.toString() ??
                                'N/A',
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            lineHeight:
                                36 / 24, // Equivalent to line-height: 36px
                            letterSpacing: 4, // Use a valid unit (e.g., pixels)
                            color: Color(0xFF414141),
                          ),
                        ),
                        SizedBox(height: 14),

                        Container(
                          child: BarlowText(
                            text:
                                aboutUsController
                                    .profileData
                                    .value!['heading_2_content']
                                    ?.toString() ??
                                'N/A',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            lineHeight: 1.2, // Equivalent to 100% line-height
                            letterSpacing: 0.0, // No extra spacing
                            color: Color(0xFF414141),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
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

  List<Widget> _buildSocialLinks(String socialJson) {
    try {
      final Map<String, dynamic> socialLinks = jsonDecode(socialJson);
      final entries = socialLinks.entries.toList();

      return List<Widget>.generate(entries.length, (index) {
        final entry = entries[index];
        final isLast = index == entries.length - 1;

        String value = entry.value;
        final keyLower = entry.key.toLowerCase();

        // Prefix for email or phone
        if (keyLower.contains('email') && !value.startsWith('mailto:')) {
          value = 'mailto:$value';
        } else if (keyLower.contains('phone') || keyLower.contains('tel')) {
          if (!value.startsWith('tel:')) {
            value = 'tel:$value';
          }
        }

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => UrlLauncherHelper.launchURL(context, value),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BarlowText(
                  text: entry.key,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF30578E),
                  enableUnderlineForActiveRoute: true,
                  decorationColor: Color(0xFF30578E),
                  hoverTextColor: const Color(0xFF2876E4),
                ),
                if (!isLast) ...[
                  SizedBox(width: 14),
                  BarlowText(
                    text: '/',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF30578E),
                  ),
                ],
              ],
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint("Error parsing social links: $e");
      return []; // Return empty list if parsing fails
    }
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
