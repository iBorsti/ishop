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
    required String createdBy,
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
      createdBy: createdBy,
      takenBy: null,
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

  static Future<bool> takeMandadito({
    required String id,
    required String takenBy,
  }) async {
    final items = await _loadAll();
    final idx = items.indexWhere((m) => m.id == id);
    if (idx == -1) return false;
    final item = items[idx];
    if (item.status != MandaditoStatus.open) return false;
    items[idx] = item.copyWith(
      status: MandaditoStatus.taken,
      takenBy: takenBy,
    );
    await _saveAll(items);
    return true;
  }

  static Future<bool> completeMandadito({
    required String id,
    required String requesterId,
  }) async {
    final items = await _loadAll();
    final idx = items.indexWhere((m) => m.id == id);
    if (idx == -1) return false;
    final item = items[idx];
    if (item.status != MandaditoStatus.taken) return false;
    if (item.takenBy != requesterId) return false;
    items[idx] = item.copyWith(status: MandaditoStatus.completed);
    await _saveAll(items);
    return true;
  }

  static Future<List<Mandadito>> getMyMandaditos(String ownerId) async {
    if (ownerId.isEmpty) return [];
    final items = await _loadAll();
    return items.where((m) => m.createdBy == ownerId).toList();
  }

  static Future<DeliveryMandaditoLists> getListsForDelivery(
    String deliveryId,
  ) async {
    final items = await _loadAll();
    final open = items.where((m) => m.status == MandaditoStatus.open).toList();
    final mine = items
        .where(
          (m) => m.status == MandaditoStatus.taken && m.takenBy == deliveryId,
        )
        .toList();
    return DeliveryMandaditoLists(open: open, mine: mine);
  }
}

class DeliveryMandaditoLists {
  final List<Mandadito> open;
  final List<Mandadito> mine;

  const DeliveryMandaditoLists({required this.open, required this.mine});
}
