import 'package:flutter/material.dart';
import '../models/admin_activity.dart';

class AdminActivityList extends StatelessWidget {
  final List<AdminActivity> activities;

  const AdminActivityList({super.key, required this.activities});

  IconData _iconFor(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'delivery':
        return Icons.local_shipping;
      default:
        return Icons.info;
    }
  }

  String _shortTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities.map((a) {
        return ListTile(
          leading: CircleAvatar(child: Icon(_iconFor(a.type), size: 18)),
          title: Text(a.message),
          subtitle: Text(_shortTime(a.timestamp)),
        );
      }).toList(),
    );
  }
}
