enum FleetJornadaStatus { notStarted, active, closed }

class FleetBikeJornada {
  final String bikeId;
  final DateTime date;
  final FleetJornadaStatus status;
  final int dailyFee;
  final bool paid;

  const FleetBikeJornada({
    required this.bikeId,
    required this.date,
    required this.status,
    required this.dailyFee,
    required this.paid,
  });

  factory FleetBikeJornada.notStarted(String bikeId, {int dailyFee = 50}) {
    return FleetBikeJornada(
      bikeId: bikeId,
      date: DateTime.now(),
      status: FleetJornadaStatus.notStarted,
      dailyFee: dailyFee,
      paid: false,
    );
  }

  FleetBikeJornada copyWith({
    FleetJornadaStatus? status,
    bool? paid,
    DateTime? date,
  }) {
    return FleetBikeJornada(
      bikeId: bikeId,
      date: date ?? this.date,
      status: status ?? this.status,
      dailyFee: dailyFee,
      paid: paid ?? this.paid,
    );
  }

  Map<String, dynamic> toJson() => {
    'bikeId': bikeId,
    'date': date.toIso8601String(),
    'status': status.name,
    'dailyFee': dailyFee,
    'paid': paid,
  };

  factory FleetBikeJornada.fromJson(Map<String, dynamic> json) {
    return FleetBikeJornada(
      bikeId: json['bikeId'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      status: FleetJornadaStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? ''),
        orElse: () => FleetJornadaStatus.notStarted,
      ),
      dailyFee: json['dailyFee'] as int? ?? 50,
      paid: json['paid'] as bool? ?? false,
    );
  }
}
