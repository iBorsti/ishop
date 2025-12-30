import 'package:intl/intl.dart';

DateTime startOfWeek(DateTime date) {
  final weekday = date.weekday; // 1 = Monday
  return DateTime(date.year, date.month, date.day)
      .subtract(Duration(days: weekday - 1));
}

DateTime endOfWeek(DateTime date) {
  final start = startOfWeek(date);
  return start.add(const Duration(
      days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
}

String weekRangeLabel(DateTime date) {
  final start = startOfWeek(date);
  final end = endOfWeek(date);
  final fmtDay = DateFormat('d');
  final fmtMonth = DateFormat('MMMM');
  final fmtYear = DateFormat('y');
  final sameMonth = start.month == end.month && start.year == end.year;
  final startPart = '${fmtDay.format(start)} de ${fmtMonth.format(start)}';
  final endPart = sameMonth
      ? fmtDay.format(end)
      : '${fmtDay.format(end)} de ${fmtMonth.format(end)}';
  return 'Semana del $startPart al $endPart de ${fmtYear.format(end)}';
}
