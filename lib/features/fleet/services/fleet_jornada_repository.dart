import '../models/fleet_bike_debt.dart';
import '../models/fleet_bike_jornada.dart';
import '../models/fleet_financial_summary.dart';
import '../models/fleet_payment.dart';
import '../models/fleet_weekly_summary.dart';

abstract class FleetJornadaRepository {
  Future<void> load();
  FleetBikeJornada getJornada(String bikeId);
  FleetBikeDebt getDebt(String bikeId);
  void startJornada(String bikeId);
  void closeJornada(String bikeId, {bool paid});
  void markAsPaid(String bikeId);
  List<FleetBikeJornada> getBikeJornadaHistory(String bikeId);
  int totalDebtAmount();
  int totalDaysOwed();
  int totalBikes();
  int bikesWithDebtCount();
  FleetFinancialSummary getFinancialSummary();
  void recordPayment({required double amount, required int bikesCovered});
  List<FleetPayment> getPaymentHistory();
  FleetWeeklySummary getWeeklySummary(DateTime date);
}
