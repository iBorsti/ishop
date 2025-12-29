import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/delivery_selector_service.dart';
import '../widgets/delivery_option_card.dart';
import 'order_confirmation_screen.dart';

class SelectDeliveryScreen extends StatelessWidget {
  final Product product;

  const SelectDeliveryScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final options = DeliverySelectorService.getOptions();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar delivery')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        itemBuilder: (_, i) {
          final option = options[i];
          return DeliveryOptionCard(
            option: option,
            onSelect: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderConfirmationScreen(
                    product: product,
                    delivery: option,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
