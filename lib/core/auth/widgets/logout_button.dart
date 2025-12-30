import 'package:flutter/material.dart';
import '../state/auth_controller.dart';
import '../auth_gate.dart';

class LogoutButton extends StatelessWidget {
  final Color? color;
  const LogoutButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      color: color,
      onPressed: () async {
        await AuthController.instance.logout();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
      },
      tooltip: 'Cerrar sesión',
    );
  }
}
