import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.seller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vendedor - Inicio'),
          actions: const [LogoutButton()],
        ),
        body: const Center(child: Text('Inicio vendedor')),
      ),
    );
  }
}
