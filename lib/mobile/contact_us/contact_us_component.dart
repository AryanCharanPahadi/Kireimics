import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/utilities/url_launcher.dart';
import '../../component/utilities/utility.dart';
import '../../web/contact_us/contact_us_controller.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';

class ContactUsComponent extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final Function(String)? onErrorWishlistChanged; // Callback to notify parent
  const ContactUsComponent({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });
  @override
  State<ContactUsComponent> createState() => _ContactUsComponentState();
}

class _ContactUsComponentState extends State<ContactUsComponent> {
  final ContactController contactController = ContactController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _anotherMessageController =
      TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final FocusNode _anotherMessageFocusNode = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _anotherMessageController.dispose();
    _messageFocusNode.dispose();
    _anotherMessageFocusNode.dispose();
    super.dispose();
  }

  bool isSubmitting = false; // New flag to track form submission

  Future<void> _submitForm() async {
    final String formattedDate = getFormattedDate();

    // Validation checks
    if (_nameController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter your name');
      return;
    }

    if (_emailController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter your email');
      return;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      widget.onErrorWishlistChanged?.call('Please enter a valid email');
      return;
    }

    if (_messageController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter a message');
      return;
    }

    setState(() {
      isSubmitting = true; // Show loader
    });

    try {
      final response = await ApiHelper.contactQuery(
        name: _nameController.text,
        email: _emailController.text,
        message: "${_messageController.text} ${_anotherMessageController.text}",
        createdAt: formattedDate,
      );

      if (response['error'] == true) {
        widget.onErrorWishlistChanged?.call(
          response['message'] ?? 'Submission failed',
        );
      } else {
        widget.onWishlistChanged?.call('Form submitted successfully!');

        // Clear fields
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        _anotherMessageController.clear();
      }
    } catch (e) {
      widget.onErrorWishlistChanged?.call(
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setState(() {
        isSubmitting = false; // Hide loader
      });
    }
  }

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
        ? const Center(
          child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
        )
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
                      contactController.contactData!['band_text'] ??
                          "/Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful/",
                      style: TextStyle(
                        fontFamily: GoogleFonts.barlow().fontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 30 / 14,
                        letterSpacing: 0.56,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 24, right: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CralikaFont(
                      text: "Contact Us",
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22, top: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customTextFormField(
                          hintText: "YOUR NAME",
                          controller: _nameController,
                        ),
                        const SizedBox(height: 24),
                        customTextFormField(
                          hintText: "YOUR EMAIL",
                          controller: _emailController,
                        ),
                        const SizedBox(height: 24),
                        customTextFormField(
                          hintText: "MESSAGE",
                          controller: _messageController,
                          isMessageField: true,
                          focusNode: _messageFocusNode,
                          nextFocusNode: _anotherMessageFocusNode,
                          nextController: _anotherMessageController,
                        ),
                        const SizedBox(height: 24),
                        customTextFormField(
                          hintText: "",
                          controller: _anotherMessageController,
                          focusNode: _anotherMessageFocusNode,
                          maxLength: 100,
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: isSubmitting ? null : _submitForm,

                          child:
                              isSubmitting
                                  ? Align(
                                    alignment: Alignment.bottomRight,

                                    child: RotatingSvgLoader(
                                      size: 20,
                                      assetPath: 'assets/footer/footerbg.svg',
                                    ),
                                  )
                                  : Align(
                                    alignment: Alignment.bottomRight,
                                    child: SvgPicture.asset(
                                      "assets/icons/submit_new2.svg",
                                      height: 19,
                                      width: 58,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // SizedBox(
              //   width: MediaQuery.of(context).size.width,
              //   child: Padding(
              //     padding: const EdgeInsets.only(left: 22, right: 22, top: 32),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         customTextFormField(hintText: "YOUR NAME"),
              //         const SizedBox(height: 10),
              //         customTextFormField(hintText: "YOUR EMAIL"),
              //         const SizedBox(height: 10),
              //         customTextFormField(hintText: "MESSAGE"),
              //         const SizedBox(height: 10),
              //         customTextFormField(hintText: ""),
              //         const SizedBox(height: 24),
              //         Align(
              //           alignment: Alignment.bottomRight,
              //           child: SvgPicture.asset(
              //             "assets/home_page/submit.svg",
              //             height: 19,
              //             width: 58,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, top: 35),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BarlowText(
                            text:
                                "Our address:\n${contactController.contactData!['address'].toString()}",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            softWrap: true,
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap:
                                () => UrlLauncherHelper.launchURL(
                                  context,
                                  "tel:+91${contactController.contactData!['phone'].toString()}",
                                ),
                            child: BarlowText(
                              text:
                                  "+91 ${contactController.contactData!['phone'].toString()}",

                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF30578E),
                              decorationColor: const Color(0xFF30578E),
                              enableHoverUnderline: true,
                              hoverTextColor: const Color(0xFF2876E4),
                              hoverDecorationColor: Color(0xFF2876E4),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF30578E),
                              decorationColor: const Color(0xFF30578E),
                              enableHoverUnderline: true,
                              hoverTextColor: const Color(0xFF2876E4),
                              hoverDecorationColor: Color(0xFF2876E4),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 46),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CralikaFont(
                      text: "FAQ's",
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
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
                                  BarlowText(
                                    text:
                                        contactController
                                            .faqData[index]["question"]
                                            .toString()!,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400,
                                    lineHeight: 1.0,
                                    letterSpacing: 0.0,
                                    color: Color(0xFF414141),

                                    softWrap: true,
                                  ),
                                  const SizedBox(height: 4.0),
                                  BarlowText(
                                    text:
                                        contactController
                                            .faqData[index]["answer"]
                                            .toString()!,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    lineHeight: 1.4,
                                    letterSpacing: 0.0,
                                    color: Color(0xFF636363),
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

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    TextEditingController? nextController,
    bool isMessageField = false,
    int? maxLength,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
    final int? effectiveMaxLength = isMessageField ? 25 : maxLength;
    String? trailingWord;

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 16,
              child: Text(
                hintText,
                style: GoogleFonts.barlow(
                  fontSize: 14,
                  color: const Color(0xFF414141),
                ),
              ),
            ),
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: Colors.black,
              textAlign: TextAlign.right,
              maxLength: effectiveMaxLength,
              onChanged: (value) {
                if (isMessageField && value.length == 25) {
                  final lastSpaceIndex = value.lastIndexOf(' ');

                  if (lastSpaceIndex != -1 &&
                      lastSpaceIndex < value.length - 1) {
                    final wordToMove = value.substring(lastSpaceIndex + 1);
                    final newText = value.substring(0, lastSpaceIndex);

                    controller?.text = newText;
                    controller?.selection = TextSelection.fromPosition(
                      TextPosition(offset: newText.length),
                    );

                    if (nextController != null) {
                      final nextText = nextController.text;
                      final updatedNextText =
                          nextText.isEmpty
                              ? wordToMove
                              : '$nextText $wordToMove';
                      nextController.text = updatedNextText;
                      nextController.selection = TextSelection.fromPosition(
                        TextPosition(offset: updatedNextText.length),
                      );
                    }

                    if (nextFocusNode != null) {
                      nextFocusNode.requestFocus();
                    }

                    trailingWord = wordToMove;
                  } else {
                    // No space found
                    nextFocusNode?.requestFocus();
                    trailingWord = null;
                  }
                  setState(() {});
                } else if (isMessageField) {
                  final parts = value.split(' ');
                  trailingWord = value.endsWith(' ') ? '' : parts.last;
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                counterText: '',
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
                color: const Color(0xFF414141),
                fontFamily: GoogleFonts.barlow().fontFamily,
              ),
            ),
          ],
        );
      },
    );
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
}
