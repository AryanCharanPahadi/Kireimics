import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/api_helper/api_helper.dart' show ApiHelper;
import '../../component/text_fonts/custom_text.dart';
import '../../component/title_service.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../web_desktop_common/shipping_policy/ShippingPolicyModal.dart';

class ShippingPolicyMobile extends StatefulWidget {
  const ShippingPolicyMobile({super.key});

  @override
  State<ShippingPolicyMobile> createState() => _ShippingPolicyMobileState();
}

class _ShippingPolicyMobileState extends State<ShippingPolicyMobile> {
  ShippingPolicyModel? _policyModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    TitleService.setTitle("Kireimics | Shipping Policy");

    loadShippingPolicy();
  }

  Future<void> loadShippingPolicy() async {
    final model = await ApiHelper.fetchShippingPolicy();
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

    final policySections = _policyModel!.shippingPolicy;

    return Container(
      width: MediaQuery.of(context).size.width,
      // color: Colors.red,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 22, top: 32),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,

              child: ListView.builder(
                itemCount: policySections.length + 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CralikaFont(
                          text: "Shipping Policy",
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),

                        SizedBox(height: 10),
                      ],
                    );
                  }

                  final section = policySections[index - 1];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CralikaFont(
                        text: section.title,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.88, // 4% of 22
                        lineHeight: 27 / 22, // 1.227
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
          ),
        ],
      ),
    );
  }

  Widget buildContentWithLinks(String text) {
    final RegExp linkRegex = RegExp(
      r'<a\s*(.*?)<\/a>',
    ); // Matches <a something</a>
    final matches = linkRegex.allMatches(text);

    if (matches.isEmpty) {
      return BarlowText(text: text, fontWeight: FontWeight.w400, fontSize: 14);
    }

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      final fullMatch = match.group(0)!;
      final linkText = match.group(1)!.trim();

      // Add plain text before the link
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: Colors.black),
          ),
        );
      }

      // Add the link
      spans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(color: Color(0xFF30578E)),
          recognizer:
              TapGestureRecognizer()
                ..onTap = () async {
                  if (linkText.contains('@')) {
                    final uri = Uri.parse('mailto:$linkText');
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri);
                    }
                  } else {
                    final uri = Uri.parse(
                      linkText.startsWith('http')
                          ? linkText
                          : 'https://$linkText',
                    );
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri);
                    }
                  }
                },
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add any remaining text after the last match
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: const TextStyle(color: Colors.black),
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }
}
