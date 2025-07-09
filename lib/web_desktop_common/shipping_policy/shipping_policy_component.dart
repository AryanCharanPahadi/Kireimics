// lib/screens/policy/ShippingPolicy.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/title_service.dart';
import '../component/rotating_svg_loader.dart';
import 'ShippingPolicyModal.dart'; // <-- Import API class

class ShippingPolicy extends StatefulWidget {
  const ShippingPolicy({super.key});

  @override
  State<ShippingPolicy> createState() => _ShippingPolicyState();
}

class _ShippingPolicyState extends State<ShippingPolicy> {
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
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 44),
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
    final RegExp linkRegex = RegExp(
      r'<a\s*(.*?)<\/a>',
    ); // Matches <a something</a>
    final matches = linkRegex.allMatches(text);

    if (matches.isEmpty) {
      return BarlowText(text: text, fontSize: 16, fontWeight: FontWeight.w400);
    }

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      final linkText = match.group(1)!.trim();

      // Add plain text before the <a> tag
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: Colors.black),
          ),
        );
      }

      // Add link text
      spans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(color: Color(0xFF30578E)),
          recognizer:
              TapGestureRecognizer()
                ..onTap = () async {
                  final uri =
                      linkText.contains('@')
                          ? Uri.parse('mailto:$linkText')
                          : Uri.parse(
                            linkText.startsWith('http')
                                ? linkText
                                : 'https://$linkText',
                          );

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add any text after the last <a> tag
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
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}
