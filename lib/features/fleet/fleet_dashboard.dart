import 'package:flutter/material.dart';
import 'services/fleet_service.dart';
import 'widgets/fleet_stat_section.dart';
import 'widgets/quota_overview_card.dart';
import 'widgets/fleet_map_placeholder.dart';
import 'widgets/moto_status_card.dart';
import 'widgets/fleet_bike_jornada_card.dart';
import '../../core/widgets/dashboard_scaffold.dart';
import '../../core/widgets/dashboard_section_title.dart';

class FleetDashboard extends StatelessWidget {
  const FleetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = FleetService.getStats();

    return DashboardScaffold(
      title: 'Flota',
      children: [
        const DashboardSectionTitle('Resumen'),
        FleetStatSection(stats: stats),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Cuotas'),
        QuotaOverviewCard(stats: stats),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Jornadas por moto'),
        const FleetBikeJornadaList(),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Mapa'),
        const FleetMapPlaceholder(),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Motos'),
        MotoStatusList(),
      ],
    );
  }
}
