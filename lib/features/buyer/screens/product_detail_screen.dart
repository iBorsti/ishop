import 'package:flutter/material.dart';
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
            Text(product.description),
            const SizedBox(height: 8),
            Text('Vendedor: ${product.sellerName}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectDeliveryScreen(product: product),
                  ),
                );
              },
              child: Text('Comprar • C\$ ${product.price.toStringAsFixed(0)}'),
            ),
          ],
        ),
      ),
    );
  }
}
