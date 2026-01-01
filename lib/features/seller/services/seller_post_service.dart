import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_env.dart';
import '../models/seller_post.dart';

class SellerPostService {
  static String _key(String userId) =>
      'seller_posts_${AppConfig.env.name}_$userId';

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
    required String description,
    required double price,
  }) async {
    final post = SellerPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      type: SellerPostType.product,
      description: description,
      price: price,
      createdAt: DateTime.now(),
      active: true,
    );
    final items = await _loadAll(userId);
    items.insert(0, post);
    await _saveAll(userId, items);
    return post;
  }

  static Future<SellerPost> createDiscount({
    required String userId,
    required String description,
  }) async {
    final post = SellerPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      type: SellerPostType.discount,
      description: description,
      price: null,
      createdAt: DateTime.now(),
      active: true,
    );
    final items = await _loadAll(userId);
    items.insert(0, post);
    await _saveAll(userId, items);
    return post;
  }

  static Future<void> updatePost({
    required String userId,
    required String postId,
    required String description,
    double? price,
  }) async {
    final items = await _loadAll(userId);
    final idx = items.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(description: description, price: price);
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
}
