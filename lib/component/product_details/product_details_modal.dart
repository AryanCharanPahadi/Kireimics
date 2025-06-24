import 'dart:convert';

class Product {
  final int id;
  final int catId;
  final String name;
  final String tag;
  final double price;
  final double? discountPrice;
  final String thumbnail;
  final List<String> otherImages;
  final String dimensions;
  final double length;
  final double breadth;
  final double height;
  final String description;
  final int? quantity;
  final double weight;
  final String catName;
  final String catDesc;
  final String? collectionName;
  final List<OtherDetail> otherDetails;
  final int discount;
  final int isSale;
  final int? isCollection;
  final int isMakerChoice;

  Product({
    required this.id,
    required this.catId,
    required this.name,
    required this.tag,
    required this.price,
    this.discountPrice,
    required this.thumbnail,
    required this.otherImages,
    required this.dimensions,
    required this.length,
    required this.breadth,
    required this.height,
    required this.weight,
    required this.description,
     this.quantity,
    required this.catName,
    this.collectionName,
    required this.otherDetails,
    required this.discount,
    required this.catDesc,
    required this.isSale,
     this.isCollection,
    required this.isMakerChoice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      catId: json['cat_id'],
      name: json['name'],
      tag: json['tag'],
      price: json['price'],
      discountPrice: json['discount_price'],
      thumbnail: json['thumnail'],
      collectionName: json['collection_name'],
      otherImages: (json['other_images'] as String).split(','),
      dimensions: json['dimensions'],
      length: json['length'],
      breadth: json['breadth'],
      height: json['height'],
      weight: json['weight'],
      description: json['description'],
      quantity: json['quantity'],
      catName: json['category_name'],
      catDesc: json['description'],
      discount: json['discount'],
      isSale: json['is_sale'],
      isCollection: json['is_collection'],
      isMakerChoice: json['is_make_choice'],
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
