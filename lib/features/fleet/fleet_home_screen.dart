import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import 'fleet_dashboard.dart';

class FleetHomeScreen extends StatelessWidget {
  const FleetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.fleet,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flota'),
          actions: const [LogoutButton()],
        ),
        body: const FleetDashboard(),
      ),
    );
  }
}
