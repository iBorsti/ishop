import 'package:flutter/material.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/theme/app_colors.dart';
import '../models/admin_overview.dart';

class AdminStatSection extends StatelessWidget {
  final AdminOverview overview;

  const AdminStatSection({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 260,
          child: StatCard(
            title: 'Usuarios activos',
            value: overview.activeUsers.toString(),
            icon: Icons.people,
            backgroundColor: AppColors.info,
          ),
        ),
        SizedBox(
          width: 260,
          child: StatCard(
            title: 'Órdenes hoy',
            value: overview.ordersToday.toString(),
            icon: Icons.shopping_cart,
            backgroundColor: AppColors.turquoise,
          ),
        ),
        SizedBox(
          width: 260,
          child: StatCard(
            title: 'Deliveries activos',
            value: overview.activeDeliveries.toString(),
            icon: Icons.local_shipping,
            backgroundColor: AppColors.warningYellow,
          ),
        ),
        SizedBox(
          width: 260,
          child: StatCard(
            title: 'Ingresos estimados',
            value: '\$${overview.estimatedRevenue.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            backgroundColor: AppColors.successGreen,
          ),
        ),
      ],
    );
  }
}
