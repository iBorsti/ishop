import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SellerReportsScreen extends StatelessWidget {
  const SellerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Center(
        child: Text('Reportes del vendedor (placeholder)', style: TextStyle(color: AppColors.textDark)),
      ),
    );
  }
}
