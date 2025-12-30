import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fleet_bike_jornada.dart';
import '../models/fleet_bike_debt.dart';
import '../models/fleet_financial_summary.dart';

class FleetJornadaService {
  final Map<String, FleetBikeJornada> _jornadas = {};
  final Map<String, FleetBikeDebt> _debts = {};
  final Map<String, List<FleetBikeJornada>> _history = {};
  bool _loaded = false;

  static const int dailyFee = 50;
  static const _kJornadasKey = 'fleet_jornadas';
  static const _kDebtsKey = 'fleet_debts';
  static const _kHistoryKey = 'fleet_history';

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawJ = prefs.getString(_kJornadasKey);
    final rawD = prefs.getString(_kDebtsKey);
    final rawH = prefs.getString(_kHistoryKey);
    if (rawJ != null) {
      try {
        final decoded = json.decode(rawJ) as Map<String, dynamic>;
        decoded.forEach((bikeId, value) {
          _jornadas[bikeId] = FleetBikeJornada.fromJson(
            (value as Map).cast<String, dynamic>(),
          );
        });
      } catch (_) {}
    }
    if (rawD != null) {
      try {
        final decoded = json.decode(rawD) as Map<String, dynamic>;
        decoded.forEach((bikeId, value) {
          _debts[bikeId] = FleetBikeDebt.fromJson(
            (value as Map).cast<String, dynamic>(),
          );
        });
      } catch (_) {}
    }
    if (rawH != null) {
      try {
        final decoded = json.decode(rawH) as Map<String, dynamic>;
        decoded.forEach((bikeId, value) {
          final list = (value as List)
              .map((e) => FleetBikeJornada.fromJson(
                    (e as Map).cast<String, dynamic>(),
                  ))
              .toList();
          _history[bikeId] = list;
        });
      } catch (_) {}
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jMap = _jornadas.map((k, v) => MapEntry(k, v.toJson()));
    final dMap = _debts.map((k, v) => MapEntry(k, v.toJson()));
    final hMap = _history.map(
      (k, v) => MapEntry(k, v.map((j) => j.toJson()).toList()),
    );
    await prefs.setString(_kJornadasKey, json.encode(jMap));
    await prefs.setString(_kDebtsKey, json.encode(dMap));
    await prefs.setString(_kHistoryKey, json.encode(hMap));
  }

  FleetBikeJornada getJornada(String bikeId) {
    return _jornadas.putIfAbsent(
      bikeId,
      () => FleetBikeJornada.notStarted(bikeId, dailyFee: dailyFee),
    );
  }

  FleetBikeDebt getDebt(String bikeId) {
    return _debts.putIfAbsent(bikeId, () => FleetBikeDebt.empty());
  }

  void startJornada(String bikeId) {
    final current = getJornada(bikeId);
    _jornadas[bikeId] = current.copyWith(status: FleetJornadaStatus.active);
    _persist();
  }

  void closeJornada(String bikeId, {bool paid = false}) {
    final current = getJornada(bikeId);
    final closed = current.copyWith(
      status: FleetJornadaStatus.closed,
      paid: paid,
      closedAt: DateTime.now(),
    );
    _jornadas[bikeId] = closed;
    _history.putIfAbsent(bikeId, () => []);
    _history[bikeId]!.add(closed);
    if (!paid) {
      _debts[bikeId] = getDebt(bikeId).addDay(current.dailyFee);
    }
    _persist();
  }

  void markAsPaid(String bikeId) {
    final current = getJornada(bikeId);
    _jornadas[bikeId] = current.copyWith(paid: true);
    _debts[bikeId] = getDebt(bikeId).clear();
    _persist();
  }

  List<FleetBikeJornada> getBikeJornadaHistory(String bikeId) {
    final list = _history[bikeId] ?? [];
    return list
        .where((j) => j.isClosed && j.closedAt != null)
        .toList()
      ..sort((a, b) => b.closedAt!.compareTo(a.closedAt!));
  }

  int totalDebtAmount() =>
      _debts.values.fold(0, (sum, d) => sum + d.totalAmount);
  int totalDaysOwed() => _debts.values.fold(0, (sum, d) => sum + d.daysOwed);
  int totalBikes() => _jornadas.length;

  int _totalClosedJornadas() {
    return _jornadas.values
        .where((j) => j.status == FleetJornadaStatus.closed)
        .length;
  }

  FleetFinancialSummary getFinancialSummary() {
    final closed = _totalClosedJornadas();
    final expected = closed * dailyFee;
    final debt = totalDebtAmount();
    final paid = (expected - debt).clamp(0, expected).toDouble();
    return FleetFinancialSummary(
      expected: expected.toDouble(),
      paid: paid,
      debt: debt.toDouble(),
    );
  }
}
