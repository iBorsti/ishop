// AdminActivity model
class AdminActivity {
  final String message;
  final DateTime timestamp;
  final String type; // order, delivery, system

  const AdminActivity({
    required this.message,
    required this.timestamp,
    required this.type,
  });

  factory AdminActivity.fakeOrder() => AdminActivity(
    message:
        'Orden #${1000 + DateTime.now().millisecondsSinceEpoch % 900} creada',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    type: 'order',
  );

  factory AdminActivity.fakeDelivery() => AdminActivity(
    message:
        'Repartidor asignado a la orden #${1000 + DateTime.now().millisecondsSinceEpoch % 900}',
    timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    type: 'delivery',
  );

  factory AdminActivity.fakeSystem() => AdminActivity(
    message: 'Backup diario completado',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    type: 'system',
  );
}
