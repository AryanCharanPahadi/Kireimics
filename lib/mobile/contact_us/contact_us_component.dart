import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/custom_text.dart';
import '../../web/contact_us/contact_us_controller.dart';

class ContactUsComponent extends StatefulWidget {
  const ContactUsComponent({super.key});

  @override
  State<ContactUsComponent> createState() => _ContactUsComponentState();
}

class _ContactUsComponentState extends State<ContactUsComponent> {
  final ContactController contactController = ContactController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await contactController.fetchContactDetails();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return contactController.isLoading
        ? const Center(child: CircularProgressIndicator())
        : contactController.contactData == null
        ? const Center(child: Text("Failed to load contact details."))
        : SizedBox(
          width: MediaQuery.of(context).size.width,
          // color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage("assets/home_page/background.png"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF2472e3).withOpacity(0.9),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    // height: 120,
                    width: 342,
                    child: Text(
                      "/Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful/",
                      style: TextStyle(
                        fontFamily: GoogleFonts.barlow().fontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 30 / 14,
                        letterSpacing: 0.56,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22, top: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      contactField("YOUR NAME"),
                      const SizedBox(height: 10),
                      contactField("YOUR EMAIL"),
                      const SizedBox(height: 10),
                      contactField("MESSAGE"),
                      const SizedBox(height: 10),
                      contactField(""),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SvgPicture.asset(
                          "assets/home_page/submit.svg",
                          height: 19,
                          width: 58,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 22, top: 24, right: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [CralikaFont(text: "Contact Us", fontSize: 24)],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, top: 32),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BarlowText(
                            text:
                                "Our address:\n${contactController.contactData!['address']}",
                            fontSize: 14,
                            softWrap: true,
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap:
                                () => _launchURL(
                                  "tel:${contactController.contactData!['phone']}",
                                ),
                            child: BarlowText(
                              text: contactController.contactData!['phone'],
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap:
                                () => _launchURL(
                                  "mailto:${contactController.contactData!['email']}",
                                ),
                            child: BarlowText(
                              text: contactController.contactData!['email'],
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: _buildSocialLinks(
                              contactController.contactData!['social'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 46),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [CralikaFont(text: "FAQ's", fontSize: 28)],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: contactController.faqData.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF000001).withOpacity(0.2),
                            width: 1,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFDDEAFF),
                              spreadRadius: 0,
                              blurRadius: 6,
                              offset: Offset(
                                6,
                                6,
                              ), // Right and Bottom shadow only
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFDDEAFF),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Color(0xFFDDEAFF),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.help_outline,
                                color: Color(0xFF003366),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contactController
                                        .faqData[index]["question"]!,
                                    style: GoogleFonts.barlow(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w400,
                                      height: 1.0,
                                      letterSpacing: 0.0,
                                      color: Color(0xFF414141),
                                    ),
                                    softWrap: true,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    contactController.faqData[index]["answer"]!,
                                    style: GoogleFonts.barlow(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                      letterSpacing: 0.0,
                                      color: Color(0xFF636363),
                                    ),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
  }

  Widget contactField(String hintText) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: GoogleFonts.barlow().fontFamily,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 5),
        ),
      ),
    );
  }

  List<Widget> _buildSocialLinks(String socialJson) {
    try {
      final Map<String, dynamic> socialLinks = jsonDecode(socialJson);
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
