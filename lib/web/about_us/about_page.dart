import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';
import 'package:kireimics/component/above_footer/above_footer.dart';
import 'package:kireimics/web/about_us/about_us_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../web_desktop_common/component/rotating_svg_loader.dart';

class AboutPageWeb extends StatelessWidget {
  const AboutPageWeb({super.key});

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
                  Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left:
                                  MediaQuery.of(context).size.width > 1700
                                      ? 395
                                      : MediaQuery.of(context).size.width > 1400
                                      ? 395
                                      : 292,
                              top: 35,
                              right:
                                  MediaQuery.of(context).size.width > 1700
                                      ? 266
                                      : 0,
                            ),
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width > 1700
                                      ? MediaQuery.of(context).size.width -
                                          (395 + 266)
                                      : MediaQuery.of(context).size.width > 1400
                                      ? MediaQuery.of(context).size.width -
                                          (395 + 0)
                                      : MediaQuery.of(context).size.width - 292,
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
                                  top: 40,
                                  right:
                                      MediaQuery.of(context).size.width > 1700
                                          ? 540
                                          : 445,
                                  left: 47,
                                  bottom: 40,
                                ),
                                child: BarlowText(
                                  text:
                                      aboutUsController
                                          .profileData
                                          .value!['banner_text']
                                          ?.toString() ??
                                      'N/A',
                                  textAlign: TextAlign.left,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,

                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(height: 500),
                        ],
                      ),
                      Positioned(
                        top: 100,
                        right:
                            MediaQuery.of(context).size.width > 1700
                                ? 364
                                : 112,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 377),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: _buildProfileImage(
                              aboutUsController.profileData.value!,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 250,
                        left:
                            MediaQuery.of(context).size.width > 1700
                                ? 395
                                : MediaQuery.of(context).size.width > 1400
                                ? 395
                                : 292,
                        right:
                            MediaQuery.of(context).size.width > 1700
                                ? 774
                                : MediaQuery.of(context).size.width > 1400
                                ? MediaQuery.of(context).size.width -
                                    (395 + 574)
                                : 466,
                        child: SizedBox(
                          width: 574,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CralikaFont(
                                text:
                                    aboutUsController
                                        .profileData
                                        .value!['heading_1']
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
                                text:
                                    aboutUsController
                                        .profileData
                                        .value!['heading_1_content']
                                        ?.toString() ??
                                    'N/A',
                                textAlign: TextAlign.left,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                lineHeight: 1.0,
                                letterSpacing: 0.0,
                                color: const Color(0xFF414141),
                              ),
                              const SizedBox(height: 44),
                              Row(
                                children: _buildSocialLinks(
                                  aboutUsController
                                          .profileData
                                          .value!['social_media']
                                          ?.toString() ??
                                      '{}',
                                ),
                              ),
                              const SizedBox(height: 44),
                              CralikaFont(
                                text:
                                    aboutUsController
                                        .profileData
                                        .value!['heading_2']
                                        ?.toString() ??
                                    'N/A',
                                fontWeight: FontWeight.w400,
                                fontSize: 32,
                                lineHeight: 1.7,
                                letterSpacing: 0.96,
                                color: Color(0xFF414141),
                              ),
                              const SizedBox(height: 14),
                              BarlowText(
                                text:
                                    aboutUsController
                                        .profileData
                                        .value!['heading_2_content']
                                        ?.toString() ??
                                    'N/A',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                lineHeight: 1.0,
                                letterSpacing: 0.0,
                                color: const Color(0xFF414141),
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

  List<Widget> _buildSocialLinks(String socialJson) {
    try {
      final Map<String, dynamic> socialLinks = jsonDecode(socialJson);
      final entries = socialLinks.entries.toList();

      return List<Widget>.generate(entries.length, (index) {
        final entry = entries[index];
        final isLast = index == entries.length - 1;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => _launchURL(entry.value),
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
      if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(url)) {
        url = "mailto:$url";
      } else if (RegExp(r'^\+?\d{7,15}$').hasMatch(url)) {
        url = "tel:$url";
      } else {
        url = "https://$url";
      }
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
