import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../component/product_details/product_details_modal.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../component/text_fonts/custom_text.dart';

class ResponsiveUtil {
  final BuildContext context;
  final double screenWidth;
  final double screenHeight;

  ResponsiveUtil(this.context)
    : screenWidth = MediaQuery.of(context).size.width,
      screenHeight = MediaQuery.of(context).size.height;

  double getResponsiveHeight(double imageHeight) {
    if (screenWidth >= 1400 && screenWidth <= 1750) {
      return imageHeight * 0.45;
    } else {
      return imageHeight * 0.35;
    }
  }

  double getResponsiveWidth(double imageWidth) {
    return imageWidth * 0.95; // You can modify this logic if needed
  }
}



