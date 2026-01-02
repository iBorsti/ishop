import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_env.dart';
import '../models/seller_post.dart';

class BuyerHighlight {
  final String description;
  final String sellerName;
  final DateTime createdAt;
  final String sellerId;

  const BuyerHighlight({
    required this.description,
    required this.sellerName,
    required this.createdAt,
    required this.sellerId,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'sellerName': sellerName,
        'createdAt': createdAt.toIso8601String(),
        'sellerId': sellerId,
      };

  factory BuyerHighlight.fromJson(Map<String, dynamic> json) {
    return BuyerHighlight(
      description: json['description'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? 'Vendedor',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      sellerId: json['sellerId'] as String? ?? '',
    );
  }
}

class SellerPostService {
  static String _key(String userId) =>
      'seller_posts_${AppConfig.env.name}_$userId';
  static String _highlightKey() => 'buyer_highlight_discounts_${AppConfig.env.name}';

  static Future<List<SellerPost>> _loadAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) return [];
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => SellerPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _saveAll(String userId, List<SellerPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(posts.map((e) => e.toJson()).toList());
    await prefs.setString(_key(userId), raw);
  }

  static Future<List<SellerPost>> getMyPosts(String userId) async {
    return _loadAll(userId);
  }

  static Future<SellerPost> createProduct({
    required String userId,
    String? title,
    required String description,
    required double price,
    String? imageUrl,
    required String sellerName,
  }) async {
    final post = SellerPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      type: SellerPostType.product,
      title: title,
      description: description,
      imageUrl: imageUrl,
      price: price,
      createdAt: DateTime.now(),
      active: true,
      sellerName: sellerName,
      sellerId: userId,
    );
    final items = await _loadAll(userId);
    items.insert(0, post);
    await _saveAll(userId, items);
    return post;
  }

  static Future<SellerPost> createDiscount({
    required String userId,
    required String description,
    required String sellerName,
  }) async {
    final post = SellerPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      type: SellerPostType.discount,
      description: description,
      price: null,
      createdAt: DateTime.now(),
      active: true,
      sellerName: sellerName,
      sellerId: userId,
    );
    final items = await _loadAll(userId);
    items.insert(0, post);
    await _saveAll(userId, items);
    await _addHighlight(post);
    return post;
  }

  static Future<void> updatePost({
    required String userId,
    required String postId,
    String? title,
    required String description,
    double? price,
    String? imageUrl,
    String? sellerName,
    String? sellerId,
    bool? active,
  }) async {
    final items = await _loadAll(userId);
    final idx = items.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    items[idx] = items[idx]
        .copyWith(
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          active: active,
          sellerName: sellerName,
          sellerId: sellerId,
        );
    await _saveAll(userId, items);
  }

  static Future<void> deletePost({
    required String userId,
    required String postId,
  }) async {
    final items = await _loadAll(userId);
    items.removeWhere((p) => p.id == postId);
    await _saveAll(userId, items);
  }

  static Future<List<BuyerHighlight>> getDiscountHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_highlightKey());
    if (raw == null) return [];
    final data = jsonDecode(raw) as List<dynamic>;
    final list = data
        .map((e) => BuyerHighlight.fromJson(e as Map<String, dynamic>))
        .toList();
    return _filterByOpen(list);
  }

  static Future<void> _addHighlight(SellerPost post) async {
    if (post.type != SellerPostType.discount) return;
    final prefs = await SharedPreferences.getInstance();
    final existingRaw = prefs.getString(_highlightKey());
    List<BuyerHighlight> current = [];
    if (existingRaw != null) {
      final data = jsonDecode(existingRaw) as List<dynamic>;
      current = data
          .map((e) => BuyerHighlight.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    current.insert(
      0,
      BuyerHighlight(
        description: post.description,
        sellerName: post.sellerName,
        createdAt: post.createdAt,
        sellerId: post.sellerId,
      ),
    );
    if (current.length > 10) current = current.sublist(0, 10);
    final raw = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_highlightKey(), raw);
  }

  static Future<List<BuyerHighlight>> _filterByOpen(
    List<BuyerHighlight> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <BuyerHighlight>[];
    for (final h in list) {
      if (h.sellerId.isEmpty) continue;
      final key = 'seller_open_${AppConfig.env.name}_${h.sellerId}';
      final isOpen = prefs.getBool(key) ?? true;
      if (isOpen) result.add(h);
    }
    return result;
  }
}
