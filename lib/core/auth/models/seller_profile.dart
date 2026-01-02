import 'dart:convert';

enum SellerType { business, individual }

class SellerProfile {
  final SellerType type;
  final String? displayName;
  final String? businessName;
  final String? address;
  final String? openingHours;
  final String? logoUrl;
  final String? taxId;
  final bool isPickupAvailable;
  final bool isDeliveryAvailable;
  final List<String> categories;
  final bool verified;

  const SellerProfile({
    required this.type,
    this.displayName,
    this.businessName,
    this.address,
    this.openingHours,
    this.logoUrl,
    this.taxId,
    this.isPickupAvailable = true,
    this.isDeliveryAvailable = true,
    this.categories = const [],
    this.verified = false,
  });

  SellerProfile copyWith({
    SellerType? type,
    String? displayName,
    String? businessName,
    String? address,
    String? openingHours,
    String? logoUrl,
    String? taxId,
    bool? isPickupAvailable,
    bool? isDeliveryAvailable,
    List<String>? categories,
    bool? verified,
  }) {
    return SellerProfile(
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
      logoUrl: logoUrl ?? this.logoUrl,
      taxId: taxId ?? this.taxId,
      isPickupAvailable: isPickupAvailable ?? this.isPickupAvailable,
      isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable,
      categories: categories ?? this.categories,
      verified: verified ?? this.verified,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'displayName': displayName,
        'businessName': businessName,
        'address': address,
        'openingHours': openingHours,
        'logoUrl': logoUrl,
        'taxId': taxId,
        'isPickupAvailable': isPickupAvailable,
        'isDeliveryAvailable': isDeliveryAvailable,
        'categories': categories,
        'verified': verified,
      };

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      type: (json['type'] as String?) == 'business' ? SellerType.business : SellerType.individual,
      displayName: json['displayName'] as String?,
      businessName: json['businessName'] as String?,
      address: json['address'] as String?,
      openingHours: json['openingHours'] as String?,
      logoUrl: json['logoUrl'] as String?,
      taxId: json['taxId'] as String?,
      isPickupAvailable: json['isPickupAvailable'] as bool? ?? true,
      isDeliveryAvailable: json['isDeliveryAvailable'] as bool? ?? true,
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      verified: json['verified'] as bool? ?? false,
    );
  }

  String toRawJson() => json.encode(toJson());

  factory SellerProfile.fromRawJson(String raw) => SellerProfile.fromJson(json.decode(raw));
}
