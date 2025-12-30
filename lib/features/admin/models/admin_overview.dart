// AdminOverview model
class AdminOverview {
  final int activeUsers;
  final int ordersToday;
  final int activeDeliveries;
  final double estimatedRevenue;

  const AdminOverview({
    required this.activeUsers,
    required this.ordersToday,
    required this.activeDeliveries,
    required this.estimatedRevenue,
  });

  factory AdminOverview.fake() => const AdminOverview(
    activeUsers: 1245,
    ordersToday: 342,
    activeDeliveries: 58,
    estimatedRevenue: 12456.75,
  );
}
