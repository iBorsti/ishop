import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SellerHistoryScreen extends StatelessWidget {
  const SellerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Center(
        child: Text(
          'Historial de ventas (placeholder)',
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
    );
  }
}
