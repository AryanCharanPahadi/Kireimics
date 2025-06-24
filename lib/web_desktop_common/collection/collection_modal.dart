
class CollectionModal {
  final int? id;
  final String? productId;
  final String? bannerImg;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final int productCount;

  CollectionModal({
    this.id,
    this.productId,
    this.bannerImg,
    this.name,
    this.createdAt,
    this.updatedAt,
    required this.productCount,
  });

  factory CollectionModal.fromJson(Map<String, dynamic> json) {
    int count = 0;
    try {
      var raw = json['product_id'];
      if (raw is String && raw.isNotEmpty) {
        count = raw.split(',').length;
      }
    } catch (e) {
      print("Failed to parse product_id: ${json['product_id']}");
    }

    return CollectionModal(
      id: json['id'],
      productId: json['product_id']?.toString(),
      bannerImg: json['banner_img']?.toString(),
      name: json['name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      productCount: count,
    );
  }
}
