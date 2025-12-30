import '../models/delivery_debt.dart';
import '../models/delivery_jornada.dart';
import '../models/delivery_payment.dart';
import '../models/delivery_weekly_summary.dart';

abstract class DeliveryJornadaRepository {
  Future<void> load();
  DeliveryJornada getCurrentJornada();
  DeliveryDebt getDebt();
  List<DeliveryJornada> getJornadaHistory({DateTime? from, DateTime? to});
  List<DeliveryPayment> getPaymentHistory();
  void startJornada();
  void closeJornada({bool paid});
  void markAsPaid();
  void recordPayment({required double amount, required int jornadasCovered});
  DeliveryWeeklySummary getWeeklySummary(DateTime date);
}
