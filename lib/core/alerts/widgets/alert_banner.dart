import 'package:flutter/material.dart';

import '../models/alert_level.dart';

class AlertBanner extends StatelessWidget {
  final AlertLevel level;
  final String message;

  const AlertBanner({
    super.key,
    required this.level,
    required this.message,
  });

  Color _background(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Colors.red.withAlpha(30);
      case AlertLevel.warning:
        return Colors.deepOrange.withAlpha(30);
      case AlertLevel.info:
        return Colors.orange.withAlpha(25);
      case AlertLevel.none:
        return Colors.transparent;
    }
  }

  Color _iconColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.deepOrange;
      case AlertLevel.info:
        return Colors.orange;
      case AlertLevel.none:
        return Colors.transparent;
    }
  }

  IconData _icon(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Icons.error_outline;
      case AlertLevel.warning:
        return Icons.report_problem_outlined;
      case AlertLevel.info:
        return Icons.info_outline;
      case AlertLevel.none:
        return Icons.check;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (level == AlertLevel.none) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _background(level),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _iconColor(level).withAlpha(120)),
      ),
      child: Row(
        children: [
          Icon(_icon(level), color: _iconColor(level)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
