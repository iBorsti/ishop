enum SellerPostType {
  product,
  discount,
}

class SellerPost {
  final String id;
  final SellerPostType type;
  final String? title;
  final String description;
  final String? imageUrl;
  final double? price;
  final DateTime createdAt;
  final bool active;
  final String sellerName;
  final String sellerId;

  const SellerPost({
    required this.id,
    required this.type,
    this.title,
    required this.description,
    this.imageUrl,
    required this.price,
    required this.createdAt,
    required this.active,
    required this.sellerName,
    required this.sellerId,
  });

  SellerPost copyWith({
    String? title,
    String? description,
    double? price,
    bool? active,
    String? sellerName,
    String? sellerId,
    String? imageUrl,
  }) {
    return SellerPost(
      id: id,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      createdAt: createdAt,
      active: active ?? this.active,
      sellerName: sellerName ?? this.sellerName,
      sellerId: sellerId ?? this.sellerId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
      'title': title,
        'description': description,
      'imageUrl': imageUrl,
        'price': price,
        'createdAt': createdAt.toIso8601String(),
        'active': active,
        'sellerName': sellerName,
        'sellerId': sellerId,
      };

  factory SellerPost.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final type = SellerPostType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => SellerPostType.product,
    );
    return SellerPost(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String?,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      active: json['active'] as bool? ?? true,
      sellerName: json['sellerName'] as String? ?? 'Vendedor',
      sellerId: json['sellerId'] as String? ?? '',
    );
  }
}
