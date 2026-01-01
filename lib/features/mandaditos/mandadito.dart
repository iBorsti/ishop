enum MandaditoStatus {
  open,
  taken,
  completed,
}

class Mandadito {
  final String id;
  final String origin;
  final String description;
  final String destination;
  final bool urgent;
  final double? budget;
  final MandaditoStatus status;

  const Mandadito({
    required this.id,
    required this.origin,
    required this.description,
    required this.destination,
    required this.urgent,
    required this.budget,
    required this.status,
  });

  Mandadito copyWith({MandaditoStatus? status}) {
    return Mandadito(
      id: id,
      origin: origin,
      description: description,
      destination: destination,
      urgent: urgent,
      budget: budget,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'origin': origin,
        'description': description,
        'destination': destination,
        'urgent': urgent,
        'budget': budget,
        'status': status.name,
      };

  factory Mandadito.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String?;
    final status = MandaditoStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => MandaditoStatus.open,
    );
    return Mandadito(
      id: json['id'] as String,
      origin: json['origin'] as String? ?? '',
      description: json['description'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      urgent: json['urgent'] as bool? ?? false,
      budget: (json['budget'] as num?)?.toDouble(),
      status: status,
    );
  }
}
