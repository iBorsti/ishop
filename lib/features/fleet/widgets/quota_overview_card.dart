import 'package:flutter/material.dart';
import '../models/fleet_stats.dart';
// AppColors not required here

class QuotaOverviewCard extends StatelessWidget {
  final FleetStats stats;

  const QuotaOverviewCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Fake: consider quota target equal to activeMotos * 5 (example)
    final total = (stats.activeMotos * 5).toDouble();
    final completed = (total - stats.pendingQuotas * 5).clamp(0, total);
    final progress = (completed / total).clamp(0.0, 1.0);

    Color color;
    if (progress >= 0.9) {
      color = Colors.green;
    } else if (progress >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuotas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text('Cumplidas: ${completed.toInt()} / ${total.toInt()}'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.withAlpha(30),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
