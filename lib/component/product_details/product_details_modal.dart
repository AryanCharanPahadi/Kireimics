import 'dart:convert';

class Product {
  final int id;
  final int catId;
  final String name;
  final String tag;
  final String price;
  final String thumbnail;
  final List<String> otherImages;
  final String dimensions;
  final String description;
  final String catName;
  final String catDesc;
  final List<OtherDetail> otherDetails;
  final int discount;

  Product({
    required this.id,
    required this.catId,
    required this.name,
    required this.tag,
    required this.price,
    required this.thumbnail,
    required this.otherImages,
    required this.dimensions,
    required this.description,
    required this.catName,
    required this.otherDetails,
    required this.discount,
    required this.catDesc,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      catId: json['cat_id'],
      name: json['name'],
      tag: json['tag'],
      price: json['price'],
      thumbnail: json['thumnail'],
      otherImages: (json['other_images'] as String).split(','),
      dimensions: json['dimensions'],
      description: json['description'],
      catName: json['category_name'],
      catDesc: json['description'],
      discount: json['discount'],
      otherDetails:
          (json['other_details'] != null)
              ? (jsonDecode(json['other_details']) as List)
                  .map((e) => OtherDetail.fromJson(e))
                  .toList()
              : [],
    );
  }
}

class OtherDetail {
  final String title;
  final String description;

  OtherDetail({required this.title, required this.description});

  factory OtherDetail.fromJson(Map<String, dynamic> json) {
    return OtherDetail(title: json['title'], description: json['description']);
  }
}
