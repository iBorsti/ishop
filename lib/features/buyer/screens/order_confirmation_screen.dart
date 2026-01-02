import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/product.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Product product;

  const OrderConfirmationScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
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
                '¡Pedido enviado a repartidores!',
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
                'Los repartidores cercanos reciben tu pedido y podrán aceptarlo. Te avisaremos cuando uno lo tome.',
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
                  const _SummaryRow(
                    label: 'Estado',
                    value: 'Esperando aceptación de un delivery',
                    valueStyle: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _SummaryRow(
                    label: 'Envío',
                    value: 'Se confirmará cuando un delivery acepte',
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
