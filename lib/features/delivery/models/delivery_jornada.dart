enum JornadaStatus { notStarted, active, closed }

class DeliveryJornada {
  final DateTime date;
  final JornadaStatus status;
  final int dailyFee;
  final bool paid;

  DeliveryJornada({
    required this.date,
    required this.status,
    required this.dailyFee,
    required this.paid,
  });

  factory DeliveryJornada.todayNotStarted() {
    return DeliveryJornada(
      date: DateTime.now(),
      status: JornadaStatus.notStarted,
      dailyFee: 100,
      paid: false,
    );
  }

  DeliveryJornada copyWith({JornadaStatus? status, bool? paid}) {
    return DeliveryJornada(
      date: date,
      status: status ?? this.status,
      dailyFee: dailyFee,
      paid: paid ?? this.paid,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'status': status.name,
    'dailyFee': dailyFee,
    'paid': paid,
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
    );
  }
}
