import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/product.dart';
import 'select_delivery_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.description,
              style: const TextStyle(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Vendedor: ${product.sellerName}',
              style: const TextStyle(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Precio: C\$ ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryBlue,
                    ),
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectDeliveryScreen(product: product),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                    ),
                    child: Text(
                      'Comprar • C\$ ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white),
                    ),
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
