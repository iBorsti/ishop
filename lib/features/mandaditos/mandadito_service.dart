import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_env.dart';
import 'mandadito.dart';

class MandaditoService {
  static String _key() => 'mandaditos_${AppConfig.env.name}';

  static Future<List<Mandadito>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key());
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Mandadito.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _saveAll(List<Mandadito> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((m) => m.toJson()).toList());
    await prefs.setString(_key(), raw);
  }

  static Future<Mandadito> createMandadito({
    required String origin,
    required String description,
    required String destination,
    required bool urgent,
    double? budget,
  }) async {
    final id = 'mand_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final newItem = Mandadito(
      id: id,
      origin: origin,
      description: description,
      destination: destination,
      urgent: urgent,
      budget: budget,
      status: MandaditoStatus.open,
    );
    final items = await _loadAll();
    items.add(newItem);
    await _saveAll(items);
    return newItem;
  }

  static Future<List<Mandadito>> getOpenMandaditos() async {
    final items = await _loadAll();
    return items.where((m) => m.status == MandaditoStatus.open).toList();
  }

  static Future<bool> takeMandadito(String id) async {
    final items = await _loadAll();
    final idx = items.indexWhere((m) => m.id == id);
    if (idx == -1) return false;
    final item = items[idx];
    if (item.status != MandaditoStatus.open) return false;
    items[idx] = item.copyWith(status: MandaditoStatus.taken);
    await _saveAll(items);
    return true;
  }
}
