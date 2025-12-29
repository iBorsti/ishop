class FleetStats {
  final int activeMotos;
  final int activeDrivers;
  final double todayEarnings;
  final int pendingQuotas;

  FleetStats({
    required this.activeMotos,
    required this.activeDrivers,
    required this.todayEarnings,
    required this.pendingQuotas,
  });

  factory FleetStats.fake() {
    return FleetStats(
      activeMotos: 8,
      activeDrivers: 7,
      todayEarnings: 3450,
      pendingQuotas: 3,
    );
  }
}
