import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeneralLinksController extends ChangeNotifier {
  String instagramLink = '';
  String emailLink = '';
  String linkedinLink = '';

  Future<void> getGeneralLinks() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://www.kireimics.com/apis/common/general_links/get_general_links.php",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.toString());
        final socialMediaLinks = jsonDecode(data[0]['social_media_links']);

        instagramLink = socialMediaLinks['Instagram'] ?? '';
        emailLink = socialMediaLinks['Email'] ?? '';
        linkedinLink = socialMediaLinks['Linkedin'] ?? '';
        notifyListeners();
      }
    } catch (e) {
      // debugPrint("Error fetching social media links: $e");
    }
  }
}
