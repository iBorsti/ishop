import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/product.dart';
import 'order_confirmation_screen.dart';

/// Pantalla legacy: mantiene compatibilidad pero ahora solo confirma el pedido
/// sin seleccionar repartidor. Se podría eliminar cuando ya no haya rutas
/// apuntando aquí.
class SelectDeliveryScreen extends StatelessWidget {
  final Product product;

  const SelectDeliveryScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ya no necesitas elegir un delivery. Enviamos tu pedido y los repartidores cercanos pueden aceptarlo.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Producto: ${product.name}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderConfirmationScreen(product: product),
                    ),
                  );
                },
                style: AppButtonStyles.success,
                child: const Text('Enviar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
