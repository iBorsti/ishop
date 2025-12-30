import 'package:flutter/foundation.dart';

import '../models/delivery_jornada.dart';
import '../services/delivery_jornada_service.dart';

class DeliveryJornadaController extends ChangeNotifier {
  final DeliveryJornadaService _service;

  DeliveryJornadaController(this._service);

  DeliveryJornada get jornada => _service.getCurrentJornada();

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
