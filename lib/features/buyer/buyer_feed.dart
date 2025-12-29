import 'package:flutter/material.dart';
import 'services/buyer_service.dart';
import 'widgets/product_card.dart';

class BuyerFeed extends StatelessWidget {
  const BuyerFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final products = BuyerService.getFeedProducts();

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }
}
