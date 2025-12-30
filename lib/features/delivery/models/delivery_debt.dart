class DeliveryDebt {
  final int totalAmount;
  final int daysOwed;

  const DeliveryDebt({required this.totalAmount, required this.daysOwed});

  factory DeliveryDebt.empty() {
    return const DeliveryDebt(totalAmount: 0, daysOwed: 0);
  }

  DeliveryDebt addDay(int dailyFee) {
    return DeliveryDebt(
      totalAmount: totalAmount + dailyFee,
      daysOwed: daysOwed + 1,
    );
  }

  DeliveryDebt clear() {
    return DeliveryDebt.empty();
  }

  Map<String, dynamic> toJson() => {
    'totalAmount': totalAmount,
    'daysOwed': daysOwed,
  };

  factory DeliveryDebt.fromJson(Map<String, dynamic> json) {
    return DeliveryDebt(
      totalAmount: json['totalAmount'] as int? ?? 0,
      daysOwed: json['daysOwed'] as int? ?? 0,
    );
  }
}
