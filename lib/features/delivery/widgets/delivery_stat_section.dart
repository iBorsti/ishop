import 'package:flutter/material.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/theme/app_colors.dart';

class DeliveryStatSection extends StatelessWidget {
  final Map<String, dynamic>? data;

  const DeliveryStatSection({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        StatCard(
          title: 'Carreras',
          value: '${data?['carreras'] ?? 0}',
          icon: Icons.motorcycle,
          backgroundColor: AppColors.turquoise,
        ),
        StatCard(
          title: 'Ingresos',
          value: 'C\$ ${data?['ingresos'] ?? 0}',
          icon: Icons.attach_money,
          backgroundColor: AppColors.successGreen,
        ),
        StatCard(
          title: 'Kilómetros',
          value: '${data?['kilometros'] ?? 0} km',
          icon: Icons.route,
          backgroundColor: AppColors.secondaryBlue,
        ),
        StatCard(
          title: 'Tiempo activo',
          value: '${data?['tiempoActivo'] ?? '-'}',
          icon: Icons.access_time,
          backgroundColor: AppColors.warningYellow,
        ),
      ],
    );
  }
}
