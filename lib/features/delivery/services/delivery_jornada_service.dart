import '../models/delivery_debt.dart';
import '../models/delivery_jornada.dart';
import '../models/delivery_payment.dart';
import '../models/delivery_weekly_summary.dart';
import 'delivery_jornada_repository.dart';
import 'delivery_jornada_factory.dart';

// Legacy service wrapper to keep existing imports working. Prefer using
// DeliveryJornadaRepository directly via buildDeliveryJornadaRepository().
class DeliveryJornadaService {
  final DeliveryJornadaRepository _repo = buildDeliveryJornadaRepository();

  Future<void> load() => _repo.load();
  DeliveryJornada getCurrentJornada() => _repo.getCurrentJornada();
  DeliveryDebt getDebt() => _repo.getDebt();
  List<DeliveryJornada> getJornadaHistory({DateTime? from, DateTime? to}) =>
      _repo.getJornadaHistory(from: from, to: to);
  List<DeliveryPayment> getPaymentHistory() => _repo.getPaymentHistory();
  void startJornada() => _repo.startJornada();
  void closeJornada({bool paid = false}) => _repo.closeJornada(paid: paid);
  void markAsPaid() => _repo.markAsPaid();
  void recordPayment({required double amount, required int jornadasCovered}) =>
      _repo.recordPayment(amount: amount, jornadasCovered: jornadasCovered);
  DeliveryWeeklySummary getWeeklySummary(DateTime date) =>
      _repo.getWeeklySummary(date);
}
