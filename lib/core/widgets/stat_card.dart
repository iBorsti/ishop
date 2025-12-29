import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconBg;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconBg,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool colored = backgroundColor != null;
    final cardColor = backgroundColor ?? AppColors.cardWhite;
    final titleColor = colored ? Colors.white70 : AppColors.textGray;
    final valueColor = colored ? Colors.white : AppColors.textDark;

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null)
              Container(
                decoration: BoxDecoration(
                  color:
                      iconBg ??
                      (colored
                          ? Colors.white24
                          : AppColors.primaryBlue.withAlpha(
                              (0.15 * 255).round(),
                            )),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: colored ? Colors.white : AppColors.primaryBlue,
                  size: 22,
                ),
              ),
            if (icon != null) const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
