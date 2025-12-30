import 'package:flutter/material.dart';

import '../models/fleet_financial_summary.dart';
import '../../../core/theme/app_colors.dart';

class FleetFinancialSummaryCard extends StatelessWidget {
  final FleetFinancialSummary summary;

  const FleetFinancialSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final expected = summary.expected;
    final paid = summary.paid;
    final debt = summary.debt;
    final progress = expected > 0 ? (paid / expected).clamp(0.0, 1.0) : 0.0;

    Color barColor;
    if (progress >= 0.9) {
      barColor = AppColors.successGreen;
    } else if (progress >= 0.6) {
      barColor = AppColors.warningOrange;
    } else {
      barColor = Colors.red;
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Resumen financiero',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.payments_outlined, color: AppColors.primaryBlue),
              ],
            ),
            const SizedBox(height: 12),
            _RowAmount(label: 'Esperado hoy', value: expected),
            const SizedBox(height: 6),
            _RowAmount(
              label: 'Pagado',
              value: paid,
              color: AppColors.successGreen,
            ),
            const SizedBox(height: 6),
            _RowAmount(label: 'Deuda', value: debt, color: Colors.red),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.withAlpha(30),
                color: barColor,
              ),
            ),
            const SizedBox(height: 6),
            Text('${(progress * 100).toStringAsFixed(0)}% cobrado'),
          ],
        ),
      ),
    );
  }
}

class _RowAmount extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;

  const _RowAmount({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.textDark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textGray)),
        Text(
          'C\$ ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
