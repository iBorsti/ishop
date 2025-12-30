import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/delivery_jornada.dart';
import '../models/delivery_debt.dart';

class DeliveryJornadaService {
  DeliveryJornada _jornada = DeliveryJornada.todayNotStarted();
  DeliveryDebt _debt = DeliveryDebt.empty();
  bool _loaded = false;

  static const _kJornadaKey = 'delivery_jornada';
  static const _kDebtKey = 'delivery_debt';

  DeliveryJornada getCurrentJornada() {
    return _jornada;
  }

  DeliveryDebt getDebt() {
    return _debt;
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawJ = prefs.getString(_kJornadaKey);
    final rawD = prefs.getString(_kDebtKey);
    if (rawJ != null) {
      try {
        _jornada = DeliveryJornada.fromJson(json.decode(rawJ));
      } catch (_) {}
    }
    if (rawD != null) {
      try {
        _debt = DeliveryDebt.fromJson(json.decode(rawD));
      } catch (_) {}
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kJornadaKey, json.encode(_jornada.toJson()));
    await prefs.setString(_kDebtKey, json.encode(_debt.toJson()));
  }

  void startJornada() {
    _jornada = _jornada.copyWith(status: JornadaStatus.active);
    _persist();
  }

  void closeJornada({bool paid = false}) {
    _jornada = _jornada.copyWith(status: JornadaStatus.closed, paid: paid);

    if (!paid) {
      _debt = _debt.addDay(_jornada.dailyFee);
    }
    _persist();
  }

  void markAsPaid() {
    _jornada = _jornada.copyWith(paid: true);
    _debt = _debt.clear();
    _persist();
  }
}
