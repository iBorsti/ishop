import 'delivery_jornada_demo_repository.dart';
import 'delivery_jornada_repository.dart';

class DeliveryJornadaPilotRepository extends DeliveryJornadaDemoRepository
        implements DeliveryJornadaRepository {
    @override
    Future<void> resetDemoData() async {
        // No-op outside demo
    }
}
