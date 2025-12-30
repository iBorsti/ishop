enum FleetJornadaStatus { notStarted, active, closed }

class FleetBikeJornada {
  final String bikeId;
  final DateTime date;
  final FleetJornadaStatus status;
  final int dailyFee;
  final bool paid;
  final DateTime? closedAt;

  const FleetBikeJornada({
    required this.bikeId,
    required this.date,
    required this.status,
    required this.dailyFee,
    required this.paid,
    this.closedAt,
  });

  factory FleetBikeJornada.notStarted(String bikeId, {int dailyFee = 50}) {
    return FleetBikeJornada(
      bikeId: bikeId,
      date: DateTime.now(),
      status: FleetJornadaStatus.notStarted,
      dailyFee: dailyFee,
      paid: false,
      closedAt: null,
    );
  }

  FleetBikeJornada copyWith({
    FleetJornadaStatus? status,
    bool? paid,
    DateTime? date,
    DateTime? closedAt,
  }) {
    return FleetBikeJornada(
      bikeId: bikeId,
      date: date ?? this.date,
      status: status ?? this.status,
      dailyFee: dailyFee,
      paid: paid ?? this.paid,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  bool get isClosed => status == FleetJornadaStatus.closed;

  Map<String, dynamic> toJson() => {
    'bikeId': bikeId,
    'date': date.toIso8601String(),
    'status': status.name,
    'dailyFee': dailyFee,
    'paid': paid,
    'closedAt': closedAt?.toIso8601String(),
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
      closedAt: DateTime.tryParse(json['closedAt'] as String? ?? ''),
    );
  }
}
