import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BuyerFeed extends StatelessWidget {
  const BuyerFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: AppColors.primaryBlue, child: const Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Tienda Ejemplo', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Hace 2 hrs', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                  ],
                ),
              ),
              // image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Producto destacado', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Descripción breve del producto', style: TextStyle(color: AppColors.textGray)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_shopping_cart), label: const Text('Comprar')),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () {}, child: const Text('Compartir')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
