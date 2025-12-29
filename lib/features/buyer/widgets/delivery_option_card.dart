import 'package:flutter/material.dart';
import '../models/delivery_option.dart';

class DeliveryOptionCard extends StatelessWidget {
  final DeliveryOption option;
  final VoidCallback onSelect;

  const DeliveryOptionCard({
    super.key,
    required this.option,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(option.name),
        subtitle: Text('ETA ~ ${option.etaMinutes} min'),
        trailing: Text('C\$ ${option.price.toStringAsFixed(0)}'),
        onTap: onSelect,
      ),
    );
  }
}
