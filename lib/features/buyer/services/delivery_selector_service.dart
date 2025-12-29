import '../models/delivery_option.dart';

class DeliverySelectorService {
  static List<DeliveryOption> getOptions() {
    return [
      DeliveryOption(name: 'Juan (moto)', price: 50, etaMinutes: 15),
      DeliveryOption(name: 'AR Delivery', price: 60, etaMinutes: 12),
      DeliveryOption(name: 'Delivery independiente', price: 45, etaMinutes: 20),
    ];
  }
}
