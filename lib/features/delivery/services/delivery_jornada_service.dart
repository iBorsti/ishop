import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/delivery_jornada.dart';
import '../models/delivery_debt.dart';

class DeliveryJornadaService {
  DeliveryJornada _jornada = DeliveryJornada.todayNotStarted();
  DeliveryDebt _debt = DeliveryDebt.empty();
  final List<DeliveryJornada> _history = [];
  bool _loaded = false;

  static const _kJornadaKey = 'delivery_jornada';
  static const _kDebtKey = 'delivery_debt';
  static const _kHistoryKey = 'delivery_history';

  DeliveryJornada getCurrentJornada() {
    return _jornada;
  }

  DeliveryDebt getDebt() {
    return _debt;
  }

  List<DeliveryJornada> getJornadaHistory({DateTime? from, DateTime? to}) {
    return _history
        .where((j) => j.isClosed)
        .where((j) {
          if (from != null && (j.closedAt ?? j.date).isBefore(from)) {
            return false;
          }
          if (to != null && (j.closedAt ?? j.date).isAfter(to)) {
            return false;
          }
          return true;
        })
        .toList()
      ..sort(
        (a, b) => (b.closedAt ?? b.date).compareTo(a.closedAt ?? a.date),
      );
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawJ = prefs.getString(_kJornadaKey);
    final rawD = prefs.getString(_kDebtKey);
    final rawH = prefs.getString(_kHistoryKey);
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
    if (rawH != null) {
      try {
        final decoded = json.decode(rawH) as List;
        _history
          ..clear()
          ..addAll(
            decoded
                .map((e) => DeliveryJornada.fromJson(
                      (e as Map).cast<String, dynamic>(),
                    ))
                .toList(),
          );
      } catch (_) {}
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kJornadaKey, json.encode(_jornada.toJson()));
    await prefs.setString(_kDebtKey, json.encode(_debt.toJson()));
    await prefs.setString(
      _kHistoryKey,
      json.encode(_history.map((j) => j.toJson()).toList()),
    );
  }

  void startJornada() {
    _jornada = _jornada.copyWith(status: JornadaStatus.active);
    _persist();
  }

  void closeJornada({bool paid = false}) {
    final closed = _jornada.copyWith(
      status: JornadaStatus.closed,
      paid: paid,
      closedAt: DateTime.now(),
    );
    _jornada = closed;
    _history.add(closed);

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
