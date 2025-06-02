// lib/screens/policy/ShippingPolicy.dart

import 'package:flutter/material.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import 'package:kireimics/web_desktop_common/privacy_policy/privacy_policy_modal.dart';
import '../../component/text_fonts/custom_text.dart';

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
      return const Center(child: CircularProgressIndicator());
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
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    section.content.length,
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BarlowText(
                        text: section.content[i],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
        ),
      ),
    );
  }
}
