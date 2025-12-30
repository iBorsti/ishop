import 'package:flutter/foundation.dart';

import '../models/delivery_jornada.dart';
import '../models/delivery_debt.dart';
import '../services/delivery_jornada_repository.dart';
import '../services/delivery_jornada_factory.dart';

class DeliveryJornadaController extends ChangeNotifier {
  final DeliveryJornadaRepository _service;

  bool _loading = true;
  bool get loading => _loading;

  DeliveryJornadaController([DeliveryJornadaRepository? service])
      : _service = service ?? buildDeliveryJornadaRepository();

  DeliveryJornada get jornada => _service.getCurrentJornada();
  DeliveryDebt get debt => _service.getDebt();

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    await _service.load();
    _loading = false;
    notifyListeners();
  }

  void startJornada() {
    _service.startJornada();
    notifyListeners();
  }

  void closeJornada({bool paid = false}) {
    _service.closeJornada(paid: paid);
    notifyListeners();
  }

  void markAsPaid() {
    _service.markAsPaid();
    notifyListeners();
  }
}
