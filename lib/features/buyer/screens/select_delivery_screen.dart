import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product.dart';
import '../services/delivery_selector_service.dart';
import '../widgets/delivery_option_card.dart';
import 'order_confirmation_screen.dart';

class SelectDeliveryScreen extends StatefulWidget {
  final Product product;

  const SelectDeliveryScreen({super.key, required this.product});

  @override
  State<SelectDeliveryScreen> createState() => _SelectDeliveryScreenState();
}

class _SelectDeliveryScreenState extends State<SelectDeliveryScreen> {
  String? selectedName;

  @override
  Widget build(BuildContext context) {
    final options = DeliverySelectorService.getOptions();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar delivery')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Elige cómo recibirlo',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Opciones con tiempo estimado y costo fijo',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final option = options[i];
                final isSelected = option.name == selectedName;
                return DeliveryOptionCard(
                  option: option,
                  isSelected: isSelected,
                  onSelect: () {
                    setState(() => selectedName = option.name);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedName == null
                    ? null
                    : () {
                        final selected = options.firstWhere(
                          (o) => o.name == selectedName,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderConfirmationScreen(
                              product: widget.product,
                              delivery: selected,
                            ),
                          ),
                        );
                      },
                style: AppButtonStyles.success.copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return AppColors.textGray.withValues(alpha: 0.16);
                    }
                    return AppColors.successGreen;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return AppColors.textGray;
                    }
                    return Colors.white;
                  }),
                ),
                child: const Text('Confirmar delivery'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
