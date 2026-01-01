import 'package:flutter/material.dart';
import 'services/buyer_service.dart';
import 'services/buyer_highlight_service.dart';
import 'widgets/product_card.dart';

class BuyerFeed extends StatelessWidget {
  const BuyerFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final products = BuyerService.getFeedProducts();

    return FutureBuilder<List<BuyerHighlight>>(
      future: BuyerHighlightService.getHighlights(),
      builder: (context, snapshot) {
        final highlights = snapshot.data ?? [];
        final items = <Widget>[];
        if (highlights.isNotEmpty) {
          items.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Descuentos destacados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ));
          items.addAll(highlights.map((h) => _HighlightCard(highlight: h)));
          items.add(const SizedBox(height: 12));
        }
        items.addAll(List.generate(products.length, (index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCard(product: product),
          );
        }));

        if (items.isEmpty) {
          return const Center(child: Text('Nada para mostrar aún'));
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: items,
        );
      },
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final BuyerHighlight highlight;

  const _HighlightCard({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Descuento'),
                ),
                const SizedBox(width: 8),
                Text(
                  highlight.sellerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(highlight.description),
          ],
        ),
      ),
    );
  }
}
