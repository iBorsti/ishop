import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/auth/widgets/unauthorized_screen.dart';
import '../../core/auth/widgets/logout_button.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.instance;
    if (ctrl.user?.role != UserRole.seller) return const UnauthorizedScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendedor - Inicio'),
        actions: const [LogoutButton()],
      ),
      body: const Center(child: Text('Inicio vendedor')),
    );
  }
}
