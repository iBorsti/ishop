import 'package:flutter/material.dart';
import 'services/buyer_service.dart';
import 'services/buyer_highlight_service.dart';
import '../seller/services/seller_post_service.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/product_card.dart';

class BuyerFeed extends StatelessWidget {
  const BuyerFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final products = BuyerService.getFeedProducts();

    return FutureBuilder<List<BuyerHighlight>>(
      future: BuyerHighlightService.getHighlights(),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final highlights = snapshot.data ?? [];
        final loadingHighlights =
            snapshot.connectionState == ConnectionState.waiting &&
                highlights.isEmpty;

        final items = <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Para ti', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Descuentos y productos de negocios abiertos',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ];

        if (loadingHighlights) {
          items.add(const _HighlightsPlaceholder());
          items.add(const SizedBox(height: 12));
        } else if (highlights.isNotEmpty) {
          items.add(const _SectionTitle('Descuentos destacados'));
          items.add(const SizedBox(height: 6));
          items.addAll(highlights.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HighlightCard(highlight: h),
            ),
          ));
          items.add(const SizedBox(height: 12));
        }

        if (products.isNotEmpty) {
          items.add(const _SectionTitle('Productos'));
          items.add(const SizedBox(height: 8));
          items.addAll(List.generate(products.length, (index) {
            final product = products[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(product: product),
            );
          }));
        }

        final hasContent = highlights.isNotEmpty || products.isNotEmpty;
        if (!hasContent && !loadingHighlights) {
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(color: AppColors.navy),
    );
  }
}

class _HighlightsPlaceholder extends StatelessWidget {
  const _HighlightsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 1 ? 0 : 10),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 140,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final BuyerHighlight highlight;

  const _HighlightCard({required this.highlight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.cardWhite,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.turquoise.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.turquoise,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight.sellerName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: AppColors.navy),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Descuento disponible',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warningYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Descuento',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              highlight.description,
              style:
                  theme.textTheme.bodyLarge?.copyWith(color: AppColors.navy),
            ),
          ],
        ),
      ),
    );
  }
}
