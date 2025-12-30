import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import 'delivery_dashboard.dart';

class DeliveryHomeScreen extends StatelessWidget {
  const DeliveryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.delivery,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery'),
          actions: const [LogoutButton()],
        ),
        body: const DeliveryDashboard(),
      ),
    );
  }
}
