import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/delivery_option.dart';

class DeliveryOptionCard extends StatelessWidget {
  final DeliveryOption option;
  final VoidCallback onSelect;
  final bool isSelected;

  const DeliveryOptionCard({
    super.key,
    required this.option,
    required this.onSelect,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.turquoise
        : AppColors.textGray.withValues(alpha: 0.18);

    return Card(
      elevation: isSelected ? 2.5 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: isSelected ? 1.4 : 1),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ETA ~ ${option.etaMinutes} min',
                      style: const TextStyle(color: AppColors.textGray),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'C\$ ${option.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.successGreen
                            : AppColors.textGray.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSelected ? 'Seleccionado' : 'Elegir',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.successGreen
                              : AppColors.turquoise,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
