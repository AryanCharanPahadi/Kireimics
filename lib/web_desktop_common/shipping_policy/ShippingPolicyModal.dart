import 'dart:convert';

class ShippingSection {
  final String title;
  final List<String> content;

  ShippingSection({required this.title, required this.content});

  factory ShippingSection.fromJson(Map<String, dynamic> json) {
    return ShippingSection(
      title: json['title'],
      content: List<String>.from(json['content']),
    );
  }
}

class ShippingPolicyModel {
  final int id;
  final List<ShippingSection> shippingPolicy;

  ShippingPolicyModel({required this.id, required this.shippingPolicy});

  factory ShippingPolicyModel.fromJson(Map<String, dynamic> json) {
    return ShippingPolicyModel(
      id: json['id'],
      shippingPolicy:
          (jsonDecode(json['shipping_policy']) as List)
              .map((e) => ShippingSection.fromJson(e))
              .toList(),
    );
  }
}
