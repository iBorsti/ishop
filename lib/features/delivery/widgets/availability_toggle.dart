import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AvailabilityToggle extends StatefulWidget {
  const AvailabilityToggle({super.key});

  @override
  State<AvailabilityToggle> createState() => _AvailabilityToggleState();
}

class _AvailabilityToggleState extends State<AvailabilityToggle> {
  bool available = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: available
            ? AppColors.successGreen.withAlpha(30)
            : Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.pause_circle,
            color: available ? AppColors.successGreen : Colors.grey,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              available ? 'Disponible para pedidos' : 'No disponible',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: available,
            activeColor: AppColors.successGreen,
            onChanged: (value) {
              setState(() {
                available = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
