import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '¡Pedido en camino!',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Hemos asignado tu delivery. Puedes revisar el estado desde inicio.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textGray.withValues(alpha: 0.14)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    label: 'Producto',
                    value: product.name,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Delivery',
                    value: '${delivery.name} · ETA ${delivery.etaMinutes} min',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Envío',
                    value: 'C\$ ${delivery.price.toStringAsFixed(0)}',
                  ),
                  const Divider(height: 22),
                  _SummaryRow(
                    label: 'Total a pagar',
                    value: 'C\$ ${total.toStringAsFixed(0)}',
                    valueStyle: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turquoise,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textGray),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle ?? const TextStyle(color: AppColors.navy),
          ),
        ),
      ],
    );
  }
}
