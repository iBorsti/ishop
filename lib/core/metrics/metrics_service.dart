import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MetricEvent {
  final String id;
  final String ownerType; // e.g. seller, fleet, delivery
  final String ownerId;
  final String itemId;
  final String itemName;
  final double amount;
  final int quantity;
  final DateTime createdAt;

  MetricEvent({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.itemId,
    required this.itemName,
    required this.amount,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerType': ownerType,
        'ownerId': ownerId,
        'itemId': itemId,
        'itemName': itemName,
        'amount': amount,
        'quantity': quantity,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MetricEvent.fromJson(Map<String, dynamic> j) => MetricEvent(
        id: j['id'] as String,
        ownerType: j['ownerType'] as String,
        ownerId: j['ownerId'] as String,
        itemId: j['itemId'] as String,
        itemName: j['itemName'] as String,
        amount: (j['amount'] as num).toDouble(),
        quantity: (j['quantity'] as num).toInt(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class MetricsService {
  static String _keyFor(String ownerType, String ownerId) => 'metrics_${ownerType}_$ownerId';

  static Future<void> recordEvent(MetricEvent e) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(e.ownerType, e.ownerId);
    final raw = prefs.getString(key);
    final list = <Map<String, dynamic>>[];
    if (raw != null) {
      final data = json.decode(raw) as List<dynamic>;
      list.addAll(data.map((x) => Map<String, dynamic>.from(x as Map)));
    }
    list.add(e.toJson());
    await prefs.setString(key, json.encode(list));
  }

  static Future<List<MetricEvent>> _loadAllFor(String ownerType, String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(ownerType, ownerId);
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final data = json.decode(raw) as List<dynamic>;
    return data.map((x) => MetricEvent.fromJson(Map<String, dynamic>.from(x as Map))).toList();
  }

  static Future<List<MetricEvent>> queryRange(String ownerType, String ownerId, DateTime from, DateTime to) async {
    final all = await _loadAllFor(ownerType, ownerId);
    return all.where((e) => !e.createdAt.isBefore(from) && !e.createdAt.isAfter(to)).toList();
  }

  static Future<Map<DateTime, double>> dailyTotals(String ownerType, String ownerId, DateTime from, DateTime to) async {
    final events = await queryRange(ownerType, ownerId, from, to);
    final Map<String, double> map = {};
    for (final e in events) {
      final k = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day).toIso8601String();
      map[k] = (map[k] ?? 0) + e.amount;
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

  static Future<List<Map<String, Object>>> topItems(String ownerType, String ownerId, DateTime from, DateTime to) async {
    final events = await queryRange(ownerType, ownerId, from, to);
    final Map<String, int> counts = {};
    for (final e in events) counts[e.itemName] = (counts[e.itemName] ?? 0) + e.quantity;
    final list = counts.entries.map((e) => {'name': e.key, 'count': e.value}).toList();
    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return list;
  }

  // Aggregate across all owners for a given ownerType
  static Future<Map<DateTime, double>> dailyTotalsGlobal(String ownerType, DateTime from, DateTime to) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('metrics_${ownerType}_'));
    final aggregated = <String, double>{};
    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      final data = json.decode(raw) as List<dynamic>;
      for (final x in data) {
        final e = MetricEvent.fromJson(Map<String, dynamic>.from(x as Map));
        if (e.createdAt.isBefore(from) || e.createdAt.isAfter(to)) continue;
        final k = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day).toIso8601String();
        aggregated[k] = (aggregated[k] ?? 0) + e.amount;
      }
    }
    final result = <DateTime, double>{};
    DateTime cur = DateTime(from.year, from.month, from.day);
    while (!cur.isAfter(to)) {
      final k = cur.toIso8601String();
      result[cur] = aggregated[k] ?? 0.0;
      cur = cur.add(const Duration(days: 1));
    }
    return result;
  }

  static Future<String> exportCsv(String ownerType, String ownerId, DateTime from, DateTime to) async {
    final events = await queryRange(ownerType, ownerId, from, to);
    final buffer = StringBuffer();
    buffer.writeln('id,ownerType,ownerId,itemId,itemName,amount,quantity,createdAt');
    for (final e in events) {
      buffer.writeln('${e.id},${e.ownerType},${e.ownerId},${e.itemId},"${e.itemName}",${e.amount},${e.quantity},${e.createdAt.toIso8601String()}');
    }
    return buffer.toString();
  }
}
