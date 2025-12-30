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
}
