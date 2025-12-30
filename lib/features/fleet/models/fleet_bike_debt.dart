class FleetBikeDebt {
  final int totalAmount;
  final int daysOwed;

  const FleetBikeDebt({required this.totalAmount, required this.daysOwed});

  factory FleetBikeDebt.empty() {
    return const FleetBikeDebt(totalAmount: 0, daysOwed: 0);
  }

  FleetBikeDebt addDay(int dailyFee) {
    return FleetBikeDebt(
      totalAmount: totalAmount + dailyFee,
      daysOwed: daysOwed + 1,
    );
  }

  FleetBikeDebt clear() {
    return FleetBikeDebt.empty();
  }

  Map<String, dynamic> toJson() => {
    'totalAmount': totalAmount,
    'daysOwed': daysOwed,
  };

  factory FleetBikeDebt.fromJson(Map<String, dynamic> json) {
    return FleetBikeDebt(
      totalAmount: json['totalAmount'] as int? ?? 0,
      daysOwed: json['daysOwed'] as int? ?? 0,
    );
  }
}
