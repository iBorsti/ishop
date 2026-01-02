import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderService {
  static const _kKey = 'app_orders_v1';

  static Future<void> createOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    final list = <Map<String, dynamic>>[];
    if (raw != null) {
      final data = json.decode(raw) as List<dynamic>;
      list.addAll(data.map((e) => Map<String, dynamic>.from(e as Map)));
    }
    list.add(order.toMap());
    await prefs.setString(_kKey, json.encode(list));
  }

  static Future<List<Order>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return [];
    final data = json.decode(raw) as List<dynamic>;
    return data.map((e) => Order.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  static Future<List<Order>> getOrdersForSeller(String sellerId) async {
    final all = await _loadAll();
    return all.where((o) => o.items.any((i) => i.sellerId == sellerId)).toList();
  }

  static Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return;
    final data = json.decode(raw) as List<dynamic>;
    final list = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    for (final m in list) {
      if (m['id'] == orderId) {
        m['status'] = status.toString();
        break;
      }
    }
    await prefs.setString(_kKey, json.encode(list));
  }
}
