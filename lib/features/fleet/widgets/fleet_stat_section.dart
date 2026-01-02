import 'package:flutter/material.dart';
import '../../../core/widgets/stat_card.dart';
import '../models/fleet_stats.dart';
import '../../../core/theme/app_colors.dart';

class FleetStatSection extends StatelessWidget {
  final FleetStats stats;

  const FleetStatSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen rápido',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Motos activas',
                value: stats.activeMotos.toString(),
                icon: Icons.directions_bike,
                backgroundColor: AppColors.turquoise,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Repartidores',
                value: stats.activeDrivers.toString(),
                icon: Icons.person,
                backgroundColor: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Ingresos hoy',
                value: 'C\$ ${stats.todayEarnings.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                backgroundColor: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Cuotas pendientes',
                value: stats.pendingQuotas.toString(),
                icon: Icons.warning,
                backgroundColor: AppColors.warningYellow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
