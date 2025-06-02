// lib/screens/policy/ShippingPolicy.dart

import 'package:flutter/material.dart';
import 'package:kireimics/component/api_helper/api_helper.dart';
import '../../component/text_fonts/custom_text.dart';
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
          },
        ),
      ),
    );
  }
}
