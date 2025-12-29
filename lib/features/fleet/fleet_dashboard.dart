import 'package:flutter/material.dart';
import 'services/fleet_service.dart';
import 'widgets/fleet_stat_section.dart';
import 'widgets/quota_overview_card.dart';
import 'widgets/fleet_map_placeholder.dart';
import 'widgets/moto_status_card.dart';

class FleetDashboard extends StatelessWidget {
  const FleetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = FleetService.getStats();

    return Scaffold(
      appBar: AppBar(title: const Text('Flota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FleetStatSection(stats: stats),
            const SizedBox(height: 16),
            QuotaOverviewCard(stats: stats),
            const SizedBox(height: 16),
            const FleetMapPlaceholder(),
            const SizedBox(height: 16),
            MotoStatusList(),
          ],
        ),
      ),
    );
  }
}
