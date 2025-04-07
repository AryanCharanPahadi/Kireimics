import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../component/custom_text.dart';
import '../component/above_footer.dart';

class ShippingPolicyWeb extends StatefulWidget {
  const ShippingPolicyWeb({super.key});

  @override
  State<ShippingPolicyWeb> createState() => _ShippingPolicyWebState();
}

class _ShippingPolicyWebState extends State<ShippingPolicyWeb> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // color: Colors.red,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 270, right: 120, top: 24),
            child: SizedBox(
              // color: Colors.yellow,
              // height: 164,
              width: MediaQuery.of(context).size.width,

              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CralikaFont(text: "Shipping Policy"),
                  SizedBox(height: 44),
                  CralikaFont(text: "1. Introduction"),
                  SizedBox(height: 15),

                  BarlowText(
                    text:
                        "After placing your order, we at Kireimics agree to dispatch all the ordered products by the buyer within 7 working days. This deadline will be communicated via our Third-party delivery partners.\n\nDelivery times are always given as an approximation. Exceeding them cannot justify the cancellation of your order without prior agreement.",
                  ),
                  SizedBox(height: 24),
                  CralikaFont(text: "2. Where We Deliver"),
                  SizedBox(height: 17),
                  BarlowText(
                    text:
                        "1. The delivery will be executed to the buyers selected address. Currently, we are only delivering within India.",
                  ),
                  SizedBox(height: 18),
                  BarlowText(
                    text:
                        "2. In case of absence, the buyer or the recipient of the ordered product is required to check with our third-party delivery partner for attempting re-delivery.  ",
                  ),
                  SizedBox(height: 18),

                  BarlowText(
                    text:
                        "3. The buyer must check the condition of the goods and its contents on delivery, in the presence of the delivery person.   ",
                  ),
                  SizedBox(height: 18),
                  BarlowText(
                    text:
                        "4. The seller cannot be held responsible for lost packages.  ",
                  ),
                  SizedBox(height: 18),
                  BarlowText(
                    text:
                        "Please note:  Once the order has been received, if the buyer has any concerns, they are required to report any reservations and complaints or refuse the goods immediately by reporting to the delivery partner and Kireimics.",
                  ),
                  SizedBox(height: 24),

                  CralikaFont(text: "3. Shipping & Returns"),
                  SizedBox(height: 16),
                  BarlowText(
                    text:
                        "Each item listed on the Kireimics website is 100% handmade, fired, hand painted, hand glazed, fired again and individually wrapped with the utmost care, before shipping.  We cannot accept returns or refunds, unless there has been a problem during transit. In such cases, please reach out to hello@kireimics.com and we will be happy to help you as best as we can.",
                  ),

                ],
              ),
            ),
          ),
          const SizedBox(height: 35),

          AboveFooter()
        ],
      ),
    );
  }
}
