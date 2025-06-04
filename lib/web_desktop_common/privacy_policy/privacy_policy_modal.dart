import 'dart:convert';

class PrivacyPolicyModal {
  final int id;
  final String updatedAt;
  final List<PrivacySection> privacyPolicy;

  PrivacyPolicyModal({required this.id, required this.privacyPolicy, required this.updatedAt, });

  factory PrivacyPolicyModal.fromJson(Map<String, dynamic> json) {
    final decodedPolicy = jsonDecode(json['privacy_policy']);
    return PrivacyPolicyModal(
      id: json['id'],
      updatedAt: json['updated_at'],
      privacyPolicy: List<PrivacySection>.from(
        decodedPolicy.map((e) => PrivacySection.fromJson(e)),
      ),
    );
  }
}

class PrivacySection {
  final String title;
  final List<String> content;

  PrivacySection({required this.title, required this.content});

  factory PrivacySection.fromJson(Map<String, dynamic> json) {
    final dynamic rawContent = json['content'];
    return PrivacySection(
      title: json['title'],
      content:
          rawContent is String ? [rawContent] : List<String>.from(rawContent),
    );
  }
}
