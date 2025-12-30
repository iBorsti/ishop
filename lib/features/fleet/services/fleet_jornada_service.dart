import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fleet_bike_jornada.dart';
import '../models/fleet_bike_debt.dart';
import '../models/fleet_financial_summary.dart';

class FleetJornadaService {
  final Map<String, FleetBikeJornada> _jornadas = {};
  final Map<String, FleetBikeDebt> _debts = {};
  bool _loaded = false;

  static const int dailyFee = 50;
  static const _kJornadasKey = 'fleet_jornadas';
  static const _kDebtsKey = 'fleet_debts';

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawJ = prefs.getString(_kJornadasKey);
    final rawD = prefs.getString(_kDebtsKey);
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
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jMap = _jornadas.map((k, v) => MapEntry(k, v.toJson()));
    final dMap = _debts.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_kJornadasKey, json.encode(jMap));
    await prefs.setString(_kDebtsKey, json.encode(dMap));
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
    _jornadas[bikeId] = current.copyWith(
      status: FleetJornadaStatus.closed,
      paid: paid,
    );
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
