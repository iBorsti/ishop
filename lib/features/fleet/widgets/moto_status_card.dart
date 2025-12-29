import 'package:flutter/material.dart';
import '../services/fleet_service.dart';
// import removed: not used here

class MotoStatusCard extends StatelessWidget {
  final Map<String, dynamic> moto;

  const MotoStatusCard({super.key, required this.moto});

  @override
  Widget build(BuildContext context) {
    final status = moto['status'] as String? ?? 'inactive';
    final quotaPaid = moto['quotaPaid'] as bool? ?? false;

    Color badgeColor;
    String statusText;
    switch (status) {
      case 'active':
        badgeColor = Colors.green;
        statusText = 'Activo';
        break;
      case 'pause':
        badgeColor = Colors.orange;
        statusText = 'Pausa';
        break;
      default:
        badgeColor = Colors.red;
        statusText = 'Inactivo';
    }

    final id = moto['id'] ?? '';
    final alias = moto['alias'] ?? '';
    final driver = moto['driver'] ?? '—';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: badgeColor.withAlpha(220),
              child: Icon(Icons.two_wheeler, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$id • $alias',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$driver • $statusText',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  quotaPaid ? 'Cuota: Pagada' : 'Cuota: Pendiente',
                  style: TextStyle(
                    color: quotaPaid ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(Icons.circle, color: badgeColor, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MotoStatusList extends StatelessWidget {
  final List<Map<String, dynamic>> motos;

  MotoStatusList({super.key}) : motos = FleetService.getMotos();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado de motos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: motos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return MotoStatusCard(moto: motos[index]);
          },
        ),
      ],
    );
  }
}
