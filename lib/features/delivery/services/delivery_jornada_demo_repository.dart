import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/delivery_jornada.dart';
import '../models/delivery_debt.dart';
import '../models/delivery_payment.dart';
import '../models/delivery_weekly_summary.dart';
import '../../../core/utils/week_utils.dart';
import '../../../core/config/app_env.dart';
import 'delivery_jornada_repository.dart';

class DeliveryJornadaDemoRepository implements DeliveryJornadaRepository {
  DeliveryJornada _jornada = DeliveryJornada.todayNotStarted();
  DeliveryDebt _debt = DeliveryDebt.empty();
  final List<DeliveryJornada> _history = [];
  final List<DeliveryPayment> _payments = [];
  bool _loaded = false;

  String get _envKeyPrefix {
    switch (AppConfig.env) {
      case AppEnv.demo:
        return 'demo_';
      case AppEnv.pilot:
        return 'pilot_';
      case AppEnv.production:
        return 'prod_';
    }
  }
  
  @override
  Future<void> resetDemoData() async {
    if (!AppConfig.isDemo) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kJornadaKey);
    await prefs.remove(_kDebtKey);
    await prefs.remove(_kHistoryKey);
    await prefs.remove(_kPaymentsKey);
    _jornada = DeliveryJornada.todayNotStarted();
    _debt = DeliveryDebt.empty();
    _history.clear();
    _payments.clear();
    _loaded = false;
  }

  String get _kJornadaKey => '${_envKeyPrefix}delivery_jornada';
  String get _kDebtKey => '${_envKeyPrefix}delivery_debt';
  String get _kHistoryKey => '${_envKeyPrefix}delivery_history';
  String get _kPaymentsKey => '${_envKeyPrefix}delivery_payments';

  @override
  DeliveryJornada getCurrentJornada() {
    return _jornada;
  }

  @override
  DeliveryDebt getDebt() {
    return _debt;
  }

  @override
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

  @override
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawJ = prefs.getString(_kJornadaKey);
    final rawD = prefs.getString(_kDebtKey);
    final rawH = prefs.getString(_kHistoryKey);
    final rawP = prefs.getString(_kPaymentsKey);
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
    if (rawP != null) {
      try {
        final decoded = json.decode(rawP) as List;
        _payments
          ..clear()
          ..addAll(
            decoded
                .map((e) => DeliveryPayment.fromJson(
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
    await prefs.setString(
      _kPaymentsKey,
      json.encode(_payments.map((p) => p.toJson()).toList()),
    );
  }

  @override
  void startJornada() {
    _jornada = _jornada.copyWith(status: JornadaStatus.active);
    _persist();
  }

  @override
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

  @override
  void markAsPaid() {
    final amount = (_debt.totalAmount + _jornada.dailyFee).toDouble();
    final covered = _debt.daysOwed + 1;
    recordPayment(amount: amount, jornadasCovered: covered);
  }

  @override
  void recordPayment({
    required double amount,
    required int jornadasCovered,
    String recordedBy = 'delivery',
  }) {
    if (amount <= 0 || jornadasCovered <= 0) return;
    _payments.add(
      DeliveryPayment(
        id: const Uuid().v4(),
        paidAt: DateTime.now(),
        amount: amount,
        jornadasCovered: jornadasCovered,
        recordedBy: recordedBy,
      ),
    );

    _jornada = _jornada.copyWith(paid: true);
    _debt = _debt.clear();
    _persist();
  }

  @override
  List<DeliveryPayment> getPaymentHistory() =>
      List.unmodifiable(_payments.reversed);

  @override
  DeliveryWeeklySummary getWeeklySummary(DateTime date) {
    final start = startOfWeek(date);
    final end = endOfWeek(date);

    int worked = 0;
    int paid = 0;
    int pending = 0;
    double pendingAmount = 0;

    Iterable<DeliveryJornada> candidates = _history;

    if (_jornada.date.isAfter(start.subtract(const Duration(days: 1))) &&
        _jornada.date.isBefore(end.add(const Duration(days: 1)))) {
      candidates = [..._history, _jornada];
    }

    for (final j in candidates) {
      final reference = j.closedAt ?? j.date;
      if (reference.isBefore(start) || reference.isAfter(end)) continue;
      worked += 1;
      if (j.paid) {
        paid += 1;
      } else {
        pending += 1;
        pendingAmount += j.dailyFee.toDouble();
      }
    }

    return DeliveryWeeklySummary(
      worked: worked,
      paid: paid,
      pending: pending,
      pendingAmount: pendingAmount,
    );
  }
}
