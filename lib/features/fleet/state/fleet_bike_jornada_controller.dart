import 'package:flutter/foundation.dart';

import '../models/fleet_bike_debt.dart';
import '../models/fleet_bike_jornada.dart';
import '../services/fleet_jornada_repository.dart';
import '../services/fleet_jornada_factory.dart';

class FleetBikeJornadaController extends ChangeNotifier {
  final FleetJornadaRepository _service;
  final String bikeId;

  bool _loading = true;
  bool get loading => _loading;

  FleetBikeJornadaController(
    FleetJornadaRepository? service, {
    required this.bikeId,
  }) : _service = service ?? buildFleetJornadaRepository();

  FleetBikeJornada get jornada => _service.getJornada(bikeId);
  FleetBikeDebt get debt => _service.getDebt(bikeId);

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    await _service.load();
    // Ensure maps are populated for this bike
    _service.getJornada(bikeId);
    _service.getDebt(bikeId);
    _loading = false;
    notifyListeners();
  }

  void startJornada() {
    _service.startJornada(bikeId);
    notifyListeners();
  }

  void closeJornada({bool paid = false}) {
    _service.closeJornada(bikeId, paid: paid);
    notifyListeners();
  }

  void markAsPaid() {
    _service.markAsPaid(bikeId);
    notifyListeners();
  }
}
