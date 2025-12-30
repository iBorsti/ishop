import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../state/auth_controller.dart';
import 'unauthorized_screen.dart';

class RoleGuard extends StatelessWidget {
  final UserRole requiredRole;
  final Widget child;

  const RoleGuard({super.key, required this.requiredRole, required this.child});

  @override
  Widget build(BuildContext context) {
    final role = AuthController.instance.user?.role;
    if (role != requiredRole) return const UnauthorizedScreen();
    return child;
  }
}
