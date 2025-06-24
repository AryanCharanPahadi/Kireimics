class CollectionModal {
  final int? id;
  final String? name;
  final String? bannerImg;
  final String? productIds; // "65,69,66,70"
  final String? createdAt;
  final String? updatedAt;

  CollectionModal({
    this.id,
    this.name,
    this.bannerImg,
    this.productIds,
    this.createdAt,
    this.updatedAt,
  });

  // Add fromJson method if not already present
  factory CollectionModal.fromJson(Map<String, dynamic> json) {
    return CollectionModal(
      id: json['id'],
      name: json['name'],
      bannerImg: json['banner_img'],
      productIds: json['product_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Helper getter to count products
  int get productCount => productIds?.split(',').length ?? 0;
}