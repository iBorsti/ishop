import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import 'widgets/availability_toggle.dart';
import 'widgets/quota_progress_card.dart';

class DeliveryDashboard extends StatelessWidget {
  const DeliveryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AvailabilityToggle(),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: const [
                StatCard(
                  title: 'Carreras',
                  value: '12',
                  icon: Icons.motorcycle,
                  backgroundColor: AppColors.primaryBlue,
                ),
                StatCard(
                  title: 'Ingresos',
                  value: 'C\$ 850',
                  icon: Icons.attach_money,
                  backgroundColor: AppColors.successGreen,
                ),
                StatCard(
                  title: 'Kilómetros',
                  value: '34 km',
                  icon: Icons.route,
                  backgroundColor: AppColors.secondaryBlue,
                ),
                StatCard(
                  title: 'Tiempo activo',
                  value: '6h 20m',
                  icon: Icons.access_time,
                  backgroundColor: AppColors.warningOrange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const QuotaProgressCard(),
          ],
        ),
      ),
    );
  }
}
