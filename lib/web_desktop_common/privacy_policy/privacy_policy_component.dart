// lib/screens/policy/ShippingPolicy.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/web_desktop_common/privacy_policy/privacy_policy_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/title_service.dart';
import '../component/rotating_svg_loader.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  PrivacyPolicyModal? _policyModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    TitleService.setTitle("Kireimics | Privacy Policy");

    loadPrivacyPolicy();
  }

  Future<void> loadPrivacyPolicy() async {
    final model = await ApiHelper.fetchPrivacyPolicy();
    setState(() {
      _policyModel = model;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: RotatingSvgLoader(assetPath: 'assets/footer/footerbg.svg'),
      );
    }

    if (_policyModel == null) {
      return const Center(child: Text('Failed to load shipping policy'));
    }

    final policyText = _policyModel!.privacyPolicy;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding:
            MediaQuery.of(context).size.width > 1400
                ? EdgeInsets.only(
                  left: 389,
                  right: MediaQuery.of(context).size.width * 0.15,
                  top: 24,
                )
                : EdgeInsets.only(
                  left: 292,
                  right: MediaQuery.of(context).size.width * 0.07,
                  top: 24,
                ),
        child: ListView.builder(
          itemCount: policyText.length + 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CralikaFont(
                        text: "Privacy Policy",
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                      ),
                      BarlowText(
                        text: "Effective Date: ${_policyModel!.updatedAt}",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 44), // 👈 Gap between Row and content
                ],
              );
            }

            // ✅ This runs only for index > 0
            final section = policyText[index - 1];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CralikaFont(
                  text: section.title,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  section.content.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildContentWithLinks(section.content[i]),

                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget buildContentWithLinks(String text) {
    final RegExp linkRegex = RegExp(r'<a\s*(.*?)<\/a>'); // matches <a something</a>

    final matches = linkRegex.allMatches(text);
    if (matches.isEmpty) {
      return BarlowText(
        text: text,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );
    }

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      final fullMatch = match.group(0)!;
      final linkText = match.group(1)!.trim();

      // Add preceding normal text
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }

      spans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(color: Color(0xFF30578E)),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (linkText.contains('@')) {
                launchUrl(Uri.parse('mailto:$linkText'));
              } else {
                launchUrl(Uri.parse(linkText.startsWith('http') ? linkText : 'https://$linkText'));
              }
            },
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add trailing text after last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
    );
  }

}
