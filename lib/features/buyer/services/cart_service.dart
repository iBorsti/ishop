import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  static final CartService instance = CartService._private();

  final List<CartItem> _items = [];
  static const _kStorageKey = 'cart_items_v1';

  // start async restore in background
  void _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw == null) return;
    try {
      final list = json.decode(raw) as List<dynamic>;
      _items.clear();
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          _items.add(CartItem.fromMap(e));
        } else if (e is Map) {
          _items.add(CartItem.fromMap(Map<String, dynamic>.from(e)));
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  // call restore when singleton is created
  CartService._private() {
    _restore();
  }

  void _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_items.map((e) => e.toMap()).toList());
    await prefs.setString(_kStorageKey, encoded);
  }

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem({required String id, required String name, required double price, String sellerId = ''}) {
    final i = _items.indexWhere((e) => e.id == id && e.sellerId == sellerId);
    if (i >= 0) {
      _items[i].quantity += 1;
    } else {
      _items.add(CartItem(id: id, name: name, price: price, sellerId: sellerId));
    }
    notifyListeners();
    _persist();
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    _persist();
  }

  void changeQuantity(String id, int newQty) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0) {
      if (newQty <= 0) {
        _items.removeAt(i);
      } else {
        _items[i].quantity = newQty;
      }
      notifyListeners();
      _persist();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _persist();
  }

  int get totalCount => _items.fold(0, (p, e) => p + e.quantity);
  double get totalPrice => _items.fold(0.0, (p, e) => p + e.total);
}
