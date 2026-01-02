import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaleEvent {
  final String id;
  final String sellerId;
  final String productId;
  final String productName;
  final double amount;
  final int quantity;
  final DateTime createdAt;

  SaleEvent({
    required this.id,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sellerId': sellerId,
        'productId': productId,
        'productName': productName,
        'amount': amount,
        'quantity': quantity,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SaleEvent.fromJson(Map<String, dynamic> j) => SaleEvent(
        id: j['id'] as String,
        sellerId: j['sellerId'] as String,
        productId: j['productId'] as String,
        productName: j['productName'] as String,
        amount: (j['amount'] as num).toDouble(),
        quantity: (j['quantity'] as num).toInt(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class SellerMetricsService {
  static const _kKeyPrefix = 'seller_sales_events_';

  static Future<void> recordSale(SaleEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kKeyPrefix${event.sellerId}';
    final raw = prefs.getString(key);
    final list = <Map<String, dynamic>>[];
    if (raw != null) {
      final data = json.decode(raw) as List<dynamic>;
      list.addAll(data.map((e) => e as Map<String, dynamic>));
    }
    list.add(event.toJson());
    await prefs.setString(key, json.encode(list));
  }

  static Future<List<SaleEvent>> _loadAll(String sellerId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kKeyPrefix$sellerId';
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final data = json.decode(raw) as List<dynamic>;
    return data.map((e) => SaleEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<SaleEvent>> queryRange(String sellerId, DateTime from, DateTime to) async {
    final all = await _loadAll(sellerId);
    return all.where((e) => !e.createdAt.isBefore(from) && !e.createdAt.isAfter(to)).toList();
  }

  static Future<Map<DateTime, double>> dailyTotals(String sellerId, DateTime from, DateTime to) async {
    final events = await queryRange(sellerId, from, to);
    final Map<String, double> map = {};
    for (final e in events) {
      final key = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day).toIso8601String();
      map[key] = (map[key] ?? 0) + e.amount;
    }
    final result = <DateTime, double>{};
    DateTime cur = DateTime(from.year, from.month, from.day);
    while (!cur.isAfter(to)) {
      final k = cur.toIso8601String();
      result[cur] = map[k] ?? 0.0;
      cur = cur.add(const Duration(days: 1));
    }
    return result;
  }

  static Future<int> totalCustomers(String sellerId, DateTime from, DateTime to) async {
    // For prototype, estimate customers as unique product purchases count
    final events = await queryRange(sellerId, from, to);
    final customers = events.map((e) => e.id).toSet().length;
    return customers;
  }

  static Future<List<Map<String, Object>>> topProducts(String sellerId, DateTime from, DateTime to) async {
    final events = await queryRange(sellerId, from, to);
    final Map<String, int> counts = {};
    for (final e in events) {
      counts[e.productName] = (counts[e.productName] ?? 0) + e.quantity;
    }
    final list = counts.entries.map((e) => {'name': e.key, 'count': e.value}).toList();
    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return list;
  }

  static Future<String> exportCsv(String sellerId, DateTime from, DateTime to) async {
    final events = await queryRange(sellerId, from, to);
    final buffer = StringBuffer();
    buffer.writeln('id,sellerId,productId,productName,amount,quantity,createdAt');
    for (final e in events) {
      buffer.writeln('${e.id},${e.sellerId},${e.productId},"${e.productName}",${e.amount},${e.quantity},${e.createdAt.toIso8601String()}');
    }
    return buffer.toString();
  }
}
