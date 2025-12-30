import 'models/alert_level.dart';

AlertLevel resolveAlertLevel({required int daysOwed}) {
  if (daysOwed >= 5) return AlertLevel.critical;
  if (daysOwed >= 3) return AlertLevel.warning;
  if (daysOwed >= 1) return AlertLevel.info;
  return AlertLevel.none;
}
