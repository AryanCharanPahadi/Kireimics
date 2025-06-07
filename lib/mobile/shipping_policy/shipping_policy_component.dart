import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../component/api_helper/api_helper.dart' show ApiHelper;
import '../../component/text_fonts/custom_text.dart';
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
      return const Center(child: CircularProgressIndicator());
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
                        CralikaFont(text: "Shipping Policy"),

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
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8, // 4% of 20px = 0.8
                        lineHeight: 27 / 20, // Line height calculation
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        section.content.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BarlowText(text: section.content[i]),
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
