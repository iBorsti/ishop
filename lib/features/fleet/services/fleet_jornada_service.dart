import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/fleet_bike_jornada.dart';
import '../models/fleet_bike_debt.dart';
import '../models/fleet_financial_summary.dart';
import '../models/fleet_payment.dart';
import '../models/fleet_weekly_summary.dart';
import '../../../core/utils/week_utils.dart';

class FleetJornadaService {
  final Map<String, FleetBikeJornada> _jornadas = {};
  final Map<String, FleetBikeDebt> _debts = {};
  final Map<String, List<FleetBikeJornada>> _history = {};
  final List<FleetPayment> _payments = [];
  bool _loaded = false;

  static const int dailyFee = 50;
  static const _kJornadasKey = 'fleet_jornadas';
  static const _kDebtsKey = 'fleet_debts';
  static const _kHistoryKey = 'fleet_history';
  static const _kPaymentsKey = 'fleet_payments';

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawJ = prefs.getString(_kJornadasKey);
    final rawD = prefs.getString(_kDebtsKey);
    final rawH = prefs.getString(_kHistoryKey);
    final rawP = prefs.getString(_kPaymentsKey);
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
    if (rawP != null) {
      try {
        final decoded = json.decode(rawP) as List;
        _payments
          ..clear()
          ..addAll(
            decoded
                .map((e) => FleetPayment.fromJson(
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
    final jMap = _jornadas.map((k, v) => MapEntry(k, v.toJson()));
    final dMap = _debts.map((k, v) => MapEntry(k, v.toJson()));
    final hMap = _history.map(
      (k, v) => MapEntry(k, v.map((j) => j.toJson()).toList()),
    );
    final pList = _payments.map((p) => p.toJson()).toList();
    await prefs.setString(_kJornadasKey, json.encode(jMap));
    await prefs.setString(_kDebtsKey, json.encode(dMap));
    await prefs.setString(_kHistoryKey, json.encode(hMap));
    await prefs.setString(_kPaymentsKey, json.encode(pList));
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

  void clearAllDebts() {
    _debts.updateAll((key, value) => FleetBikeDebt.empty());
    _jornadas.updateAll(
      (key, value) => value.copyWith(paid: true),
    );
  }

  void recordPayment({
    required double amount,
    required int bikesCovered,
    String recordedBy = 'admin',
  }) {
    if (amount <= 0 || bikesCovered <= 0) return;
    _payments.add(
      FleetPayment(
        id: const Uuid().v4(),
        paidAt: DateTime.now(),
        amount: amount,
        bikesCovered: bikesCovered,
        recordedBy: recordedBy,
      ),
    );

    clearAllDebts();
    _persist();
  }

  List<FleetPayment> getPaymentHistory() =>
      List.unmodifiable(_payments.reversed);

  int totalDebtAmount() =>
      _debts.values.fold(0, (sum, d) => sum + d.totalAmount);
  int totalDaysOwed() => _debts.values.fold(0, (sum, d) => sum + d.daysOwed);
  int totalBikes() => _jornadas.length;
  int bikesWithDebtCount() =>
      _debts.values.where((d) => d.totalAmount > 0).length;

  FleetWeeklySummary getWeeklySummary(DateTime date) {
    final start = startOfWeek(date);
    final end = endOfWeek(date);

    int bikeJornadas = 0;
    int debtDays = 0;
    double debtAmount = 0;

    // Count jornada history within week
    for (final entry in _history.entries) {
      for (final j in entry.value) {
        final reference = j.closedAt ?? j.date;
        if (reference.isBefore(start) || reference.isAfter(end)) continue;
        bikeJornadas += 1;
        if (!j.paid) {
          debtDays += 1;
          debtAmount += j.dailyFee.toDouble();
        }
      }
    }

    // Include current jornadas if in week
    for (final j in _jornadas.values) {
      final reference = j.closedAt ?? j.date;
      if (reference.isBefore(start) || reference.isAfter(end)) continue;
      bikeJornadas += 1;
      if (!j.paid) {
        debtDays += 1;
        debtAmount += j.dailyFee.toDouble();
      }
    }

    final activeBikes = _jornadas.length;

    return FleetWeeklySummary(
      activeBikes: activeBikes,
      bikeJornadas: bikeJornadas,
      debtDays: debtDays,
      debtAmount: debtAmount,
    );
  }

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
