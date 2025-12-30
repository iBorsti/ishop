import 'package:flutter/material.dart';
import '../state/auth_controller.dart';

class LogoutButton extends StatelessWidget {
  final Color? color;
  const LogoutButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      color: color,
      onPressed: () => AuthController.instance.logout(),
      tooltip: 'Cerrar sesión',
    );
  }
}
