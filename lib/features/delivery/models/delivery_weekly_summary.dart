class DeliveryWeeklySummary {
  final int worked;
  final int paid;
  final int pending;
  final double pendingAmount;

  const DeliveryWeeklySummary({
    required this.worked,
    required this.paid,
    required this.pending,
    required this.pendingAmount,
  });
}
