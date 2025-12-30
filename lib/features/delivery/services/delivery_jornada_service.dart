import '../models/delivery_jornada.dart';

class DeliveryJornadaService {
  DeliveryJornada _jornada = DeliveryJornada.todayNotStarted();

  DeliveryJornada getCurrentJornada() {
    return _jornada;
  }

  void startJornada() {
    _jornada = _jornada.copyWith(status: JornadaStatus.active);
  }

  void closeJornada({bool paid = false}) {
    _jornada = _jornada.copyWith(status: JornadaStatus.closed, paid: paid);
  }

  void markAsPaid() {
    _jornada = _jornada.copyWith(paid: true);
  }
}
