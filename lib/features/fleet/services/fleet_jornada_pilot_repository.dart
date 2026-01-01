import 'fleet_jornada_demo_repository.dart';
import 'fleet_jornada_repository.dart';

class FleetJornadaPilotRepository extends FleetJornadaDemoRepository
        implements FleetJornadaRepository {
    @override
    Future<void> resetDemoData() async {
        // No-op outside demo
    }
}
