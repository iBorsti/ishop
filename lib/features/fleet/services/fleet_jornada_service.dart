import '../models/fleet_bike_debt.dart';
import '../models/fleet_bike_jornada.dart';
import '../models/fleet_financial_summary.dart';
import '../models/fleet_payment.dart';
import '../models/fleet_weekly_summary.dart';
import 'fleet_jornada_repository.dart';
import 'fleet_jornada_factory.dart';

// Legacy service wrapper to keep existing imports working. Prefer using
// FleetJornadaRepository directly via buildFleetJornadaRepository().
class FleetJornadaService {
  final FleetJornadaRepository _repo = buildFleetJornadaRepository();

  Future<void> load() => _repo.load();
  FleetBikeJornada getJornada(String bikeId) => _repo.getJornada(bikeId);
  FleetBikeDebt getDebt(String bikeId) => _repo.getDebt(bikeId);
  void startJornada(String bikeId) => _repo.startJornada(bikeId);
  void closeJornada(String bikeId, {bool paid = false}) =>
      _repo.closeJornada(bikeId, paid: paid);
  void markAsPaid(String bikeId) => _repo.markAsPaid(bikeId);
  List<FleetBikeJornada> getBikeJornadaHistory(String bikeId) =>
      _repo.getBikeJornadaHistory(bikeId);
  int totalDebtAmount() => _repo.totalDebtAmount();
  int totalDaysOwed() => _repo.totalDaysOwed();
  int totalBikes() => _repo.totalBikes();
  int bikesWithDebtCount() => _repo.bikesWithDebtCount();
  FleetFinancialSummary getFinancialSummary() => _repo.getFinancialSummary();
  void recordPayment({required double amount, required int bikesCovered}) =>
      _repo.recordPayment(amount: amount, bikesCovered: bikesCovered);
  List<FleetPayment> getPaymentHistory() => _repo.getPaymentHistory();
  FleetWeeklySummary getWeeklySummary(DateTime date) =>
      _repo.getWeeklySummary(date);
}
