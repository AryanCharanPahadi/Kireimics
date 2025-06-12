import 'package:flutter/material.dart';
import 'package:kireimics/web_desktop_common/privacy_policy/privacy_policy_modal.dart';

import '../../component/api_helper/api_helper.dart';
import '../../component/text_fonts/custom_text.dart';

class PrivacyPolicyMobile extends StatefulWidget {
  const PrivacyPolicyMobile({super.key});

  @override
  State<PrivacyPolicyMobile> createState() => _PrivacyPolicyMobileState();
}

class _PrivacyPolicyMobileState extends State<PrivacyPolicyMobile> {
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

    final policySections = _policyModel!.privacyPolicy;

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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CralikaFont(text: "Privacy Policy",fontSize: 24,fontWeight: FontWeight.w400,),
                            BarlowText(
                              text:
                                  "Effective Date: ${_policyModel!.updatedAt}",
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 44,
                        ), // 👈 Gap between Row and content
                      ],
                    );
                  }

                  final section = policySections[index - 1];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CralikaFont(
                        text: section.title,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.88, // 4% of 22
                        lineHeight: 27 / 22, // 1.227
                      ),

                      const SizedBox(height: 16),
                      ...List.generate(
                        section.content.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BarlowText(text: section.content[i],fontWeight: FontWeight.w400,fontSize: 14,),
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
}
