import 'package:flutter/material.dart';

class WeeklySummaryCard extends StatelessWidget {
  final String title;
  final List<String> lines;
  final String? highlightAmount;
  final String? subtitle;
  final String? comparison;

  const WeeklySummaryCard({
    super.key,
    required this.title,
    required this.lines,
    this.highlightAmount,
    this.subtitle,
    this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            const SizedBox(height: 8),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
            ),
            if (highlightAmount != null) ...[
              const SizedBox(height: 8),
              Text(
                highlightAmount!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
            if (comparison != null) ...[
              const SizedBox(height: 8),
              Text(
                comparison!,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
