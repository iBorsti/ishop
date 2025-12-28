import 'dart:math';

Future<Map<String, dynamic>> fetchDeliveryStats() async {
  // Simula latencia de red
  await Future.delayed(const Duration(seconds: 2));

  // Simula fallo aleatorio (20% de probabilidad)
  final rnd = Random().nextInt(10);
  if (rnd < 2) {
    throw Exception('Error al obtener datos del servidor');
  }

  // Datos fake
  return {
    'carreras': 12,
    'ingresos': 850,
    'kilometros': 34,
    'tiempoActivo': '6h 20m',
    'quota': {'quota': 1000, 'earned': 850},
    'chart': [5.0, 8.0, 6.0, 10.0, 9.0, 12.0, 11.0, 15.0, 13.0],
  };
}
