import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kireimics/component/text_fonts/custom_text.dart';

import '../../component/above_footer/above_footer.dart';
import '../../component/utilities/url_launcher.dart';
import 'contact_us_controller.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
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
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 292, top: 35),
              child: Container(
                width: MediaQuery.of(context).size.width - 292,
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
                  padding: const EdgeInsets.only(
                    top: 40,
                    left: 47,
                    bottom: 40,
                    right: 50,
                  ),
                  child: Text(
                    contactController.contactData!['band_text'] ??
                        "/Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful/",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: GoogleFonts.barlow().fontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      height: 1.5,
                      letterSpacing: 0.04 * 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 292, top: 35),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [CralikaFont(text: "Contact Us", fontSize: 28)],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 292,
                  right: MediaQuery.of(context).size.width * 0.07,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BarlowText(
                          text:
                              "Our address:\n${contactController.contactData!['address'].toString()}",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap:
                              () => UrlLauncherHelper.launchURL(
                                context,
                                "tel:${contactController.contactData!['phone'].toString()}",
                              ),
                          child: BarlowText(
                            text:
                                contactController.contactData!['phone']
                                    .toString(),
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap:
                              () => UrlLauncherHelper.launchURL(
                                context,
                                "mailto:${contactController.contactData!['email'].toString()}",
                              ),
                          child: BarlowText(
                            text:
                                contactController.contactData!['email']
                                    .toString(),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: _buildSocialLinks(
                            contactController.contactData!['social_media']
                                .toString(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 302,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customTextFormField(hintText: "YOUR NAME"),
                          const SizedBox(height: 10),
                          customTextFormField(hintText: "YOUR EMAIL"),
                          const SizedBox(height: 10),
                          customTextFormField(hintText: "MESSAGE"),
                          const SizedBox(height: 10),
                          customTextFormField(hintText: ""),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 292, top: 35),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [CralikaFont(text: "FAQ's", fontSize: 28)],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 292,
                  right: MediaQuery.of(context).size.width * 0.07,
                ),
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
                                  contactController.faqData[index]["question"]!,
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
          ],
        );
  }

  List<Widget> _buildSocialLinks(String socialJson) {
    try {
      final Map<String, dynamic> socialLinks = jsonDecode(socialJson);
      return socialLinks.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => UrlLauncherHelper.launchURL(context, entry.value),
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

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
  }) {
    return Stack(
      children: [
        // Hint text positioned on the left
        Positioned(
          left: 0,
          top: 16, // Adjust this value to align vertically
          child: Text(
            hintText,
            style: GoogleFonts.barlow(fontSize: 14, color: Color(0xFF414141)),
          ),
        ),
        // Text field with right-aligned input
        TextFormField(
          controller: controller,
          cursorColor: Colors.black,
          textAlign: TextAlign.right, // Align user input to the right
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: GoogleFonts.barlow().fontFamily,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(bottom: 5),
          ),
          style: TextStyle(
            color: Color(0xFF414141),
            fontFamily: GoogleFonts.barlow().fontFamily,
          ),
        ),
      ],
    );
  }
}
