import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PublishProductScreen extends StatelessWidget {
  const PublishProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar producto')),
      body: Center(
        child: Text('Formulario para publicar producto (placeholder)', style: TextStyle(color: AppColors.textDark)),
      ),
    );
  }
}
