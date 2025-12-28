import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuotaProgressCard extends StatelessWidget {
  final num quota;
  final num earned;

  const QuotaProgressCard({super.key, required this.quota, required this.earned});

  @override
  Widget build(BuildContext context) {
    final double q = quota == 0 ? 1.0 : quota.toDouble();
    final double e = earned.toDouble();
    final progress = (e / q).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuota diaria',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.withAlpha(40),
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'C\$ ${earned} / C\$ ${quota}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
