import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/auth/widgets/unauthorized_screen.dart';
import '../../core/auth/widgets/logout_button.dart';
import 'fleet_dashboard.dart';

class FleetHomeScreen extends StatelessWidget {
  const FleetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.instance;
    if (ctrl.user?.role != UserRole.fleet) return const UnauthorizedScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flota'),
        actions: const [LogoutButton()],
      ),
      body: const FleetDashboard(),
    );
  }
}
