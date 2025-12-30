import '../../../core/config/app_env.dart';
import 'fleet_jornada_repository.dart';
import 'fleet_jornada_demo_repository.dart';
import 'fleet_jornada_pilot_repository.dart';

FleetJornadaRepository buildFleetJornadaRepository() {
  switch (AppConfig.env) {
    case AppEnv.demo:
      return FleetJornadaDemoRepository();
    case AppEnv.pilot:
    case AppEnv.production:
      return FleetJornadaPilotRepository();
  }
}
