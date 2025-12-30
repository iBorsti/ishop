import '../../../core/config/app_env.dart';
import 'delivery_jornada_repository.dart';
import 'delivery_jornada_demo_repository.dart';
import 'delivery_jornada_pilot_repository.dart';

DeliveryJornadaRepository buildDeliveryJornadaRepository() {
  switch (AppConfig.env) {
    case AppEnv.demo:
      return DeliveryJornadaDemoRepository();
    case AppEnv.pilot:
    case AppEnv.production:
      return DeliveryJornadaPilotRepository();
  }
}
