class FleetPayment {
  final String id;
  final DateTime paidAt;
  final double amount;
  final int bikesCovered;
  final String recordedBy;

  FleetPayment({
    required this.id,
    required this.paidAt,
    required this.amount,
    required this.bikesCovered,
    required this.recordedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'paidAt': paidAt.toIso8601String(),
        'amount': amount,
        'bikesCovered': bikesCovered,
        'recordedBy': recordedBy,
      };

  factory FleetPayment.fromJson(Map<String, dynamic> json) {
    return FleetPayment(
      id: json['id'] as String? ?? '',
      paidAt: DateTime.tryParse(json['paidAt'] as String? ?? '') ??
          DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      bikesCovered: json['bikesCovered'] as int? ?? 0,
      recordedBy: json['recordedBy'] as String? ?? 'admin',
    );
  }
}
