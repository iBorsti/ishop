import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import 'admin_dashboard.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.admin,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: const [LogoutButton()],
        ),
        body: const AdminDashboard(),
      ),
    );
  }
}
