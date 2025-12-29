import 'package:flutter/material.dart';

class FleetMapPlaceholder extends StatelessWidget {
  const FleetMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.map, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ubicación en tiempo real (próximamente)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pin(Colors.redAccent),
                    const SizedBox(width: 12),
                    _pin(Colors.greenAccent),
                    const SizedBox(width: 12),
                    _pin(Colors.orangeAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pin(Color color) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.location_on, color: color, size: 28),
      const SizedBox(height: 6),
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    ],
  );
}
