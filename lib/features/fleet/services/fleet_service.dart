import '../models/fleet_stats.dart';

class FleetService {
  static FleetStats getStats() {
    return FleetStats.fake();
  }

  // Motos fake: id, alias, driver, status, quotaPaid
  static List<Map<String, dynamic>> getMotos() {
    return [
      {
        'id': 'M-001',
        'alias': 'Fénix',
        'driver': 'Juan',
        'status': 'active',
        'quotaPaid': true,
        'lat': 10.0,
        'lon': -84.0,
      },
      {
        'id': 'M-002',
        'alias': 'Rayo',
        'driver': 'María',
        'status': 'pause',
        'quotaPaid': false,
        'lat': 10.01,
        'lon': -84.01,
      },
      {
        'id': 'M-003',
        'alias': 'Sombra',
        'driver': 'Carlos',
        'status': 'inactive',
        'quotaPaid': false,
        'lat': 9.99,
        'lon': -84.02,
      },
      {
        'id': 'M-004',
        'alias': 'Luna',
        'driver': 'Ana',
        'status': 'active',
        'quotaPaid': true,
        'lat': 10.02,
        'lon': -84.03,
      },
      {
        'id': 'M-005',
        'alias': 'Rocío',
        'driver': 'Pedro',
        'status': 'active',
        'quotaPaid': false,
        'lat': 10.03,
        'lon': -84.04,
      },
    ];
  }
}
