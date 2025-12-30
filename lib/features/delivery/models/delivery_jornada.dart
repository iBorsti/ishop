enum JornadaStatus { notStarted, active, closed }

class DeliveryJornada {
  final DateTime date;
  final JornadaStatus status;
  final int dailyFee;
  final bool paid;
  final DateTime? closedAt;

  DeliveryJornada({
    required this.date,
    required this.status,
    required this.dailyFee,
    required this.paid,
    this.closedAt,
  });

  factory DeliveryJornada.todayNotStarted() {
    return DeliveryJornada(
      date: DateTime.now(),
      status: JornadaStatus.notStarted,
      dailyFee: 100,
      paid: false,
      closedAt: null,
    );
  }

  DeliveryJornada copyWith({
    JornadaStatus? status,
    bool? paid,
    DateTime? closedAt,
  }) {
    return DeliveryJornada(
      date: date,
      status: status ?? this.status,
      dailyFee: dailyFee,
      paid: paid ?? this.paid,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  bool get isClosed => status == JornadaStatus.closed;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'status': status.name,
    'dailyFee': dailyFee,
    'paid': paid,
    'closedAt': closedAt?.toIso8601String(),
  };

  factory DeliveryJornada.fromJson(Map<String, dynamic> json) {
    return DeliveryJornada(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      status: JornadaStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? ''),
        orElse: () => JornadaStatus.notStarted,
      ),
      dailyFee: json['dailyFee'] as int? ?? 100,
      paid: json['paid'] as bool? ?? false,
      closedAt: DateTime.tryParse(json['closedAt'] as String? ?? ''),
    );
  }
}
