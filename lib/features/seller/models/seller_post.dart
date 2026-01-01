enum SellerPostType {
  product,
  discount,
}

class SellerPost {
  final String id;
  final SellerPostType type;
  final String description;
  final double? price;
  final DateTime createdAt;
  final bool active;

  const SellerPost({
    required this.id,
    required this.type,
    required this.description,
    required this.price,
    required this.createdAt,
    required this.active,
  });

  SellerPost copyWith({
    String? description,
    double? price,
    bool? active,
  }) {
    return SellerPost(
      id: id,
      type: type,
      description: description ?? this.description,
      price: price ?? this.price,
      createdAt: createdAt,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'description': description,
        'price': price,
        'createdAt': createdAt.toIso8601String(),
        'active': active,
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
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      active: json['active'] as bool? ?? true,
    );
  }
}
