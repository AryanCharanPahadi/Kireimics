// controllers/contact_controller.dart
import 'dart:convert';

import '../../component/api_helper/api_helper.dart';

class ContactController {
  Map<String, dynamic>? contactData;
  List<Map<String, String>> faqData = [];
  bool isLoading = true;

  Future<void> fetchContactDetails() async {
    try {
      final data = await ApiHelper.fetchContactData();
      contactData = data;

      if (data != null && data.containsKey('collection')) {
        try {
          faqData = List<Map<String, String>>.from(
            jsonDecode(
              data['collection'],
            ).map((item) => Map<String, String>.from(item)),
          );
        } catch (e) {
          // print("Error parsing FAQ data: $e");
          faqData = [];
        }
      }
      isLoading = false;
    } catch (e) {
      // print("Error fetching contact data: $e");
      isLoading = false;
    }
  }
}
