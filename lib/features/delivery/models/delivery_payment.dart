class DeliveryPayment {
  final String id;
  final DateTime paidAt;
  final double amount;
  final int jornadasCovered;
  final String recordedBy;

  DeliveryPayment({
    required this.id,
    required this.paidAt,
    required this.amount,
    required this.jornadasCovered,
    required this.recordedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'paidAt': paidAt.toIso8601String(),
        'amount': amount,
        'jornadasCovered': jornadasCovered,
        'recordedBy': recordedBy,
      };

  factory DeliveryPayment.fromJson(Map<String, dynamic> json) {
    return DeliveryPayment(
      id: json['id'] as String? ?? '',
      paidAt: DateTime.tryParse(json['paidAt'] as String? ?? '') ??
          DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      jornadasCovered: json['jornadasCovered'] as int? ?? 0,
      recordedBy: json['recordedBy'] as String? ?? 'delivery',
    );
  }
}
