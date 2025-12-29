import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/delivery_option.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Product product;
  final DeliveryOption delivery;

  const OrderConfirmationScreen({
    super.key,
    required this.product,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    final total = product.price + delivery.price;

    return Scaffold(
      appBar: AppBar(title: const Text('Pedido confirmado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Producto: ${product.name}'),
            Text('Delivery: ${delivery.name}'),
            Text('Tiempo estimado: ${delivery.etaMinutes} min'),
            const SizedBox(height: 16),
            Text(
              'Total: C\$ $total',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
