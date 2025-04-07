import 'package:flutter/material.dart';

import '../../component/custom_text.dart';

class PrivacyPolicyComponent extends StatefulWidget {
  const PrivacyPolicyComponent({super.key});

  @override
  State<PrivacyPolicyComponent> createState() => _PrivacyPolicyComponentState();
}

class _PrivacyPolicyComponentState extends State<PrivacyPolicyComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // color: Colors.red,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 22, top: 32),
            child: SizedBox(
              // color: Colors.yellow,
              // height: 164,
              width: MediaQuery.of(context).size.width,

              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CralikaFont(text: "Privacy Policy"),
                  SizedBox(height: 10),
                  CralikaFont(
                    text: "1. Introduction",
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8, // 4% of 20px = 0.8
                    lineHeight: 27 / 20, // Line height calculation
                  ),
                  SizedBox(height: 15),

                  BarlowText(
                    text:
                        "Welcome to Kireimics! Your privacy is critically important to us. Our privacy policy describes how your personal information is collected, used, and shared when you visit or make a purchase from www.kireimics.com. By using our site, you consent to the practices described in this policy.",
                  ),
                  SizedBox(height: 24),
                  CralikaFont(
                    text: "2. Information We Collect",
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8, // 4% of 20px = 0.8
                    lineHeight: 27 / 20, // Line height calculation
                  ),
                  SizedBox(height: 17),
                  BarlowText(
                    text:
                        "• Personal Information: When you create an account, sign in, or make a purchase, we may collect information such as your name, email address, mailing address, phone number, and payment details.",
                  ),

                  SizedBox(height: 18),
                  BarlowText(
                    text:
                        "• Order Information: We collect details about your orders, including the products you purchase, shipping address, and order history.",
                  ),
                  SizedBox(height: 18),

                  BarlowText(
                    text:
                        "• Account Details: When you access your account, we gather information to help manage your orders and preferences.",
                  ),

                  SizedBox(height: 24),

                  CralikaFont(
                    text: "3. How We Use Your Information",
                    fontSize: 20,
                  ),
                  SizedBox(height: 16),
                  BarlowText(text: 'We use your information to:'),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BarlowText(text: '• Process and fulfill your orders.'),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Communicate with you about your orders, products, and promotions (optional).',
                        ),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Manage your account and provide customer support.',
                        ),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Improve our site and enhance your shopping experience.',
                        ),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Comply with legal obligations and regulations.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  CralikaFont(
                    text: "4. Sharing Your Information",
                    fontSize: 20,
                  ),
                  SizedBox(height: 16),
                  BarlowText(
                    text:
                        'We do not sell, trade, or otherwise transfer your personal information to outside parties, except as described below:',
                  ),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BarlowText(text: '• Process and fulfill your orders.'),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Service Providers: We may share your information with third-party service providers who assist us in processing payments, and delivering orders.',
                        ),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Legal Requirements: We may disclose your information if required to do so by law or in response to valid requests by public authorities.',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  CralikaFont(text: "5. Data Security", fontSize: 20),
                  SizedBox(height: 16),
                  BarlowText(
                    text:
                        'We take the security of your personal information seriously and implement appropriate measures to protect it. However, no method of transmission over the Internet or electronic storage is 100% secure.',
                  ),

                  SizedBox(height: 24),

                  CralikaFont(text: "6. Your Rights", fontSize: 20),
                  SizedBox(height: 16),
                  BarlowText(text: 'You have the right to:'),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BarlowText(text: '• Process and fulfill your orders.'),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Access, correct, or delete your personal information.',
                        ),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Object to or restrict the processing of your data.',
                        ),
                        SizedBox(height: 18),
                        BarlowText(
                          text:
                              '• Withdraw your consent at any time, without affecting the lawfulness of processing based on consent before its withdrawal.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  CralikaFont(text: "7. Changes to This Policy", fontSize: 20),
                  SizedBox(height: 16),
                  BarlowText(
                    text:
                        'We may update this privacy policy from time to time to reflect changes in our practices or legal requirements. We will notify you of any material changes by posting the new policy on our site.',
                  ),
                  SizedBox(height: 24),

                  CralikaFont(text: "8. Contact Us", fontSize: 20),
                  SizedBox(height: 16),
                  BarlowText(
                    text:
                        'If you have any questions or concerns about this privacy policy or our data practices, please contact us at hello@kireimics.com',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
